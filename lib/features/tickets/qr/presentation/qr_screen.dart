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

  String? _nombreEvento;
  String? _nombreZona;
  String? _correoVendedor;
  int? _publicacionID;

  int _quantity = 0;
  double? _unitPrice;
  int? _maxQuantity;
  static const double _commissionPct = 10.0;

  // Para no spamear SnackBars cuando se excede stock
  bool _exceedSnackShown = false;

  // Helpers de totales
  double get _baseTotal => (_unitPrice ?? 0) * _quantity;
  double get _commissionBs => _baseTotal * (_commissionPct / 100);
  double get _grandTotal => _baseTotal + _commissionBs;

  // ¿Supera el stock?
  bool get _exceedsStock => _maxQuantity != null && _quantity > _maxQuantity!;
  int get _faltantes => _maxQuantity == null ? 0 : (_quantity - _maxQuantity!).clamp(0, 1 << 30);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_unitPrice != null &&
        _maxQuantity != null &&
        _nombreEvento != null &&
        _nombreZona != null &&
        _correoVendedor != null &&
        _publicacionID != null) return;

    final state = GoRouterState.of(context);
    final extra = state.extra;
    log('INIT publicacionId original=$_publicacionID', name: 'QrForm.initializeSimple');

    if (extra is Map<String, dynamic>) {
      final upAny = extra['unitPrice'];
      if (_unitPrice == null && upAny != null) {
        _unitPrice = (upAny is num) ? upAny.toDouble() : double.tryParse(upAny.toString());
      }

      final mqAny = extra['maxQuantity'];
      if (_maxQuantity == null && mqAny != null) {
        final parsed = (mqAny is num) ? mqAny.toInt() : int.tryParse(mqAny.toString());
        if (parsed != null) _maxQuantity = parsed;
      }

      final publicacionId = extra['publicacionId'];
      log('INIT publicacionId=$publicacionId', name: 'QrForm.initializeSimple');
      if (_publicacionID == null && publicacionId != null) {
        final parsed = (publicacionId is num) ? publicacionId.toInt() : int.tryParse(publicacionId.toString());
        if (parsed != null) _publicacionID = parsed;
      }

      final eventoAny = extra['nombreEvento'];
      if (_nombreEvento == null && eventoAny != null) {
        _nombreEvento = eventoAny.toString().trim();
        if (_nombreEvento!.isEmpty) _nombreEvento = null;
      }

      final zonaAny = extra['zonaTicket']; // o 'nombreZona' si lo cambiaste
      if (_nombreZona == null && zonaAny != null) {
        _nombreZona = zonaAny.toString().trim();
        if (_nombreZona!.isEmpty) _nombreZona = null;
      }

      final vendedorAny = extra['correoVendedor'];
      if (_correoVendedor == null && vendedorAny != null) {
        _correoVendedor = vendedorAny.toString().trim();
        if (_correoVendedor!.isEmpty) _correoVendedor = null;
      }
    }

    log('DEBUG QrScreen extraídos: evento=$_nombreEvento, zona=$_nombreZona, vendedor=$_correoVendedor, price=$_unitPrice, maxQty=$_maxQuantity');
  }

  @override
  Widget build(BuildContext context) {
    final totalToPay = _calculateTotal(); // (no se usa mucho, lo dejo)

    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cobro QR',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: AppTheme.fontSizeH1,
                          fontWeight: FontWeight.w600,
                        ),
                  )
                      .animate()
                      .fadeIn(duration: 800.ms, curve: Curves.easeOutQuart)
                      .slideY(begin: -0.15, duration: 800.ms, curve: Curves.easeOutCubic)
                      .then(delay: 300.ms)
                      .shimmer(duration: 1000.ms, color: AppTheme.primaryColor.withOpacity(0.2)),
                  const SizedBox(height: 32),

                  if (_unitPrice == null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                      ),
                      child: const Text('No se recibió el precio del ticket. Vuelve y reintenta.'),
                    ),

                  if (_unitPrice != null) ...[
                    Text('Precio unitario: Bs. ${_unitPrice!.toStringAsFixed(2)}'),
                    if (_maxQuantity != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          'Disponibles: $_maxQuantity',
                          style: TextStyle(
                            fontSize: AppTheme.fontSizeBodyNormal,
                            color: Colors.black.withOpacity(0.6),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Campo Cantidad (sin recortar automáticamente)
                    CustomInputField(
                      label: 'Cantidad',
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        final newQty = int.tryParse(value) ?? 0;
                        final newExceed = _maxQuantity != null && newQty > _maxQuantity!;
                        setState(() {
                          _quantity = newQty < 0 ? 0 : newQty;
                        });

                        // SnackBar una sola vez al exceder
                        if (newExceed && !_exceedSnackShown) {
                          _exceedSnackShown = true;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                _maxQuantity == 0
                                    ? 'No hay entradas disponibles para esta zona.'
                                    : 'Solo hay $_maxQuantity ${_maxQuantity == 1 ? 'entrada' : 'entradas'} disponibles.',
                              ),
                              backgroundColor: Colors.red,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        } else if (!newExceed && _exceedSnackShown) {
                          _exceedSnackShown = false;
                        }
                      },
                    )
                        .animate(delay: 400.ms)
                        .fadeIn(duration: 700.ms, curve: Curves.easeOutQuart)
                        .slideY(begin: 0.2, duration: 700.ms, curve: Curves.easeOutCubic)
                        .scale(begin: const Offset(0.95, 0.95), duration: 700.ms, curve: Curves.easeOutCubic),

                    // Advertencia inline si se excede el stock
                    if (_exceedsStock)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                          border: Border.all(color: Colors.red.withOpacity(0.35)),
                        ),
                        child: Text(
                          _maxQuantity == 0
                              ? 'No hay entradas disponibles para esta zona.'
                              : 'Estás solicitando más de lo disponible. Solo hay $_maxQuantity ${_maxQuantity == 1 ? 'entrada' : 'entradas'} a la venta.',
                          style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.red),
                        ),
                      ),

                    const SizedBox(height: 24),

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

                    // Botón de cobrar QR (bloqueado si se excede)
                    CustomButton(
                      text: _exceedsStock ? 'Cantidad supera el stock' : 'Pagar QR',
                      isEnabled: _quantity > 0 && _grandTotal > 0 && !_exceedsStock,
                      onPressed: (_quantity > 0 && _grandTotal > 0 && !_exceedsStock)
                          ? () {
                              ref.read(qrFormProvider.notifier).initializeSimple(
                                    baseTotal: _baseTotal,
                                    commissionPercent: _commissionPct,
                                    quantity: _quantity,
                                    nombreEvento: _nombreEvento ?? 'Evento Desconocido',
                                    nombreZona: _nombreZona ?? 'Zona Desconocida',
                                    correoVendedor: _correoVendedor,
                                    publicacionId: _publicacionID,
                                  );
                              log('Generar QR por Bs. ${_grandTotal.toStringAsFixed(2)} '
                                  '(base ${_baseTotal.toStringAsFixed(2)} + com ${_commissionBs.toStringAsFixed(2)}) '
                                  'cantidad=$_quantity');

                              context.push('/qr-generation');
                            }
                          : null,
                    )
                        .animate(delay: 1200.ms)
                        .fadeIn(duration: 600.ms, curve: Curves.easeOutQuart)
                        .slideY(begin: 0.5, duration: 600.ms, curve: Curves.easeOutBack),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _row(String label, double value, {bool isBold = false}) {
    final style = TextStyle(fontWeight: isBold ? FontWeight.w700 : FontWeight.w500);
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
            Expanded(child: _buildCounterButton(icon: Icons.remove, onPressed: () => setState(() { if (_splitCount > 1) _splitCount--; }))),
            const SizedBox(width: 12),
            Expanded(child: _buildCounterButton(icon: Icons.add, onPressed: () => setState(() { _splitCount++; }))),
            const SizedBox(width: 12),
          ],
        ),
      ],
    );
  }

  Widget _buildCounterButton({required IconData icon, required VoidCallback onPressed}) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.borderRadiusNormal)),
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
      height: 48,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(width: 3, color: _showTipOptions ? AppTheme.highlightBlue : AppTheme.greyBtnColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall)),
          foregroundColor: _showTipOptions ? AppTheme.highlightBlue : AppTheme.greyBtnColor,
        ),
        onPressed: () {
          setState(() {
            _showTipOptions = !_showTipOptions;
            if (!_showTipOptions) _tipPercentage = null;
          });
        },
        child: Text(
          '¿Agregamos propina?',
          style: TextStyle(fontSize: AppTheme.fontSizeH2, fontWeight: FontWeight.w600),
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
      onTap: () => setState(() => _tipPercentage = isSelected ? null : percentage.toDouble()),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
          border: Border.all(width: 3, color: isSelected ? AppTheme.highlightBlue : AppTheme.greyBtnColor),
        ),
        child: Center(
          child: Text(
            '$percentage%',
            style: TextStyle(
              fontSize: AppTheme.fontSizeBodyLarge,
              fontWeight: FontWeight.w600,
              color: isSelected ? AppTheme.highlightBlue : AppTheme.greyBtnColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    final responsive = Responsive.of(context);
    return Container(
      padding: EdgeInsets.only(
        top: responsive.hp(1.8),
        bottom: responsive.hp(3.8),
        left: responsive.wp(3.8),
        right: responsive.wp(3.8),
      ),
      decoration: BoxDecoration(
        color: AppTheme.scaffoldBackground,
        border: Border(top: BorderSide(color: AppTheme.navBorderColor, width: 1)),
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
              .slideX(begin: -0.3, duration: 600.ms, curve: Curves.easeOutBack),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
            onPressed: () => context.pop(),
            child: Text(
              'Cancelar',
              style: TextStyle(fontSize: responsive.dp(1.8), fontWeight: FontWeight.w500),
            ),
          )
              .animate(delay: 1500.ms)
              .fadeIn(duration: 600.ms)
              .slideX(begin: 0.3, duration: 600.ms, curve: Curves.easeOutBack),
        ],
      ),
    ).animate(delay: 1300.ms).fadeIn(duration: 600.ms).slideY(begin: 1.0, duration: 600.ms, curve: Curves.easeOutQuart);
  }

  double _calculateTotal() {
    double subtotal = _tableTotal / _splitCount;
    if (_tipPercentage != null) {
      subtotal += subtotal * (_tipPercentage! / 100);
    }
    return subtotal;
  }
}
