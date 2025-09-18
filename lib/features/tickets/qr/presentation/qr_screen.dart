import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:bombotickets/config/theme/app_theme_new.dart';
import 'package:bombotickets/features/tickets/qr/providers/qr_form_provider.dart';
import 'package:bombotickets/features/shared/utils/responsive.dart';
import 'package:bombotickets/features/shared/widgets/custom_button.dart';
import 'package:bombotickets/features/shared/widgets/custom_input_field.dart';

class QrScreen extends ConsumerStatefulWidget {
  const QrScreen({super.key});
  static const name = 'qr-screen';

  @override
  ConsumerState<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends ConsumerState<QrScreen> {
  int _tableId = 0;
  int _splitCount = 1;
  double _tableTotal = 0.0;
  double? _tipPercentage;
  bool _showTipOptions = false;


  //
  int _quantity = 0;
  double? _unitPrice; 
  int? _maxQuantity;
  static const double _commissionPct = 10.0;

  @override
void didChangeDependencies() {
  super.didChangeDependencies();

  // Si ya cargamos ambos, nada que hacer
  if (_unitPrice != null && _maxQuantity != null) return;

  final state = GoRouterState.of(context);
  final extra = state.extra; // Object?

  if (extra is Map<String, dynamic>) {
    // unitPrice
    final upAny = extra['unitPrice'];
    if (_unitPrice == null && upAny != null) {
      _unitPrice = (upAny is num)
          ? upAny.toDouble()
          : double.tryParse(upAny.toString());
    }

    // maxQuantity
    final mqAny = extra['maxQuantity'];
    if (_maxQuantity == null && mqAny != null) {
      final parsed = (mqAny is num)
          ? mqAny.toInt()
          : int.tryParse(mqAny.toString());
      if (parsed != null) {
        _maxQuantity = parsed; // int?
      }
    }
  }
}


  double get _baseTotal => (_unitPrice ?? 0) * _quantity;
  double get _commissionBs => _baseTotal * (_commissionPct / 100);
  double get _grandTotal => _baseTotal + _commissionBs;

  @override
  Widget build(BuildContext context) {

    final totalToPay = _calculateTotal();

    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Padding(
              //padding: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                        'Cobro QR',
                        style: Theme.of(
                          context,
                        ).textTheme.displayLarge?.copyWith(
                          fontSize: AppTheme.fontSizeH1,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 800.ms, curve: Curves.easeOutQuart)
                      .slideY(
                        begin: -0.15,
                        duration: 800.ms,
                        curve: Curves.easeOutCubic,
                      )
                      .then(delay: 300.ms)
                      .shimmer(
                        duration: 1000.ms,
                        color: AppTheme.primaryColor.withOpacity(0.2),
                      ),
                  const SizedBox(height: 32),

                    if (_unitPrice == null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                      ),
                      child: const Text(
                        'No se recibió el precio del ticket. Vuelve y reintenta.',
                      ),
                    ),

                  if (_unitPrice != null) ...[
                    Text('Precio unitario: Bs. ${_unitPrice!.toStringAsFixed(2)}'),
                    const SizedBox(height: 16),

                  // Campo Cantidad
                  CustomInputField(
                        label: 'Cantidad',
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                            setState(() {
                          _quantity = int.tryParse(value) ?? 0;
                          if (_quantity < 0) _quantity = 0;
                          if (_maxQuantity != null && _quantity > _maxQuantity!) {
      _quantity = _maxQuantity!;
       Padding(
    padding: const EdgeInsets.only(top: 6),
    child: Text(
      'Máximo disponible: $_maxQuantity',
      style: TextStyle(color: Colors.grey[600]),
    ));
    }
                        });
                      },
                      )
                      .animate(delay: 400.ms)
                      .fadeIn(duration: 700.ms, curve: Curves.easeOutQuart)
                      .slideY(
                        begin: 0.2,
                        duration: 700.ms,
                        curve: Curves.easeOutCubic,
                      )
                      .scale(
                        begin: const Offset(0.95, 0.95),
                        duration: 700.ms,
                        curve: Curves.easeOutCubic,
                      ),
                  const SizedBox(height: 24),

                  // Campo: Total de mesa
                  /*
                  CustomInputField(
                        label: 'Total ',
                        hintText: 'Bs. 0',
                        keyboardType: TextInputType.number,
                        bigFont: true,
                        textAlign: TextAlign.end,
                        onChanged: (value) {
                          setState(() {
                            _tableTotal = double.tryParse(value) ?? 0.0;
                          });
                        },
                      )
                      .animate(delay: 600.ms)
                      .fadeIn(duration: 700.ms, curve: Curves.easeOutQuart)
                      .slideY(
                        begin: 0.2,
                        duration: 700.ms,
                        curve: Curves.easeOutCubic,
                      )
                      .scale(
                        begin: const Offset(0.95, 0.95),
                        duration: 700.ms,
                        curve: Curves.easeOutCubic,
                      ),
                  const SizedBox(height: 24),

                  // Sección: Dividir cuenta
                  _buildSplitSection()
                      .animate(delay: 600.ms)
                      .fadeIn(duration: 600.ms, curve: Curves.easeOutQuart)
                      .slideY(
                        begin: 0.3,
                        duration: 600.ms,
                        curve: Curves.easeOutBack,
                      ),
                  const SizedBox(height: 24),
                  

                  // Botón para agregar propina
                  _buildAddTipButton()
                      .animate(delay: 800.ms)
                      .fadeIn(duration: 600.ms, curve: Curves.easeOutQuart)
                      .scale(
                        begin: const Offset(0.8, 0.8),
                        duration: 600.ms,
                        curve: Curves.easeOutBack,
                      ),
                  const SizedBox(height: 12),

                  // Opciones de propina (solo visible cuando se activa)
                  if (_showTipOptions)
                    _buildTipOptions()
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .slideY(
                          begin: -0.2,
                          duration: 400.ms,
                          curve: Curves.easeOutQuart,
                        ),
                  if (_showTipOptions) const SizedBox(height: 24),

                  // Campo: Total a cobrar
                  CustomInputField(
                        label: 'Total a cobrar por persona',
                        hintText: 'Bs. 0',
                        value: 'Bs. ${totalToPay.toStringAsFixed(2)}',
                        isReadOnly: true,
                        keyboardType: TextInputType.number,
                        bigFont: true,
                        textAlign: TextAlign.end,
                      )
                      .animate(delay: 1000.ms)
                      .fadeIn(duration: 600.ms, curve: Curves.easeOutQuart)
                      .slideX(
                        begin: -0.3,
                        duration: 600.ms,
                        curve: Curves.easeOutQuart,
                      ),
                  const SizedBox(height: 40),
*/
   // Resumen
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppTheme.borderRadiusNormal),
                      ),
                      child: Column(
                        children: [
                          _row('Subtotal (${_quantity} × ${_unitPrice!.toStringAsFixed(2)})', _baseTotal),
                          const SizedBox(height: 6),
                          _row('Comisión (${_commissionPct.toStringAsFixed(0)}%)', _commissionBs),
                          const Divider(height: 18),
                          _row('Total', _grandTotal, isBold: true),
                        ],
                      ),
                    ),
                  // Botón de cobrar QR
                  CustomButton(
                        text: 'Pagar QR',
                         isEnabled: _quantity > 0 && _grandTotal > 0,
                      onPressed: (_quantity > 0 && _grandTotal > 0)
                          ? () {
                              // Inicializar provider sin dividir cuentas
                       ref.read(qrFormProvider.notifier).initializeSimple(
  baseTotal: _baseTotal,
  commissionPercent: _commissionPct,
  quantity: _quantity,
);
                              log('Generar QR por Bs. ${_grandTotal.toStringAsFixed(2)} '
                                  '(base ${_baseTotal.toStringAsFixed(2)} + com ${_commissionBs.toStringAsFixed(2)}) '
                                  'cantidad=$_quantity');

                              // Ir a generar QR
                              context.push('/qr-generation');
                            }
                          : null,
                    )
                      .animate(delay: 1200.ms)
                      .fadeIn(duration: 600.ms, curve: Curves.easeOutQuart)
                      .slideY(
                        begin: 0.5,
                        duration: 600.ms,
                        curve: Curves.easeOutBack,
                      ),
                  //const SizedBox(height: 32),
                ],
                ],
              ),
            ),
          ),
        ),
      ),
      // Barra de navegación inferior
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }
 Widget _row(String label, double value, {bool isBold = false}) {
    final style = TextStyle(
      fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text('Bs. ${value.toStringAsFixed(2)}', style: style),
      ],
    );
  }

  Widget _buildSplitSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '¿Entre cuántos dividimos?',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            fontSize: AppTheme.fontSizeH2,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Botón para disminuir
            Expanded(
              child: _buildCounterButton(
                icon: Icons.remove,
                onPressed: () {
                  setState(() {
                    if (_splitCount > 1) _splitCount--;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),

            // Botón para aumentar
            Expanded(
              child: _buildCounterButton(
                icon: Icons.add,
                onPressed: () {
                  setState(() {
                    _splitCount++;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),

            // Campo para mostrar/editar el número
            /*
            Expanded(
              flex: 2,
              child: CustomInputField(
                //hintText: '1',
                //isReadOnly: true,
                controller: TextEditingController(text: _splitCount.toString()),
                keyboardType: TextInputType.number,
                //textAlign: TextAlign.center,
                //bigFont: true,
              ),
             
            ),
             */
          ],
        ),
      ],
    );
  }

  Widget _buildCounterButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 48, // 3rem = 48px
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusNormal),
          ),
          padding: EdgeInsets.zero,
        ),
        onPressed: onPressed,
        child: Icon(icon, color: Colors.black),
      ),
    );
  }

  Widget _buildAddTipButton() {
    return SizedBox(
      width: double.infinity,
      height: 48, // 3rem = 48px
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            width: 3,
            color:
                _showTipOptions
                    ? AppTheme.highlightBlue
                    : AppTheme.greyBtnColor,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
          ),
          foregroundColor:
              _showTipOptions ? AppTheme.highlightBlue : AppTheme.greyBtnColor,
        ),
        onPressed: () {
          setState(() {
            _showTipOptions = !_showTipOptions;
            if (!_showTipOptions) _tipPercentage = null;
          });
        },
        child: Text(
          '¿Agregamos propina?',
          style: TextStyle(
            fontSize: AppTheme.fontSizeH2,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildTipOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildTipOption(percentage: 5)),
            const SizedBox(width: 12),
            Expanded(child: _buildTipOption(percentage: 10)),
            const SizedBox(width: 12),
            Expanded(child: _buildTipOption(percentage: 15)),
          ],
        ),
      ],
    );
  }

  Widget _buildTipOption({required int percentage}) {
    final isSelected = _tipPercentage == percentage.toDouble();

    return GestureDetector(
      onTap: () {
        setState(() {
          _tipPercentage = isSelected ? null : percentage.toDouble();
        });
      },
      child: Container(
        height: 48, // 3rem = 48px
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
          border: Border.all(
            width: 3,
            color: isSelected ? AppTheme.highlightBlue : AppTheme.greyBtnColor,
          ),
        ),
        child: Center(
          child: Text(
            '$percentage%',
            style: TextStyle(
              fontSize: AppTheme.fontSizeBodyLarge,
              fontWeight: FontWeight.w600,
              color:
                  isSelected ? AppTheme.highlightBlue : AppTheme.greyBtnColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    Responsive responsive = Responsive.of(context);
    return Container(
          //height: 96, // 6rem = 96px
          padding: EdgeInsets.only(
            top: responsive.hp(1.8),
            bottom: responsive.hp(3.8),
            left: responsive.wp(3.8),
            right: responsive.wp(3.8),
          ),
          decoration: BoxDecoration(
            color: AppTheme.scaffoldBackground,
            border: Border(
              top: BorderSide(color: AppTheme.navBorderColor, width: 1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                    onPressed: () => context.pop(),
                    child: Text(
                      'Atrás',
                      style: TextStyle(
                        fontSize: responsive.dp(1.8),
                        fontWeight: FontWeight.w500,
                        color: AppTheme.bodyFontColor,
                      ),
                    ),
                  )
                  .animate(delay: 1400.ms)
                  .fadeIn(duration: 600.ms)
                  .slideX(
                    begin: -0.3,
                    duration: 600.ms,
                    curve: Curves.easeOutBack,
                  ),
              ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppTheme.borderRadiusSmall,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                    ),
                    onPressed: () => context.pop(),
                    child: Text(
                      'Cancelar',
                      style: TextStyle(
                        fontSize: responsive.dp(1.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                  .animate(delay: 1500.ms)
                  .fadeIn(duration: 600.ms)
                  .slideX(
                    begin: 0.3,
                    duration: 600.ms,
                    curve: Curves.easeOutBack,
                  ),
            ],
          ),
        )
        .animate(delay: 1300.ms)
        .fadeIn(duration: 600.ms)
        .slideY(begin: 1.0, duration: 600.ms, curve: Curves.easeOutQuart);
  }

  double _calculateTotal() {
    double subtotal = _tableTotal / _splitCount;
    if (_tipPercentage != null) {
      subtotal += subtotal * (_tipPercentage! / 100);
    }
    return subtotal;
  }
}
