import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:bombotickets/features/shared/utils/responsive.dart';
import 'package:bombotickets/config/theme/app_theme_new.dart';
import 'package:bombotickets/features/shared/widgets/app_card.dart';
import 'package:bombotickets/features/shared/widgets/gradient_background.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';

// Custom clipper para el overlay del escáner
class ScannerOverlayClipper extends CustomClipper<Path> {
  final double scanAreaSize;
  final double borderRadius;

  ScannerOverlayClipper({
    required this.scanAreaSize,
    required this.borderRadius,
  });

  @override
  Path getClip(Size size) {
    final path = Path();

    // Área completa
    path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Área de escaneo (agujero en el centro)
    final scanAreaRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: scanAreaSize,
      height: scanAreaSize,
    );

    final scanAreaPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(scanAreaRect, Radius.circular(borderRadius)),
      );

    // Restar el área de escaneo del área total
    return Path.combine(PathOperation.difference, path, scanAreaPath);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// Provider para manejar el estado del escáner de tickets
final ticketScannerProvider =
    StateNotifierProvider<TicketScannerNotifier, TicketScannerState>((ref) {
      return TicketScannerNotifier();
    });

class TicketScannerState {
  final String? lastScannedTicket;
  final DateTime? scanTime;
  final bool isFlashOn;
  final List<ScannedTicketHistory> history;

  TicketScannerState({
    this.lastScannedTicket,
    this.scanTime,
    this.isFlashOn = false,
    this.history = const [],
  });

  TicketScannerState copyWith({
    String? lastScannedTicket,
    DateTime? scanTime,
    bool? isFlashOn,
    List<ScannedTicketHistory>? history,
  }) {
    return TicketScannerState(
      lastScannedTicket: lastScannedTicket,
      scanTime: scanTime,
      isFlashOn: isFlashOn ?? this.isFlashOn,
      history: history ?? this.history,
    );
  }
}

class ScannedTicketHistory {
  final String ticketData;
  final DateTime scanTime;
  final TicketType type;

  ScannedTicketHistory({
    required this.ticketData,
    required this.scanTime,
    required this.type,
  });
}

enum TicketType { bomboticket, event, concert, other }

class TicketScannerNotifier extends StateNotifier<TicketScannerState> {
  TicketScannerNotifier() : super(TicketScannerState());

  void onTicketScanned(String ticketData) {
    final now = DateTime.now();
    final type = _determineTicketType(ticketData);

    final newHistory = ScannedTicketHistory(
      ticketData: ticketData,
      scanTime: now,
      type: type,
    );

    state = state.copyWith(
      lastScannedTicket: ticketData,
      scanTime: now,
      history: [newHistory, ...state.history.take(19).toList()],
    );
  }

  TicketType _determineTicketType(String data) {
    if (data.startsWith('BOMBO_TICKET_') || data.contains('bombotickets')) {
      return TicketType.bomboticket;
    } else if (data.contains('EVENT_') || data.contains('event')) {
      return TicketType.event;
    } else if (data.contains('CONCERT_') || data.contains('concert')) {
      return TicketType.concert;
    } else {
      return TicketType.other;
    }
  }

  void toggleFlash() {
    state = state.copyWith(isFlashOn: !state.isFlashOn);
  }

  void clearHistory() {
    state = state.copyWith(history: []);
  }
}

class TicketScannerScreen extends ConsumerStatefulWidget {
  const TicketScannerScreen({super.key});

  @override
  ConsumerState<TicketScannerScreen> createState() =>
      _TicketScannerScreenState();
}

