import 'package:bombotickets/config/theme/app_theme_new.dart';
import 'package:bombotickets/features/profile/models/CuentaBancariaModels.dart';
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
import 'package:go_router/go_router.dart';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';

import '../providers/marketplace_provider.dart';

import 'package:bombotickets/features/profile/repositories/cuenta_bancaria.repository.dart';
import 'package:bombotickets/features/profile/presentation/cuenta_bancaria_form.screen.dart';

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

  // Arrays para manejar los tickets
  final List<String> _qrTokens = [];
  final List<ScannedTicketInfo> _scannedTickets = [];

  // Estado del formulario y scanner
  bool _isLoading = false;
  bool _isScanning = false;
  String? _currentEvent;
  String? _currentZone;

  // Controlador del scanner
  MobileScannerController? _scannerController;

  // ✅ Estado de cuenta bancaria
  bool _bankCheckInProgress = false;
  bool? _hasBankAccount; // null => desconocido; true/false => verificado

  @override
  void initState() {
    super.initState();
    _checkBankAccount();
  }

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
                // Header
                _buildCustomHeader(res, isDark),
                SizedBox(height: AppTheme.spacingLarge),

                // 🔎 Banner de advertencia si no hay cuenta bancaria
                if (!_bankCheckInProgress && _hasBankAccount == false)
                  Container(
                    margin: EdgeInsets.only(bottom: AppTheme.spacingMedium),
                    padding: EdgeInsets.all(AppTheme.spacingNormal),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(
                        AppTheme.borderRadiusSmall,
                      ),
                      border: Border.all(
                        color: Colors.orange.withOpacity(0.35),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.account_balance, color: Colors.orange),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Necesitas registrar una cuenta bancaria para publicar tus tickets.',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () async {
                            await context.pushNamed(
                              BankAccountFormScreen.name,
                              extra: const BankAccountFormArgs.create(),
                            );
                            if (mounted) _checkBankAccount();
                          },
                          child: const Text('Configurar'),
                        ),
                      ],
                    ),
                  ),

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
                  if (_currentEvent != null && _currentZone != null)
                    _buildEventInfoCard(res, isDark),
                  if (_currentEvent != null && _currentZone != null)
                    SizedBox(height: AppTheme.spacingMedium),

                  _buildTicketsSection(res, isDark),
                  SizedBox(height: AppTheme.spacingMedium),

                  // Botón de agregar ticket (requiere cuenta bancaria)
                  _buildAddTicketButton(res, isDark),
                  SizedBox(height: AppTheme.spacingMedium),

                  if (_scannedTickets.isNotEmpty) ...[
                    _buildPriceSection(res, isDark),
                    SizedBox(height: AppTheme.spacingMedium),
                    _buildPublishButton(res, isDark), // también valida cuenta
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================
  // VALIDACIÓN CUENTA BANCARIA
  // ==========================

  Future<void> _checkBankAccount() async {
    setState(() => _bankCheckInProgress = true);
    try {
      final repo = ref.read(cuentaBancariaRepositoryProvider);
      final res = await repo.getCuentas();

      final root = res['data'] ?? res;
      int count = 0;

      if (root is List) {
        count = root.length;
      } else if (root is Map) {
        if (root['cuentas'] is List) {
          count = (root['cuentas'] as List).length;
        } else if (root['cuentasBancarias'] is List) {
          count = (root['cuentasBancarias'] as List).length;
        } else if (root.isNotEmpty) {
          count = 1; // algunos backends devuelven objeto único
        }
      }

      setState(() => _hasBankAccount = count > 0);
    } catch (e) {
      setState(() => _hasBankAccount = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              const Text('No se pudo verificar tu cuenta bancaria. Intenta de nuevo.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _bankCheckInProgress = false);
    }
  }

  Future<bool> _requireBankAccountOrRedirect() async {
    // Si aún no sabemos, verifica
    if (_hasBankAccount == null) await _checkBankAccount();
    if (_hasBankAccount == true) return true;

    // Ofrece ir a crear
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cuenta bancaria requerida'),
        content: const Text(
          'Necesitas registrar una cuenta bancaria para poder publicar y vender tickets.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Ahora no'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Agregar cuenta'),
          ),
        ],
      ),
    );

    if (ok == true && mounted) {
      await context.pushNamed(
        BankAccountFormScreen.name,
        extra: const BankAccountFormArgs.create(),
      );
      // Revalidar al volver
      await _checkBankAccount();
    }

    return _hasBankAccount == true;
  }

  // ==========================
  // UI
  // ==========================

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
          child: Text(
            _isScanning ? 'Escanear QR' : 'Nueva Publicación',
            style: GoogleFonts.poppins(
              fontSize: AppTheme.fontSizeH2,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          )
              .animate()
              .fadeIn(duration: 600.ms)
              .slideY(begin: -0.3, duration: 600.ms, curve: Curves.easeOutBack),
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

  // Sección del scanner con diseño elegante
  Widget _buildScannerSection(Responsive res, bool isDark) {
    return SizedBox(
      height: res.hp(60),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;
          final cutOutSize = math.min(size.width, size.height) * 0.7;
          final cutOutTop = (size.height - cutOutSize) / 2;
          final cutOutLeft = (size.width - cutOutSize) / 2;
          final cutOutRect = Rect.fromLTWH(
            cutOutLeft,
            cutOutTop,
            cutOutSize,
            cutOutSize,
          );

          return Stack(
            fit: StackFit.expand,
            children: [
              // Camera preview con bordes redondeados
              ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                child: MobileScanner(
                  controller: _scannerController ??= MobileScannerController(
                    detectionSpeed: DetectionSpeed.unrestricted,
                    facing: CameraFacing.back,
                    torchEnabled: false,
                    formats: [BarcodeFormat.qrCode],
                  ),
                  fit: BoxFit.cover,
                  scanWindow: cutOutRect,
                  onDetect: _onQRDetected,
                  errorBuilder: (context, error, child) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(
                          AppTheme.borderRadiusLarge,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'No se pudo acceder a la cámara',
                          style: GoogleFonts.inter(color: Colors.white),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Overlay elegante
              Positioned.fill(
                child: _ScannerOverlay(
                  cutOutRect: cutOutRect,
                  processing: _isLoading,
                  onToggleTorch: () async {
                    try {
                      await _scannerController?.toggleTorch();
                    } catch (e) {
                      _showError('Error al cambiar la linterna');
                    }
                  },
                ),
              ),
            ],
          );
        },
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
              Expanded(
                child: Text(
                  'Información del Evento',
                  style: GoogleFonts.inter(
                    fontSize: AppTheme.fontSizeBodyLarge,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
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
              Expanded(
                child: Text(
                  'Tickets Escaneados (${_scannedTickets.length})',
                  style: GoogleFonts.inter(
                    fontSize: AppTheme.fontSizeBodyLarge,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacingMedium),
          ...List.generate(
            _scannedTickets.length,
            (index) => _buildTicketItem(_scannedTickets[index], index, res, isDark),
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
          SizedBox(height: 0, width: AppTheme.spacingMedium),
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
                const SizedBox(height: 2),
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

  // Botón de agregar ticket (verifica cuenta bancaria)
  Widget _buildAddTicketButton(Responsive res, bool isDark) {
    return AppCard(
      padding: EdgeInsets.symmetric(vertical: AppTheme.spacingLarge),
      child: Column(
        children: [
          Icon(
            Icons.add_circle_outline,
            size: res.dp(5),
            color: AppTheme.primaryColor,
          ),
          SizedBox(height: AppTheme.spacingMedium),
          Text(
            'Agregar Ticket',
            style: GoogleFonts.inter(
              fontSize: AppTheme.fontSizeBodyLarge,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.grey[800],
            ),
          ),
          SizedBox(height: AppTheme.spacingSmall),
          Text(
            _scannedTickets.isEmpty
                ? 'Agrega tu primer ticket escaneando el QR'
                : 'Agregar otro ticket a la publicación',
            style: GoogleFonts.inter(
              fontSize: AppTheme.fontSizeBodyMedium,
              color: isDark ? Colors.white70 : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppTheme.spacingLarge),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                if (_bankCheckInProgress) return;
                final ok = await _requireBankAccountOrRedirect();
                if (!ok) return;
                _showAddTicketOptions(context, res, isDark);
              },
              icon: const Icon(Icons.add),
              label: const Text('Agregar Ticket'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Mostrar opciones para agregar ticket
  void _showAddTicketOptions(
    BuildContext context,
    Responsive res,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.all(AppTheme.spacingMedium),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Indicador
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: AppTheme.spacingMedium),

                // Título
                Text(
                  'Agregar Ticket',
                  style: GoogleFonts.inter(
                    fontSize: AppTheme.fontSizeH3,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.grey[800],
                  ),
                ),
                SizedBox(height: AppTheme.spacingMedium),

                // Opción de cámara
                _buildOptionTile(
                  res: res,
                  isDark: isDark,
                  icon: Icons.qr_code_scanner,
                  title: 'Escanear con Cámara',
                  subtitle: 'Usar la cámara del dispositivo',
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _isScanning = true);
                  },
                ),

                SizedBox(height: AppTheme.spacingSmall),

                // Opción de galería
                _buildOptionTile(
                  res: res,
                  isDark: isDark,
                  icon: Icons.photo_library,
                  title: 'Desde Galería',
                  subtitle: 'Seleccionar imagen con código QR',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageFromGallery();
                  },
                ),

                SizedBox(height: AppTheme.spacingMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget para cada opción en el modal
  Widget _buildOptionTile({
    required Responsive res,
    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(AppTheme.spacingSmall),
        decoration: BoxDecoration(
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.grey.withOpacity(0.2),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppTheme.primaryColor,
                size: res.dp(2.4),
              ),
            ),
            SizedBox(width: AppTheme.spacingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: AppTheme.fontSizeBodyNormal,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: AppTheme.fontSizeBodyMedium,
                      color: isDark ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: res.dp(1.6),
              color: isDark ? Colors.white38 : Colors.grey,
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

  // Botón de publicar (verifica cuenta bancaria)
  Widget _buildPublishButton(Responsive res, bool isDark) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading
            ? null
            : () async {
                final ok = await _requireBankAccountOrRedirect();
                if (!ok) return;
                await _publishListing();
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: AppTheme.spacingLarge),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusNormal),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(
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

  // ==========================
  // LÓGICA
  // ==========================

  // Manejar detección de QR desde cámara
  void _onQRDetected(BarcodeCapture capture) async {
    if (!mounted) return;
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
          _showError('No se pudo leer el QR de la imagen: ${response['mensaje']}');
        }
      } catch (e) {
        _showError('Error al procesar la imagen: $e');
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _validateQR(String qrToken) async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(ticketsRepositoryProvider);
      final response = await repository.validateQRCode(qrToken);

      if (!mounted) return;

      // El repository ya devuelve directamente los datos del ticket
      if (response.isNotEmpty &&
          response['id'] != null &&
          response['status'] != null) {
        final ticketData = response;

        final ticketInfo = ScannedTicketInfo(
          id: ticketData['id'],
          status: ticketData['status'],
          evento: ticketData['evento'],
          zona: ticketData['zona'],
          tokenId: ticketData['tokenId'],
          qrToken: qrToken,
        );

        // Duplicado
        if (_qrTokens.contains(qrToken)) {
          _showError('Este ticket ya fue escaneado');
          return;
        }

        // Solo permitir vendidos/pagados si así lo exige tu negocio
        if (ticketInfo.status != 'PENDING_PAYMENT') {
          _showError(
            'Solo se pueden vender tickets pagados (Estado actual: ${ticketInfo.status})',
          );
          return;
        }

        // Consistencia evento/zona
        if (_currentEvent == null && _currentZone == null) {
          _currentEvent = ticketInfo.evento;
          _currentZone = ticketInfo.zona;
        } else if (_currentEvent != ticketInfo.evento ||
            _currentZone != ticketInfo.zona) {
          _showError(
            'Todos los tickets deben ser del mismo evento y zona.\n'
            'Esperado: $_currentEvent - $_currentZone\n'
            'Encontrado: ${ticketInfo.evento} - ${ticketInfo.zona}',
          );
          return;
        }

        // Agregar
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
        _showError('Los datos del ticket no son válidos');
      }
    } catch (e) {
      _showError('Error al validar QR: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showError('Error al crear la publicación: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showError(String? message) {
    if (!mounted) return;
    final errorMessage = message ?? 'Error desconocido';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}

// ==========================
// Overlay elegante del scanner
// ==========================

class _ScannerOverlay extends StatefulWidget {
  final Rect cutOutRect;
  final VoidCallback onToggleTorch;
  final bool processing;

  const _ScannerOverlay({
    Key? key,
    required this.cutOutRect,
    required this.onToggleTorch,
    required this.processing,
  }) : super(key: key);

  @override
  State<_ScannerOverlay> createState() => _ScannerOverlayState();
}

class _ScannerOverlayState extends State<_ScannerOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glowCtrl;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
      lowerBound: 0.0,
      upperBound: 1.0,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final res = Responsive.of(context);
    return AnimatedBuilder(
      animation: _glowCtrl,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final cutOutRect = widget.cutOutRect;
            final cutOutTop = cutOutRect.top;
            final cutOutSize = cutOutRect.width;
            final t = _glowCtrl.value; // 0..1

            return Stack(
              children: [
                // Blurred overlay outside the cutout
                ClipPath(
                  clipper: _OutsideHoleClipper(
                    holeRect: cutOutRect,
                    radius: 16,
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(color: Colors.black.withOpacity(0.25)),
                  ),
                ),

                // Border of the cutout with animated outer glow
                Positioned.fill(
                  child: CustomPaint(
                    painter: _CutoutBorderPainter(
                      cutOutRect: cutOutRect,
                      radius: 16,
                      glowT: t,
                    ),
                  ),
                ),

                // Torch button in top right corner
                Positioned(
                  top: cutOutTop + 16,
                  right: (constraints.maxWidth - cutOutRect.right) + 16,
                  child: _CircleButton(
                    icon: Icons.flash_on_rounded,
                    onTap: widget.onToggleTorch,
                    isDark: true,
                  ),
                ),

                // Hint text under the square
                Positioned(
                  top: cutOutTop + cutOutSize + 16,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      'Apunta al código QR del ticket',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: res.dp(1.6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                // Processing overlay
                if (widget.processing)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 36,
                              height: 36,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(
                                  Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Validando QR…',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: res.dp(1.6),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

class _OutsideHoleClipper extends CustomClipper<Path> {
  final Rect holeRect;
  final double radius;

  _OutsideHoleClipper({required this.holeRect, required this.radius});

  @override
  Path getClip(Size size) {
    final full = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final hole = Path()
      ..addRRect(RRect.fromRectAndRadius(holeRect, Radius.circular(radius)));
    return Path.combine(PathOperation.difference, full, hole);
  }

  @override
  bool shouldReclip(covariant _OutsideHoleClipper oldClipper) {
    return oldClipper.holeRect != holeRect || oldClipper.radius != radius;
  }
}

class _CutoutBorderPainter extends CustomPainter {
  final Rect cutOutRect;
  final double radius;
  final double glowT; // 0..1 animation value

  _CutoutBorderPainter({
    required this.cutOutRect,
    required this.radius,
    required this.glowT,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(cutOutRect, Radius.circular(radius));

    // Solid border
    final border = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(rrect, border);

    // Animated outer glow
    final glowOpacity = 0.25 + 0.25 * glowT; // 0.25..0.5
    final sigma = 6.0 + 10.0 * glowT; // blur strength 6..16
    final glow = Paint()
      ..color = Colors.white.withOpacity(glowOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, sigma);

    final full = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final hole = Path()..addRRect(rrect);
    final outside = Path.combine(PathOperation.difference, full, hole);

    canvas.save();
    canvas.clipPath(outside);
    canvas.drawRRect(rrect, glow);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CutoutBorderPainter oldDelegate) {
    return oldDelegate.cutOutRect != cutOutRect ||
        oldDelegate.radius != radius ||
        oldDelegate.glowT != glowT;
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;

  const _CircleButton({
    required this.icon,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.15),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.all(10),
          child: Icon(Icons.flash_on_rounded, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}
