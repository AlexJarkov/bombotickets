import 'package:bombotickets/config/theme/app_theme_new.dart';
import 'package:bombotickets/features/shared/utils/responsive.dart';
import 'package:bombotickets/features/shared/widgets/animated_background.dart';
import 'package:bombotickets/features/shared/widgets/app_card.dart';
import 'package:bombotickets/features/shared/widgets/custom_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../repositories/tickets_repository.dart';
import '../providers/my_tickets_provider.dart';

class CreateListingScreen extends ConsumerStatefulWidget {
  const CreateListingScreen({super.key});

  @override
  ConsumerState<CreateListingScreen> createState() =>
      _CreateListingScreenState();
}

class _CreateListingScreenState extends ConsumerState<CreateListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');

  bool _isLoading = false;
  String? _scannedTicketInfo;
  List<String> _qrTokens = [];

  @override
  void dispose() {
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final res = Responsive.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Fondo animado
          const AnimatedBackground(child: SizedBox.expand()),

          // Contenido principal
          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(res, theme),

                // Contenido scrollable
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.all(res.wp(4)),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Información del proceso
                          _buildProcessInfo(res, theme),

                          SizedBox(height: AppTheme.spacingLarge),

                          // Escanear ticket
                          _buildScanTicketSection(res, theme),

                          SizedBox(height: AppTheme.spacingLarge),

                          // Configuración de la venta
                          if (_scannedTicketInfo != null)
                            _buildSaleConfiguration(res, theme),
                        ],
                      ),
                    ),
                  ),
                ),

                // Botón de crear publicación
                if (_scannedTicketInfo != null) _buildCreateButton(res, theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Responsive res, ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(res.wp(4)),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios,
              color: theme.colorScheme.onSurface,
              size: res.dp(2.5),
            ),
          ),
          SizedBox(width: res.wp(2)),
          Expanded(
            child: Text(
              'Crear Publicación',
              style: GoogleFonts.poppins(
                fontSize: AppTheme.fontSizeH2,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessInfo(Responsive res, ThemeData theme) {
    return AppCard(
          padding: EdgeInsets.all(res.wp(4)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppTheme.primaryColor,
                    size: res.dp(2.5),
                  ),
                  SizedBox(width: res.wp(3)),
                  Text(
                    '¿Cómo funciona?',
                    style: GoogleFonts.poppins(
                      fontSize: AppTheme.fontSizeBodyLarge,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),

              SizedBox(height: AppTheme.spacingMedium),

              ..._buildProcessSteps(res, theme),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.3, duration: 600.ms, curve: Curves.easeOutBack);
  }

  List<Widget> _buildProcessSteps(Responsive res, ThemeData theme) {
    final steps = [
      {
        'icon': Icons.qr_code_scanner,
        'text': 'Escanea el código QR de tu ticket',
      },
      {'icon': Icons.attach_money, 'text': 'Configura el precio de venta'},
      {'icon': Icons.publish, 'text': 'Publica y espera compradores'},
      {'icon': Icons.payment, 'text': 'Recibe el pago de forma segura'},
    ];

    return steps.asMap().entries.map((entry) {
      final step = entry.value;

      return Padding(
        padding: EdgeInsets.symmetric(vertical: res.hp(0.5)),
        child: Row(
          children: [
            Container(
              width: res.dp(3),
              height: res.dp(3),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(res.dp(1.5)),
              ),
              child: Icon(
                step['icon'] as IconData,
                size: res.dp(1.8),
                color: AppTheme.primaryColor,
              ),
            ),
            SizedBox(width: res.wp(3)),
            Expanded(
              child: Text(
                step['text'] as String,
                style: GoogleFonts.inter(
                  fontSize: AppTheme.fontSizeBodyNormal,
                  color: AppTheme.grey1,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildScanTicketSection(Responsive res, ThemeData theme) {
    return AppCard(
          padding: EdgeInsets.all(res.wp(4)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Paso 1: Escanear Ticket',
                style: GoogleFonts.poppins(
                  fontSize: AppTheme.fontSizeBodyLarge,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),

              SizedBox(height: AppTheme.spacingMedium),

              if (_scannedTicketInfo == null) ...[
                // Botón para escanear
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _scanTicket,
                    icon: Icon(Icons.qr_code_scanner),
                    label: Text('Escanear Código QR'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: res.hp(2)),
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),

                SizedBox(height: AppTheme.spacingMedium),

                Text(
                  'Escanea el código QR de tu ticket para verificar su autenticidad y obtener la información del evento.',
                  style: GoogleFonts.inter(
                    fontSize: AppTheme.fontSizeBodyNormal,
                    color: AppTheme.grey1,
                    height: 1.4,
                  ),
                ),
              ] else ...[
                // Información del ticket escaneado
                Container(
                  padding: EdgeInsets.all(res.wp(3)),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                      AppTheme.borderRadiusSmall,
                    ),
                    border: Border.all(
                      color: Colors.green.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: res.dp(2.5),
                      ),
                      SizedBox(width: res.wp(3)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ticket verificado',
                              style: GoogleFonts.inter(
                                fontSize: AppTheme.fontSizeBodyNormal,
                                fontWeight: FontWeight.w600,
                                color: Colors.green,
                              ),
                            ),
                            Text(
                              _scannedTicketInfo!,
                              style: GoogleFonts.inter(
                                fontSize: AppTheme.fontSizeBodyNormal,
                                color: AppTheme.grey1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _clearScan,
                        icon: Icon(
                          Icons.close,
                          color: AppTheme.grey1,
                          size: res.dp(2),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        )
        .animate(delay: 200.ms)
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.3, duration: 600.ms, curve: Curves.easeOutBack);
  }

  Widget _buildSaleConfiguration(Responsive res, ThemeData theme) {
    return AppCard(
          padding: EdgeInsets.all(res.wp(4)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Paso 2: Configurar Venta',
                style: GoogleFonts.poppins(
                  fontSize: AppTheme.fontSizeBodyLarge,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),

              SizedBox(height: AppTheme.spacingLarge),

              // Cantidad
              CustomInputField(
                controller: _quantityController,
                label: 'Cantidad de tickets',
                keyboardType: TextInputType.number,
              ),

              SizedBox(height: AppTheme.spacingMedium),

              // Precio
              CustomInputField(
                controller: _priceController,
                label: 'Precio de venta',
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                prefixIcon: Icons.attach_money,
              ),

              SizedBox(height: AppTheme.spacingMedium),

              // Información adicional
              Container(
                padding: EdgeInsets.all(res.wp(3)),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                    AppTheme.borderRadiusSmall,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppTheme.primaryColor,
                      size: res.dp(2),
                    ),
                    SizedBox(width: res.wp(3)),
                    Expanded(
                      child: Text(
                        'BomboTickets cobrará una comisión del 5% sobre el precio de venta.',
                        style: GoogleFonts.inter(
                          fontSize: AppTheme.fontSizeBodyNormal,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
        .animate(delay: 400.ms)
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.3, duration: 600.ms, curve: Curves.easeOutBack);
  }

  Widget _buildCreateButton(Responsive res, ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(res.wp(4)),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _createListing,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: res.hp(2)),
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppTheme.grey1,
          ),
          child: _isLoading
              ? SizedBox(
                  height: res.dp(2.5),
                  width: res.dp(2.5),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  'Crear Publicación',
                  style: GoogleFonts.inter(
                    fontSize: AppTheme.fontSizeBodyLarge,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }

  void _scanTicket() {
    // TODO: Implementar escaneo real
    // Por ahora simulamos un ticket escaneado
    setState(() {
      _scannedTicketInfo = 'Evento de prueba - Zona VIP - Asiento A12';
      _qrTokens = ['Bearer_dummy_token_12345']; // Token simulado
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ticket escaneado correctamente'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _clearScan() {
    setState(() {
      _scannedTicketInfo = null;
      _qrTokens.clear();
    });
  }

  Future<void> _createListing() async {
    if (!_formKey.currentState!.validate()) return;
    if (_qrTokens.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Debes escanear un ticket primero'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final repository = TicketsRepository();

      await repository.createResaleListing(
        qrTokens: _qrTokens,
        cantidad: int.parse(_quantityController.text),
        precioOfertado: double.parse(_priceController.text),
      );

      // Invalidar el provider para actualizar la lista
      ref.invalidate(myTicketsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡Publicación creada exitosamente!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear publicación: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