class _TicketScannerScreenState extends ConsumerState<TicketScannerScreen> {
  MobileScannerController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final res = Responsive.of(context);
    final theme = Theme.of(context);
    final scannerState = ref.watch(ticketScannerProvider);

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // Header personalizado
              Container(
                padding: EdgeInsets.all(AppTheme.spacingMedium),
                child: Row(
                  children: [
                    Material(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(
                        AppTheme.borderRadiusLarge,
                      ),
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(
                          AppTheme.borderRadiusLarge,
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(AppTheme.spacingNormal),
                          child: Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                            size: res.dp(2.4),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: AppTheme.spacingMedium),
                    Expanded(
                      child: AutoSizeText(
                        'Escáner de Tickets',
                        style: GoogleFonts.poppins(
                          fontSize: AppTheme.fontSizeH2,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                      ),
                    ),
                    Material(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(
                        AppTheme.borderRadiusLarge,
                      ),
                      child: InkWell(
                        onTap: () {
                          _controller?.toggleTorch();
                          ref
                              .read(ticketScannerProvider.notifier)
                              .toggleFlash();
                        },
                        borderRadius: BorderRadius.circular(
                          AppTheme.borderRadiusLarge,
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(AppTheme.spacingNormal),
                          child: Icon(
                            ref.watch(ticketScannerProvider).isFlashOn
                                ? Icons.flash_on_rounded
                                : Icons.flash_off_rounded,
                            color: Colors.white,
                            size: res.dp(2.4),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: AppTheme.spacingSmall),
                    Material(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(
                        AppTheme.borderRadiusLarge,
                      ),
                      child: InkWell(
                        onTap: () =>
                            _showHistoryBottomSheet(context, res, theme),
                        borderRadius: BorderRadius.circular(
                          AppTheme.borderRadiusLarge,
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(AppTheme.spacingNormal),
                          child: Icon(
                            Icons.history_rounded,
                            color: Colors.white,
                            size: res.dp(2.4),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Contenido con scroll
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      SizedBox(height: AppTheme.spacingMedium),

                      // Scanner Area
                      Container(
                        height: res.hp(55),
                        margin: EdgeInsets.all(AppTheme.spacingNormal),
                        child: _buildScannerArea(res, theme),
                      ),

                      // Inner text removed; detailed instructions card is shown below

                      // Last Scanned Ticket Info
                      if (scannerState.lastScannedTicket != null)
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: res.hp(15),
                            maxHeight: res.hp(25),
                          ),
                          child: _buildTicketInfo(res, theme, scannerState),
                        ),

                      // Instructions
                      _buildInstructions(res, theme),

                      SizedBox(height: AppTheme.spacingLarge),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScannerArea(Responsive res, ThemeData theme) {
    return Container(
      margin: EdgeInsets.all(AppTheme.spacingNormal),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        child: Stack(
          children: [
            // Scanner
            MobileScanner(
              controller: _controller,
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  if (barcode.rawValue != null &&
                      barcode.rawValue!.isNotEmpty) {
                    HapticFeedback.mediumImpact();

                    ref
                        .read(ticketScannerProvider.notifier)
                        .onTicketScanned(barcode.rawValue!);

                    MotionToast.success(
                      title: const Text('Ticket Escaneado'),
                      description: const Text('Ticket detectado exitosamente'),
                      toastDuration: const Duration(seconds: 3),
                      width: 300,
                    ).show(context);
                    break;
                  }
                }
              },
            ),

            // Scanner Overlay mejorado
            _buildScannerOverlay(res, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildScannerOverlay(Responsive res, ThemeData theme) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        ),
        child: Stack(
          children: [
            // Overlay oscuro con recorte
            ClipPath(
              clipper: ScannerOverlayClipper(
                scanAreaSize: res.wp(70),
                borderRadius: AppTheme.borderRadiusNormal,
              ),
              child: Container(color: Colors.black.withOpacity(0.7)),
            ),

            // Área de escaneo con borde brillante
            Center(
              child: Container(
                width: res.wp(70),
                height: res.wp(70),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.8),
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(
                    AppTheme.borderRadiusNormal,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Esquinas animadas
                    _buildAnimatedCorner(res, isTopLeft: true),
                    _buildAnimatedCorner(res, isTopRight: true),
                    _buildAnimatedCorner(res, isBottomLeft: true),
                    _buildAnimatedCorner(res, isBottomRight: true),
                  ],
                ),
              ),
            ),

            // Scan line and inner text removed (instructions shown below camera)
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedCorner(
    Responsive res, {
    bool isTopLeft = false,
    bool isTopRight = false,
    bool isBottomLeft = false,
    bool isBottomRight = false,
  }) {
    return Positioned(
          top: isTopLeft || isTopRight ? -1.5 : null,
          bottom: isBottomLeft || isBottomRight ? -1.5 : null,
          left: isTopLeft || isBottomLeft ? -1.5 : null,
          right: isTopRight || isBottomRight ? -1.5 : null,
          child: Container(
            width: res.wp(8),
            height: res.wp(8),
            decoration: BoxDecoration(
              border: Border(
                top: (isTopLeft || isTopRight)
                    ? BorderSide(color: Colors.white, width: 4)
                    : BorderSide.none,
                bottom: (isBottomLeft || isBottomRight)
                    ? BorderSide(color: Colors.white, width: 4)
                    : BorderSide.none,
                left: (isTopLeft || isBottomLeft)
                    ? BorderSide(color: Colors.white, width: 4)
                    : BorderSide.none,
                right: (isTopRight || isBottomRight)
                    ? BorderSide(color: Colors.white, width: 4)
                    : BorderSide.none,
              ),
            ),
          ),
        )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(duration: 2000.ms, color: Colors.white.withOpacity(0.5));
  }

  Widget _buildScanLine(Responsive res) {
    return ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusNormal),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  AppTheme.primaryColor.withOpacity(0.3),
                  AppTheme.primaryColor.withOpacity(0.7),
                  AppTheme.primaryColor.withOpacity(0.3),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.4, 0.5, 0.6, 1.0],
              ),
            ),
            height: 3,
            margin: EdgeInsets.symmetric(horizontal: AppTheme.spacingSmall),
          ),
        )
        .animate(onPlay: (controller) => controller.repeat())
        .moveY(
          begin: -res.wp(30),
          end: res.wp(30),
          duration: 2000.ms,
          curve: Curves.easeInOut,
        );
  }

  Widget _buildTicketInfo(
    Responsive res,
    ThemeData theme,
    TicketScannerState state,
  ) {
    if (state.lastScannedTicket == null) return const SizedBox.shrink();

    final ticketData = state.lastScannedTicket!;
    final scanTime = state.scanTime!;

    return AppCard(
      margin: EdgeInsets.all(AppTheme.spacingNormal),
      padding: EdgeInsets.all(AppTheme.spacingNormal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.confirmation_number_rounded,
                color: AppTheme.primaryColor,
                size: res.dp(3),
              ),
              SizedBox(width: AppTheme.spacingSmall),
              Expanded(
                child: AutoSizeText(
                  'Último ticket escaneado',
                  style: GoogleFonts.poppins(
                    fontSize: AppTheme.fontSizeBodyLarge,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.bodyFontColor,
                  ),
                  maxLines: 1,
                ),
              ),
            ],
          ),

          SizedBox(height: AppTheme.spacingSmall),

          AutoSizeText(
            '${scanTime.day}/${scanTime.month}/${scanTime.year} - ${scanTime.hour.toString().padLeft(2, '0')}:${scanTime.minute.toString().padLeft(2, '0')}',
            style: GoogleFonts.inter(
              fontSize: AppTheme.fontSizeBodyNormal,
              color: AppTheme.grey1,
            ),
            maxLines: 1,
          ),

          SizedBox(height: AppTheme.spacingSmall),

          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppTheme.spacingSmall),
            decoration: BoxDecoration(
              color: AppTheme.greyInputBg,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
            ),
            child: SelectableText(
              ticketData,
              style: GoogleFonts.sourceCodePro(
                fontSize: AppTheme.fontSizeBodyNormal,
                color: AppTheme.bodyFontColor,
              ),
            ),
          ),

          SizedBox(height: AppTheme.spacingNormal),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: ticketData));
                    MotionToast.success(
                      title: const Text('Copiado'),
                      description: const Text('Ticket copiado al portapapeles'),
                      toastDuration: const Duration(seconds: 2),
                      width: 300,
                    ).show(context);
                  },
                  icon: const Icon(Icons.copy_rounded),
                  label: AutoSizeText(
                    'Copiar',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    maxLines: 1,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppTheme.borderRadiusSmall,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(width: AppTheme.spacingSmall),

              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _validateTicket(ticketData),
                  icon: const Icon(Icons.verified_rounded),
                  label: AutoSizeText(
                    'Validar',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    maxLines: 1,
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    side: const BorderSide(color: AppTheme.primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppTheme.borderRadiusSmall,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.3);
  }

  Widget _buildInstructions(Responsive res, ThemeData theme) {
    return AppCard(
      margin: EdgeInsets.all(AppTheme.spacingNormal),
      padding: EdgeInsets.all(AppTheme.spacingNormal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppTheme.primaryColor,
                size: res.dp(2.5),
              ),
              SizedBox(width: AppTheme.spacingSmall),
              AutoSizeText(
                'Instrucciones para escanear tickets',
                style: GoogleFonts.poppins(
                  fontSize: AppTheme.fontSizeBodyLarge,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.bodyFontColor,
                ),
                maxLines: 1,
              ),
            ],
          ),

          SizedBox(height: AppTheme.spacingSmall),

          _buildInstructionItem(
            '1. Mantén la cámara estable',
            'Apunta directamente al código QR del ticket',
            Icons.camera_alt_rounded,
          ),

          _buildInstructionItem(
            '2. Asegúrate de tener buena iluminación',
            'Usa el flash si es necesario',
            Icons.wb_sunny_rounded,
          ),

          _buildInstructionItem(
            '3. Mantén una distancia adecuada',
            'Ni muy cerca ni muy lejos del código',
            Icons.zoom_out_map_rounded,
          ),

          _buildInstructionItem(
            '4. Verifica la validez del ticket',
            'Usa el botón "Validar" después de escanear',
            Icons.verified_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(String title, String subtitle, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppTheme.spacingSmall / 2),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.grey1, size: 20),
          SizedBox(width: AppTheme.spacingSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoSizeText(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: AppTheme.fontSizeBodyNormal,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.bodyFontColor,
                  ),
                  maxLines: 1,
                ),
                AutoSizeText(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: AppTheme.fontSizeBodyNormal,
                    color: AppTheme.grey1,
                  ),
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _validateTicket(String ticketData) {
    final type = ref
        .read(ticketScannerProvider.notifier)
        ._determineTicketType(ticketData);

    // TODO: Implementar validación real con backend
    MotionToast.success(
      title: const Text('Ticket Válido'),
      description: Text('Tipo: ${type.name.toUpperCase()}'),
      toastDuration: const Duration(seconds: 3),
      width: 300,
    ).show(context);
  }

  void _showHistoryBottomSheet(
    BuildContext context,
    Responsive res,
    ThemeData theme,
  ) {
    final history = ref.read(ticketScannerProvider).history;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: res.hp(70),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppTheme.borderRadiusLarge),
          ),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: EdgeInsets.symmetric(vertical: AppTheme.spacingSmall),
              width: res.wp(12),
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.grey1,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: EdgeInsets.all(AppTheme.spacingNormal),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AutoSizeText(
                    'Historial de Tickets',
                    style: GoogleFonts.poppins(
                      fontSize: AppTheme.fontSizeH3,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                  ),
                  if (history.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        ref.read(ticketScannerProvider.notifier).clearHistory();
                        Navigator.pop(context);
                      },
                      child: AutoSizeText(
                        'Limpiar',
                        style: GoogleFonts.inter(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                      ),
                    ),
                ],
              ),
            ),

            // History list
            Expanded(
              child: history.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.confirmation_number_rounded,
                            size: res.dp(8),
                            color: AppTheme.grey1,
                          ),
                          SizedBox(height: AppTheme.spacingNormal),
                          AutoSizeText(
                            'No hay tickets escaneados',
                            style: GoogleFonts.inter(
                              fontSize: AppTheme.fontSizeBodyLarge,
                              color: AppTheme.grey1,
                            ),
                            maxLines: 1,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingNormal,
                      ),
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final item = history[index];
                        return _buildHistoryItem(item, res, theme);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(
    ScannedTicketHistory item,
    Responsive res,
    ThemeData theme,
  ) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: AppTheme.spacingSmall / 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
      ),
      child: ListTile(
        leading: Icon(
          _getIconForTicketType(item.type),
          color: AppTheme.primaryColor,
        ),
        title: AutoSizeText(
          item.ticketData.length > 30
              ? '${item.ticketData.substring(0, 30)}...'
              : item.ticketData,
          style: GoogleFonts.inter(
            fontSize: AppTheme.fontSizeBodyNormal,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
        ),
        subtitle: AutoSizeText(
          '${item.scanTime.day}/${item.scanTime.month}/${item.scanTime.year} - ${item.scanTime.hour.toString().padLeft(2, '0')}:${item.scanTime.minute.toString().padLeft(2, '0')}',
          style: GoogleFonts.inter(
            fontSize: AppTheme.fontSizeBodyNormal,
            color: AppTheme.grey1,
          ),
          maxLines: 1,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.copy_rounded),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: item.ticketData));
            MotionToast.success(
              title: const Text('Copiado'),
              description: const Text('Ticket copiado al portapapeles'),
              toastDuration: const Duration(seconds: 2),
              width: 300,
            ).show(context);
          },
        ),
        onTap: () {
          // Reutilizar el ticket del historial
          ref
              .read(ticketScannerProvider.notifier)
              .onTicketScanned(item.ticketData);
          Navigator.pop(context);
        },
      ),
    );
  }

  IconData _getIconForTicketType(TicketType type) {
    switch (type) {
      case TicketType.bomboticket:
        return Icons.local_activity_rounded;
      case TicketType.event:
        return Icons.event_rounded;
      case TicketType.concert:
        return Icons.music_note_rounded;
      case TicketType.other:
        return Icons.qr_code_rounded;
    }
  }
}

