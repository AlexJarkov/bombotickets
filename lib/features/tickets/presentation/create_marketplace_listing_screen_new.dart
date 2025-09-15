import 'package:bombotickets/config/theme/app_theme_new.dart';
import 'package:bombotickets/features/shared/utils/responsive.dart';
import 'package:bombotickets/features/shared/widgets/animated_background.dart';
import 'package:bombotickets/features/shared/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/marketplace_provider.dart';

// Modelo para la información del ticket escaneado
class ScannedTicketInfo {
  final int id;
  final String status;
  final String evento;
  final String zona;
  final String tokenId;
  final String qrToken;

  const ScannedTicketInfo({
    required this.id,
    required this.status,
    required this.evento,
    required this.zona,
    required this.tokenId,
    required this.qrToken,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScannedTicketInfo &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          qrToken == other.qrToken;

  @override
  int get hashCode => id.hashCode ^ qrToken.hashCode;
}

class CreateMarketplaceListingScreen extends ConsumerStatefulWidget {
  const CreateMarketplaceListingScreen({super.key});

  @override
  ConsumerState<CreateMarketplaceListingScreen> createState() =>
      _CreateMarketplaceListingScreenState();
}

class _CreateMarketplaceListingScreenState
    extends ConsumerState<CreateMarketplaceListingScreen> {
  final _priceController = TextEditingController();

  // Arrays para manejar los tickets según la especificación
  final List<String> _qrTokens = [];
  final List<ScannedTicketInfo> _scannedTickets = [];

  // Estado del formulario y scanner
  bool _isLoading = false;
  bool _isScanning = false;
  String? _currentEvent;
  String? _currentZone;

  // Controlador del scanner
  MobileScannerController? _scannerController;

  @override
  void dispose() {
    _priceController.dispose();
    _scannerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final res = Responsive.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBackground(
      style: BackgroundStyle.surface,
      animated: true,
      intensity: 0.6,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.all(AppTheme.spacingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header personalizado
                _buildCustomHeader(res, isDark),

                SizedBox(height: AppTheme.spacingLarge),

                // Loading overlay
                if (_isLoading)
                  Container(
                    margin: EdgeInsets.symmetric(
                      vertical: AppTheme.spacingLarge,
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ),

                // Contenido principal
                if (_isScanning)
                  _buildScannerSection(res, isDark)
                else ...[
                  // Información del evento/zona si hay tickets
                  if (_currentEvent != null && _currentZone != null)
                    _buildEventInfoCard(res, isDark),

                  if (_currentEvent != null && _currentZone != null)
                    SizedBox(height: AppTheme.spacingMedium),

                  // Lista de tickets escaneados
                  _buildTicketsSection(res, isDark),

                  SizedBox(height: AppTheme.spacingMedium),

                  // Botones de escaneo
                  _buildScanButtons(res, isDark),

                  SizedBox(height: AppTheme.spacingMedium),

                  // Campo de precio y botón de publicar
                  if (_scannedTickets.isNotEmpty) ...[
                    _buildPriceSection(res, isDark),
                    SizedBox(height: AppTheme.spacingMedium),
                    _buildPublishButton(res, isDark),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Header personalizado
  Widget _buildCustomHeader(Responsive res, bool isDark) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDark ? Colors.white : Colors.black87,
            size: res.dp(2.5),
          ),
        ),
        SizedBox(width: AppTheme.spacingSmall),
        Expanded(
          child:
              Text(
                    _isScanning ? 'Escanear QR' : 'Nueva Publicación',
                    style: GoogleFonts.poppins(
                      fontSize: AppTheme.fontSizeH2,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .slideY(
                    begin: -0.3,
                    duration: 600.ms,
                    curve: Curves.easeOutBack,
                  ),
        ),
        if (_isScanning)
          IconButton(
            onPressed: () {
              setState(() => _isScanning = false);
              _scannerController?.dispose();
              _scannerController = null;
            },
            icon: Icon(
              Icons.close,
              color: isDark ? Colors.white : Colors.black87,
              size: res.dp(2.5),
            ),
          ),
      ],
    );
  }

  // Sección del scanner
  Widget _buildScannerSection(Responsive res, bool isDark) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Scanner view
          Container(
            height: res.hp(50),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
              child: MobileScanner(
                controller: _scannerController ??= MobileScannerController(),
                onDetect: _onQRDetected,
              ),
            ),
          ),

          // Instrucciones
          Padding(
            padding: EdgeInsets.all(AppTheme.spacingLarge),
            child: Column(
              children: [
                Text(
                  'Apunta la cámara al código QR del ticket',
                  style: GoogleFonts.inter(
                    fontSize: AppTheme.fontSizeBodyLarge,
                    color: isDark ? Colors.white70 : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: AppTheme.spacingMedium),

                // Botón de galería alternativo
                OutlinedButton.icon(
                  onPressed: _pickImageFromGallery,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppTheme.primaryColor),
                    foregroundColor: AppTheme.primaryColor,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingLarge,
                      vertical: AppTheme.spacingMedium,
                    ),
                  ),
                  icon: Icon(Icons.photo_library),
                  label: Text('Desde Galería'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Card de información del evento
  Widget _buildEventInfoCard(Responsive res, bool isDark) {
    return AppCard(
      padding: EdgeInsets.all(AppTheme.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.event,
                color: AppTheme.primaryColor,
                size: res.dp(2.5),
              ),
              SizedBox(width: AppTheme.spacingSmall),
              Text(
                'Información del Evento',
                style: GoogleFonts.inter(
                  fontSize: AppTheme.fontSizeBodyLarge,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),

          SizedBox(height: AppTheme.spacingMedium),

          _buildInfoRow('Evento', _currentEvent!, isDark),
          SizedBox(height: AppTheme.spacingSmall),
          _buildInfoRow('Zona', _currentZone!, isDark),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, duration: 600.ms);
  }

  Widget _buildInfoRow(String label, String value, bool isDark) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: GoogleFonts.inter(
              fontSize: AppTheme.fontSizeBodyNormal,
              color: isDark ? Colors.white60 : Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: AppTheme.fontSizeBodyNormal,
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // Sección de tickets escaneados
  Widget _buildTicketsSection(Responsive res, bool isDark) {
    if (_scannedTickets.isEmpty) {
      return AppCard(
        padding: EdgeInsets.all(AppTheme.spacingLarge),
        child: Column(
          children: [
            Icon(
              Icons.qr_code_2,
              size: res.dp(8),
              color: isDark
                  ? Colors.white.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.26),
            ),
            SizedBox(height: AppTheme.spacingMedium),
            Text(
              'No hay tickets escaneados',
              style: GoogleFonts.inter(
                fontSize: AppTheme.fontSizeBodyLarge,
                color: isDark ? Colors.white60 : Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: AppTheme.spacingSmall),
            Text(
              'Escanea tu primer ticket para comenzar',
              style: GoogleFonts.inter(
                fontSize: AppTheme.fontSizeBodyNormal,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.4)
                    : Colors.black.withValues(alpha: 0.38),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return AppCard(
      padding: EdgeInsets.all(AppTheme.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.confirmation_number,
                color: AppTheme.primaryColor,
                size: res.dp(2.5),
              ),
              SizedBox(width: AppTheme.spacingSmall),
              Text(
                'Tickets Escaneados (${_scannedTickets.length})',
                style: GoogleFonts.inter(
                  fontSize: AppTheme.fontSizeBodyLarge,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),

          SizedBox(height: AppTheme.spacingMedium),

          ...List.generate(
            _scannedTickets.length,
            (index) =>
                _buildTicketItem(_scannedTickets[index], index, res, isDark),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, duration: 600.ms);
  }

  Widget _buildTicketItem(
    ScannedTicketInfo ticket,
    int index,
    Responsive res,
    bool isDark,
  ) {
    return Container(
          margin: EdgeInsets.only(
            bottom: index < _scannedTickets.length - 1
                ? AppTheme.spacingMedium
                : 0,
          ),
          padding: EdgeInsets.all(AppTheme.spacingMedium),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusNormal),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            children: [
              // Icono del ticket
              Container(
                padding: EdgeInsets.all(AppTheme.spacingSmall),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                    AppTheme.borderRadiusSmall,
                  ),
                ),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: res.dp(2),
                ),
              ),

              SizedBox(width: AppTheme.spacingMedium),

              // Información del ticket
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ticket #${ticket.id}',
                      style: GoogleFonts.inter(
                        fontSize: AppTheme.fontSizeBodyNormal,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Estado: ${ticket.status}',
                      style: GoogleFonts.inter(
                        fontSize: AppTheme.fontSizeBodyMedium,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              // Botón eliminar
              IconButton(
                onPressed: () => _removeTicket(index),
                icon: Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: res.dp(2),
                ),
              ),
            ],
          ),
        )
        .animate(delay: Duration(milliseconds: index * 100))
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.3, duration: 300.ms);
  }

  // Botones de escaneo
  Widget _buildScanButtons(Responsive res, bool isDark) {
    return Column(
      children: [
        // Botón principal de cámara
        _buildScanButton(
          res: res,
          isDark: isDark,
          title: _scannedTickets.isEmpty
              ? 'Escanear Primer QR'
              : 'Escanear Otro QR',
          subtitle: 'Usar cámara del dispositivo',
          icon: Icons.qr_code_scanner,
          onTap: () => setState(() => _isScanning = true),
          isPrimary: true,
        ),

        SizedBox(height: AppTheme.spacingMedium),

        // Botón de galería
        _buildScanButton(
          res: res,
          isDark: isDark,
          title: 'Desde Galería',
          subtitle: 'Seleccionar imagen con QR',
          icon: Icons.photo_library,
          onTap: _pickImageFromGallery,
          isPrimary: false,
        ),
      ],
    );
  }

  Widget _buildScanButton({
    required Responsive res,
    required bool isDark,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    return AppCard(
      padding: EdgeInsets.all(AppTheme.spacingLarge),
      child: InkWell(
        onTap: _isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        child: Column(
          children: [
            if (_isLoading && isPrimary)
              SizedBox(
                width: res.dp(4),
                height: res.dp(4),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryColor,
                  ),
                ),
              )
            else
              Container(
                padding: EdgeInsets.all(AppTheme.spacingMedium),
                decoration: BoxDecoration(
                  color: isPrimary
                      ? AppTheme.primaryColor.withValues(alpha: 0.1)
                      : (isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.black.withValues(alpha: 0.03)),
                  borderRadius: BorderRadius.circular(
                    AppTheme.borderRadiusLarge,
                  ),
                ),
                child: Icon(
                  icon,
                  size: res.dp(4),
                  color: isPrimary
                      ? AppTheme.primaryColor
                      : (isDark ? Colors.white60 : Colors.black54),
                ),
              ),

            SizedBox(height: AppTheme.spacingMedium),

            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: AppTheme.fontSizeBodyLarge,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: AppTheme.spacingSmall),

            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: AppTheme.fontSizeBodyNormal,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Sección de precio
  Widget _buildPriceSection(Responsive res, bool isDark) {
    return AppCard(
      padding: EdgeInsets.all(AppTheme.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.attach_money,
                color: AppTheme.primaryColor,
                size: res.dp(2.5),
              ),
              SizedBox(width: AppTheme.spacingSmall),
              Text(
                'Precio por Ticket',
                style: GoogleFonts.inter(
                  fontSize: AppTheme.fontSizeBodyLarge,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),

          SizedBox(height: AppTheme.spacingMedium),

          TextFormField(
            controller: _priceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: GoogleFonts.inter(
              color: isDark ? Colors.white : Colors.black87,
            ),
            decoration: InputDecoration(
              labelText: 'Precio unitario (Bs.)',
              labelStyle: GoogleFonts.inter(
                color: isDark ? Colors.white60 : Colors.black54,
              ),
              prefixIcon: Icon(
                Icons.monetization_on,
                color: AppTheme.primaryColor,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  AppTheme.borderRadiusNormal,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  AppTheme.borderRadiusNormal,
                ),
                borderSide: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.3)
                      : Colors.black.withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  AppTheme.borderRadiusNormal,
                ),
                borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, duration: 600.ms);
  }

  // Botón de publicar
  Widget _buildPublishButton(Responsive res, bool isDark) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _publishListing,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: AppTheme.spacingLarge),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusNormal),
          ),
        ),
        child: _isLoading
            ? CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
            : Text(
                'Publicar ${_scannedTickets.length} Ticket${_scannedTickets.length > 1 ? 's' : ''}',
                style: GoogleFonts.inter(
                  fontSize: AppTheme.fontSizeBodyLarge,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  // Manejar detección de QR desde cámara
  void _onQRDetected(BarcodeCapture capture) async {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty && !_isLoading) {
      final qrData = barcodes.first.rawValue;
      if (qrData != null) {
        await _validateQR(qrData);
      }
    }
  }

  // Seleccionar imagen desde galería
  void _pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() => _isLoading = true);
      try {
        final repository = ref.read(ticketsRepositoryProvider);
        final response = await repository.readQRFromFile(File(image.path));

        if (response['codigo'] == 200) {
          final qrToken = response['data']['qr'];
          await _validateQR(qrToken);
        } else {
          _showError(
            'No se pudo leer el QR de la imagen: ${response['mensaje']}',
          );
        }
      } catch (e) {
        _showError('Error al procesar la imagen: $e');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _validateQR(String qrToken) async {
    setState(() => _isLoading = true);

    try {
      final repository = ref.read(ticketsRepositoryProvider);
      final response = await repository.validateQRCode(qrToken);

      if (response['codigo'] == 200) {
        final ticketData = response['data'];
        final ticketInfo = ScannedTicketInfo(
          id: ticketData['id'],
          status: ticketData['status'],
          evento: ticketData['evento'],
          zona: ticketData['zona'],
          tokenId: ticketData['tokenId'],
          qrToken: qrToken,
        );

        // Verificar si el ticket ya fue escaneado
        if (_qrTokens.contains(qrToken)) {
          _showError('Este ticket ya fue escaneado');
          return;
        }

        // Verificar estado del ticket
        if (ticketInfo.status != 'EN_VENTA') {
          _showError(
            'El ticket no está disponible para venta (Estado: ${ticketInfo.status})',
          );
          return;
        }

        // Verificar que sea del mismo evento y zona
        if (_currentEvent == null && _currentZone == null) {
          // Primer ticket escaneado
          _currentEvent = ticketInfo.evento;
          _currentZone = ticketInfo.zona;
        } else if (_currentEvent != ticketInfo.evento ||
            _currentZone != ticketInfo.zona) {
          _showError(
            'Todos los tickets deben ser del mismo evento y zona.\nEsperado: $_currentEvent - $_currentZone\nEncontrado: ${ticketInfo.evento} - ${ticketInfo.zona}',
          );
          return;
        }

        // Agregar ticket a las listas
        _qrTokens.add(qrToken);
        _scannedTickets.add(ticketInfo);

        // Salir del modo scanner
        setState(() => _isScanning = false);
        _scannerController?.dispose();
        _scannerController = null;

        _showSuccess(
          'Ticket agregado correctamente (${_scannedTickets.length} tickets)',
        );
      } else {
        _showError('Error al validar QR: ${response['mensaje']}');
      }
    } catch (e) {
      _showError('Error al validar QR: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _removeTicket(int index) {
    setState(() {
      _qrTokens.removeAt(index);
      _scannedTickets.removeAt(index);

      // Si no quedan tickets, resetear evento y zona
      if (_scannedTickets.isEmpty) {
        _currentEvent = null;
        _currentZone = null;
      }
    });
  }

  Future<void> _publishListing() async {
    // Validación manual del precio
    if (_priceController.text.isEmpty) {
      _showError('Por favor ingresa un precio');
      return;
    }

    final price = double.tryParse(_priceController.text);
    if (price == null || price <= 0) {
      _showError('Ingresa un precio válido');
      return;
    }

    if (_scannedTickets.isEmpty) {
      _showError('Debes escanear al menos un ticket');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(ticketsRepositoryProvider);

      await repository.createMarketplaceListing(
        qrTokens: _qrTokens,
        cantidad: _scannedTickets.length,
        precioOfertado: price,
      );

      _showSuccess('¡Publicación creada exitosamente!');

      // Volver a la pantalla anterior después de un breve delay
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      _showError('Error al crear la publicación: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