// Widget de contenido para usar en el PageView del MainLayout
class QRScannerContent extends ConsumerWidget {
  final bool showAppBar;

  const QRScannerContent({super.key, this.showAppBar = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (showAppBar) {
      return const TicketScannerScreen();
    } else {
      // Versión sin AppBar para el PageView
      return const TicketScannerScreenContent();
    }
  }
}

class TicketScannerScreenContent extends ConsumerStatefulWidget {
  const TicketScannerScreenContent({super.key});

  @override
  ConsumerState<TicketScannerScreenContent> createState() =>
      _TicketScannerScreenContentState();
}

class _TicketScannerScreenContentState
    extends ConsumerState<TicketScannerScreenContent> {
  MobileScannerController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final res = Responsive.of(context);
    final theme = Theme.of(context);
    final scannerState = ref.watch(ticketScannerProvider);

    return GradientBackground(
      child: SafeArea(
        child: Column(
          children: [
            // Header moderno con glassmorphism
            Container(
              padding: EdgeInsets.all(AppTheme.spacingNormal),
              margin: EdgeInsets.all(AppTheme.spacingNormal),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AutoSizeText(
                          'Escáner QR',
                          style: GoogleFonts.poppins(
                            fontSize: AppTheme.fontSizeH3,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                        ),
                        SizedBox(height: AppTheme.spacingSmall / 2),
                        AutoSizeText(
                          'Escanea tickets rápidamente',
                          style: GoogleFonts.inter(
                            fontSize: AppTheme.fontSizeBodyNormal,
                            color: Colors.white.withOpacity(0.8),
                          ),
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      // Flash button con estilo moderno
                      Container(
                        decoration: BoxDecoration(
                          color: scannerState.isFlashOn
                              ? Colors.white.withOpacity(0.3)
                              : Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            AppTheme.borderRadiusNormal,
                          ),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: IconButton(
                          icon: Icon(
                            scannerState.isFlashOn
                                ? Icons.flash_on_rounded
                                : Icons.flash_off_rounded,
                            color: Colors.white,
                            size: res.dp(2.5),
                          ),
                          onPressed: () {
                            _controller?.toggleTorch();
                            ref
                                .read(ticketScannerProvider.notifier)
                                .toggleFlash();
                          },
                        ),
                      ),
                      SizedBox(width: AppTheme.spacingSmall),
                      // History button
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            AppTheme.borderRadiusNormal,
                          ),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.history_rounded,
                            color: Colors.white,
                            size: res.dp(2.5),
                          ),
                          onPressed: () =>
                              _showHistoryBottomSheet(context, res, theme),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Contenido expandible con scanner moderno
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // Scanner Area moderno
                    Container(
                      height: res.hp(50),
                      margin: EdgeInsets.all(AppTheme.spacingNormal),
                      child: _buildModernScannerArea(res, theme),
                    ),

                    // Inner instructions moved below camera
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingNormal,
                      ),
                      child: Text(
                        'Mantén el QR en el área marcada. El escaneo se realizará automáticamente',
                        style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: AppTheme.fontSizeBodyNormal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    // Stats rápidas
                    _buildQuickStats(res, theme, scannerState),

                    // Last Scanned Ticket Info
                    if (scannerState.lastScannedTicket != null)
                      _buildModernTicketInfo(res, theme, scannerState),

                    SizedBox(height: AppTheme.spacingLarge),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reutilizar los métodos de TicketScannerScreen
  Widget _buildScannerArea(Responsive res, ThemeData theme) {
    return Container(
      margin: EdgeInsets.all(AppTheme.spacingNormal),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        child: Stack(
          children: [
            MobileScanner(
              controller: _controller,
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  if (barcode.rawValue != null &&
                      barcode.rawValue!.isNotEmpty) {
                    HapticFeedback.mediumImpact();

                    ref
                        .read(ticketScannerProvider.notifier)
                        .onTicketScanned(barcode.rawValue!);

                    MotionToast.success(
                      title: const Text('Ticket Escaneado'),
                      description: const Text('Ticket detectado exitosamente'),
                      toastDuration: const Duration(seconds: 3),
                      width: 300,
                    ).show(context);
                    break;
                  }
                }
              },
            ),
            _buildScannerOverlay(res, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildScannerOverlay(Responsive res, ThemeData theme) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        ),
        child: Stack(
          children: [
            Center(
              child: Container(
                width: res.wp(60),
                height: res.wp(60),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(
                    AppTheme.borderRadiusNormal,
                  ),
                  color: Colors.transparent,
                ),
              ),
            ),
            Positioned(
              bottom: res.hp(5),
              left: 0,
              right: 0,
              child: Center(
                child: AutoSizeText(
                  'Apunta la cámara al código QR del ticket',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: AppTheme.fontSizeBodyNormal,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketInfo(
    Responsive res,
    ThemeData theme,
    TicketScannerState state,
  ) {
    if (state.lastScannedTicket == null) return const SizedBox.shrink();

    final ticketData = state.lastScannedTicket!;

    return AppCard(
      margin: EdgeInsets.all(AppTheme.spacingNormal),
      padding: EdgeInsets.all(AppTheme.spacingSmall),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.confirmation_number_rounded,
                color: AppTheme.primaryColor,
                size: res.dp(2.5),
              ),
              SizedBox(width: AppTheme.spacingSmall),
              Expanded(
                child: AutoSizeText(
                  'Ticket escaneado',
                  style: GoogleFonts.poppins(
                    fontSize: AppTheme.fontSizeBodyNormal,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.bodyFontColor,
                  ),
                  maxLines: 1,
                ),
              ),
            ],
          ),

          SizedBox(height: AppTheme.spacingSmall / 2),

          AutoSizeText(
            ticketData.length > 40
                ? '${ticketData.substring(0, 40)}...'
                : ticketData,
            style: GoogleFonts.sourceCodePro(
              fontSize: AppTheme.fontSizeBodyNormal,
              color: AppTheme.grey1,
            ),
            maxLines: 1,
          ),

          SizedBox(height: AppTheme.spacingSmall),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: ticketData));
                    MotionToast.success(
                      title: const Text('Copiado'),
                      description: const Text('Ticket copiado'),
                      toastDuration: const Duration(seconds: 2),
                      width: 250,
                    ).show(context);
                  },
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  label: AutoSizeText(
                    'Copiar',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: AppTheme.fontSizeBodyNormal,
                    ),
                    maxLines: 1,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingSmall,
                      vertical: AppTheme.spacingSmall / 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppTheme.borderRadiusSmall,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.3);
  }

  void _showHistoryBottomSheet(
    BuildContext context,
    Responsive res,
    ThemeData theme,
  ) {
    final history = ref.read(ticketScannerProvider).history;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: res.hp(60),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppTheme.borderRadiusLarge),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: AppTheme.spacingSmall),
              width: res.wp(12),
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.grey1,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(AppTheme.spacingNormal),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AutoSizeText(
                    'Historial',
                    style: GoogleFonts.poppins(
                      fontSize: AppTheme.fontSizeH3,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                  ),
                  if (history.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        ref.read(ticketScannerProvider.notifier).clearHistory();
                        Navigator.pop(context);
                      },
                      child: AutoSizeText(
                        'Limpiar',
                        style: GoogleFonts.inter(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                      ),
                    ),
                ],
              ),
            ),

            Expanded(
              child: history.isEmpty
                  ? Center(
                      child: AutoSizeText(
                        'No hay tickets escaneados',
                        style: GoogleFonts.inter(
                          fontSize: AppTheme.fontSizeBodyLarge,
                          color: AppTheme.grey1,
                        ),
                        maxLines: 1,
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingNormal,
                      ),
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final item = history[index];
                        return Card(
                          margin: EdgeInsets.symmetric(
                            vertical: AppTheme.spacingSmall / 2,
                          ),
                          child: ListTile(
                            leading: Icon(
                              Icons.confirmation_number_rounded,
                              color: AppTheme.primaryColor,
                            ),
                            title: AutoSizeText(
                              item.ticketData.length > 25
                                  ? '${item.ticketData.substring(0, 25)}...'
                                  : item.ticketData,
                              style: GoogleFonts.inter(
                                fontSize: AppTheme.fontSizeBodyNormal,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                            ),
                            subtitle: AutoSizeText(
                              '${item.scanTime.day}/${item.scanTime.month} - ${item.scanTime.hour.toString().padLeft(2, '0')}:${item.scanTime.minute.toString().padLeft(2, '0')}',
                              style: GoogleFonts.inter(
                                fontSize: AppTheme.fontSizeBodyNormal,
                                color: AppTheme.grey1,
                              ),
                              maxLines: 1,
                            ),
                            onTap: () {
                              ref
                                  .read(ticketScannerProvider.notifier)
                                  .onTicketScanned(item.ticketData);
                              Navigator.pop(context);
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Métodos modernos para el escáner
  Widget _buildModernScannerArea(Responsive res, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        child: Stack(
          children: [
            // Scanner
            MobileScanner(
              controller: _controller,
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  if (barcode.rawValue != null &&
                      barcode.rawValue!.isNotEmpty) {
                    HapticFeedback.mediumImpact();

                    ref
                        .read(ticketScannerProvider.notifier)
                        .onTicketScanned(barcode.rawValue!);

                    MotionToast.success(
                      title: const Text('¡Ticket Escaneado!'),
                      description: const Text('Ticket detectado exitosamente'),
                      toastDuration: const Duration(seconds: 3),
                      width: 300,
                    ).show(context);
                    break;
                  }
                }
              },
            ),

            // Modern overlay con animaciones
            _buildModernScannerOverlay(res, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildModernScannerOverlay(Responsive res, ThemeData theme) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        ),
        child: Stack(
          children: [
            // Overlay oscuro con recorte
            ClipPath(
              clipper: ScannerOverlayClipper(
                scanAreaSize: res.wp(65),
                borderRadius: AppTheme.borderRadiusNormal,
              ),
              child: Container(color: Colors.black.withOpacity(0.7)),
            ),

            // Área de escaneo con efectos modernos
            Center(
              child: Container(
                width: res.wp(65),
                height: res.wp(65),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 3),
                  borderRadius: BorderRadius.circular(
                    AppTheme.borderRadiusNormal,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Esquinas con animación pulso
                    _buildModernCorner(res, isTopLeft: true),
                    _buildModernCorner(res, isTopRight: true),
                    _buildModernCorner(res, isBottomLeft: true),
                    _buildModernCorner(res, isBottomRight: true),

                    // Líneas de escaneo múltiples
                    _buildMultipleScanLines(res),
                  ],
                ),
              ),
            ),

            // Inner instructions moved below camera viewer
          ],
        ),
      ),
    );
  }

  Widget _buildModernCorner(
    Responsive res, {
    bool isTopLeft = false,
    bool isTopRight = false,
    bool isBottomLeft = false,
    bool isBottomRight = false,
  }) {
    return Positioned(
          top: isTopLeft || isTopRight ? -2 : null,
          bottom: isBottomLeft || isBottomRight ? -2 : null,
          left: isTopLeft || isBottomLeft ? -2 : null,
          right: isTopRight || isBottomRight ? -2 : null,
          child: Container(
            width: res.wp(10),
            height: res.wp(10),
            decoration: BoxDecoration(
              border: Border(
                top: (isTopLeft || isTopRight)
                    ? const BorderSide(color: Colors.white, width: 5)
                    : BorderSide.none,
                bottom: (isBottomLeft || isBottomRight)
                    ? const BorderSide(color: Colors.white, width: 5)
                    : BorderSide.none,
                left: (isTopLeft || isBottomLeft)
                    ? const BorderSide(color: Colors.white, width: 5)
                    : BorderSide.none,
                right: (isTopRight || isBottomRight)
                    ? const BorderSide(color: Colors.white, width: 5)
                    : BorderSide.none,
              ),
            ),
          ),
        )
        .animate(onPlay: (controller) => controller.repeat())
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.2, 1.2),
          duration: 1500.ms,
          curve: Curves.easeInOut,
        )
        .then()
        .scale(
          begin: const Offset(1.2, 1.2),
          end: const Offset(0.8, 0.8),
          duration: 1500.ms,
          curve: Curves.easeInOut,
        );
  }

  Widget _buildMultipleScanLines(Responsive res) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.borderRadiusNormal),
      child: Stack(
        children: [
          // Línea principal
          Container(
                width: double.infinity,
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.white.withOpacity(0.3),
                      Colors.white,
                      Colors.white.withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              )
              .animate(onPlay: (controller) => controller.repeat())
              .moveY(
                begin: -res.wp(30),
                end: res.wp(30),
                duration: 2500.ms,
                curve: Curves.easeInOut,
              ),

          // Línea secundaria
          Container(
                width: double.infinity,
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.white.withOpacity(0.5),
                      Colors.white,
                      Colors.white.withOpacity(0.5),
                      Colors.transparent,
                    ],
                  ),
                ),
              )
              .animate(onPlay: (controller) => controller.repeat())
              .moveY(
                begin: res.wp(30),
                end: -res.wp(30),
                duration: 3000.ms,
                curve: Curves.easeInOut,
              ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(
    Responsive res,
    ThemeData theme,
    TicketScannerState state,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppTheme.spacingNormal),
      padding: EdgeInsets.all(AppTheme.spacingNormal),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              'Escaneados Hoy',
              '${state.history.length}',
              Icons.qr_code_scanner_rounded,
              res,
            ),
          ),
          Container(
            width: 1,
            height: res.hp(5),
            color: Colors.white.withOpacity(0.3),
          ),
          Expanded(
            child: _buildStatItem(
              'Último Escaneo',
              state.scanTime != null
                  ? '${state.scanTime!.hour.toString().padLeft(2, '0')}:${state.scanTime!.minute.toString().padLeft(2, '0')}'
                  : '--:--',
              Icons.access_time_rounded,
              res,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Responsive res,
  ) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.7), size: res.dp(2.5)),
        SizedBox(height: AppTheme.spacingSmall / 2),
        AutoSizeText(
          value,
          style: GoogleFonts.poppins(
            fontSize: AppTheme.fontSizeH3,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          maxLines: 1,
        ),
        AutoSizeText(
          label,
          style: GoogleFonts.inter(
            fontSize: AppTheme.fontSizeBodyNormal,
            color: Colors.white.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
        ),
      ],
    );
  }

  Widget _buildModernTicketInfo(
    Responsive res,
    ThemeData theme,
    TicketScannerState state,
  ) {
    if (state.lastScannedTicket == null) return const SizedBox.shrink();

    final ticketData = state.lastScannedTicket!;
    final scanTime = state.scanTime!;

    return Container(
          margin: EdgeInsets.all(AppTheme.spacingNormal),
          padding: EdgeInsets.all(AppTheme.spacingNormal),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(AppTheme.spacingSmall),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(
                        AppTheme.borderRadiusNormal,
                      ),
                    ),
                    child: Icon(
                      Icons.confirmation_number_rounded,
                      color: Colors.white,
                      size: res.dp(2.5),
                    ),
                  ),
                  SizedBox(width: AppTheme.spacingSmall),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AutoSizeText(
                          'Ticket Escaneado',
                          style: GoogleFonts.poppins(
                            fontSize: AppTheme.fontSizeBodyLarge,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                        ),
                        AutoSizeText(
                          '${scanTime.day}/${scanTime.month}/${scanTime.year} - ${scanTime.hour.toString().padLeft(2, '0')}:${scanTime.minute.toString().padLeft(2, '0')}',
                          style: GoogleFonts.inter(
                            fontSize: AppTheme.fontSizeBodyNormal,
                            color: Colors.white.withOpacity(0.7),
                          ),
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: AppTheme.spacingNormal),

              Container(
                width: double.infinity,
                padding: EdgeInsets.all(AppTheme.spacingNormal),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(
                    AppTheme.borderRadiusSmall,
                  ),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: SelectableText(
                  ticketData,
                  style: GoogleFonts.sourceCodePro(
                    fontSize: AppTheme.fontSizeBodyNormal,
                    color: Colors.white,
                  ),
                ),
              ),

              SizedBox(height: AppTheme.spacingNormal),

              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.2),
                            Colors.white.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(
                          AppTheme.borderRadiusNormal,
                        ),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: ticketData));
                            MotionToast.success(
                              title: const Text('Copiado'),
                              description: const Text(
                                'Ticket copiado al portapapeles',
                              ),
                              toastDuration: const Duration(seconds: 2),
                              width: 300,
                            ).show(context);
                          },
                          borderRadius: BorderRadius.circular(
                            AppTheme.borderRadiusNormal,
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(AppTheme.spacingNormal),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.copy_rounded,
                                  color: Colors.white,
                                  size: res.dp(2),
                                ),
                                SizedBox(width: AppTheme.spacingSmall),
                                AutoSizeText(
                                  'Copiar',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: AppTheme.spacingSmall),

                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryColor.withOpacity(0.8),
                            AppTheme.primaryColor.withOpacity(0.6),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(
                          AppTheme.borderRadiusNormal,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _validateTicket(ticketData),
                          borderRadius: BorderRadius.circular(
                            AppTheme.borderRadiusNormal,
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(AppTheme.spacingNormal),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.verified_rounded,
                                  color: Colors.white,
                                  size: res.dp(2),
                                ),
                                SizedBox(width: AppTheme.spacingSmall),
                                AutoSizeText(
                                  'Validar',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.3)
        .shimmer(duration: 1000.ms, color: Colors.white.withOpacity(0.1));
  }

  void _validateTicket(String ticketData) {
    // TODO: Implementar validación real con backend
    MotionToast.success(
      title: const Text('Ticket Válido ✅'),
      description: const Text('El ticket ha sido validado correctamente'),
      toastDuration: const Duration(seconds: 3),
      width: 300,
    ).show(context);
  }
}
