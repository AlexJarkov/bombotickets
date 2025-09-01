import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:bombotickets/features/shared/utils/responsive.dart';
import 'package:bombotickets/config/theme/theme.dart';
import 'package:bombotickets/features/shared/widgets/app_card.dart';
import 'package:bombotickets/features/shared/widgets/app_toast.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

// Provider para manejar el estado del scanner
final qrScannerProvider =
    StateNotifierProvider<QRScannerNotifier, QRScannerState>((ref) {
      return QRScannerNotifier();
    });

class QRScannerState {
  final String? lastScannedQR;
  final DateTime? scanTime;
  final bool isFlashOn;
  final List<ScannedQRHistory> history;

  QRScannerState({
    this.lastScannedQR,
    this.scanTime,
    this.isFlashOn = false,
    this.history = const [],
  });

  QRScannerState copyWith({
    String? lastScannedQR,
    DateTime? scanTime,
    bool? isFlashOn,
    List<ScannedQRHistory>? history,
  }) {
    return QRScannerState(
      lastScannedQR: lastScannedQR,
      scanTime: scanTime,
      isFlashOn: isFlashOn ?? this.isFlashOn,
      history: history ?? this.history,
    );
  }
}

class ScannedQRHistory {
  final String qrData;
  final DateTime scanTime;
  final QRType type;

  ScannedQRHistory({
    required this.qrData,
    required this.scanTime,
    required this.type,
  });
}

enum QRType { url, text, wifi, email, phone, other }

class QRScannerNotifier extends StateNotifier<QRScannerState> {
  QRScannerNotifier() : super(QRScannerState());

  void onQRScanned(String qrData) {
    final now = DateTime.now();
    final type = _determineQRType(qrData);

    final newHistory = ScannedQRHistory(
      qrData: qrData,
      scanTime: now,
      type: type,
    );

    state = state.copyWith(
      lastScannedQR: qrData,
      scanTime: now,
      history: [newHistory, ...state.history.take(19).toList()], // Keep last 20
    );
  }

  QRType _determineQRType(String data) {
    if (data.startsWith('http://') || data.startsWith('https://')) {
      return QRType.url;
    } else if (data.startsWith('WIFI:')) {
      return QRType.wifi;
    } else if (data.startsWith('mailto:')) {
      return QRType.email;
    } else if (data.startsWith('tel:')) {
      return QRType.phone;
    } else if (data.contains('@') && data.contains('.')) {
      return QRType.email;
    } else {
      return QRType.text;
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
    final scannerState = ref.watch(qrScannerProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Escáner QR',
          style: TextStyle(fontSize: res.dp(2.2), fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              scannerState.isFlashOn ? Icons.flash_on : Icons.flash_off,
            ),
            onPressed: () {
              _controller?.toggleTorch();
              ref.read(qrScannerProvider.notifier).toggleFlash();
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _showHistoryBottomSheet(context, res, theme),
          ),
        ],
      ),
      body: Column(
        children: [
          // Scanner Area
          Expanded(flex: 2, child: _buildScannerArea(res, theme)),

          // Last Scanned QR Info
          if (scannerState.lastScannedQR != null)
            Expanded(flex: 1, child: _buildQRInfo(res, theme, scannerState)),

          // Instructions
          _buildInstructions(res, theme),
        ],
      ),
    );
  }

  Widget _buildScannerArea(Responsive res, ThemeData theme) {
    return Container(
      margin: EdgeInsets.all(res.wp(4)),
      child: AppCard(
        padding: EdgeInsets.all(res.wp(2)),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(res.wp(3)),
              child: MobileScanner(
                controller: _controller,
                onDetect: (BarcodeCapture capture) {
                  final List<Barcode> barcodes = capture.barcodes;
                  for (final barcode in barcodes) {
                    if (barcode.rawValue != null &&
                        barcode.rawValue!.isNotEmpty) {
                      // Vibrate on successful scan
                      HapticFeedback.mediumImpact();

                      ref
                          .read(qrScannerProvider.notifier)
                          .onQRScanned(barcode.rawValue!);

                      AppToast.showSuccess(
                        context,
                        title: 'QR Escaneado',
                        description: 'Código QR detectado exitosamente',
                      );
                      break;
                    }
                  }
                },
              ),
            ),

            // Scanner Overlay
            _buildScannerOverlay(res, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildScannerOverlay(Responsive res, ThemeData theme) {
    return Center(
          child: Container(
            width: res.wp(70),
            height: res.wp(70),
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.primaryColor, width: 3),
              borderRadius: BorderRadius.circular(res.wp(4)),
            ),
            child: Stack(
              children: [
                // Corner indicators
                _buildCornerIndicator(
                  res,
                  Alignment.topLeft,
                  BorderRadius.only(topLeft: Radius.circular(res.wp(4))),
                ),
                _buildCornerIndicator(
                  res,
                  Alignment.topRight,
                  BorderRadius.only(topRight: Radius.circular(res.wp(4))),
                ),
                _buildCornerIndicator(
                  res,
                  Alignment.bottomLeft,
                  BorderRadius.only(bottomLeft: Radius.circular(res.wp(4))),
                ),
                _buildCornerIndicator(
                  res,
                  Alignment.bottomRight,
                  BorderRadius.only(bottomRight: Radius.circular(res.wp(4))),
                ),

                // Center focus indicator
                Center(
                  child: Container(
                    width: res.wp(8),
                    height: res.wp(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.center_focus_strong,
                      color: AppTheme.primaryColor,
                      size: res.dp(3),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
        .animate(onPlay: (controller) => controller.repeat())
        .scaleXY(begin: 0.98, end: 1.02, duration: 2000.ms)
        .then()
        .scaleXY(begin: 1.02, end: 0.98, duration: 2000.ms);
  }

  Widget _buildCornerIndicator(
    Responsive res,
    Alignment alignment,
    BorderRadius borderRadius,
  ) {
    return Align(
      alignment: alignment,
      child: Container(
        width: res.wp(10),
        height: res.wp(10),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor,
          borderRadius: borderRadius,
        ),
      ),
    );
  }

  Widget _buildQRInfo(
    Responsive res,
    ThemeData theme,
    QRScannerState scannerState,
  ) {
    final qrData = scannerState.lastScannedQR!;
    final scanTime = scannerState.scanTime!;
    final qrType = ref
        .read(qrScannerProvider.notifier)
        ._determineQRType(qrData);

    return Container(
      padding: EdgeInsets.all(res.wp(4)),
      child: AppCard(
        animationDelay: 200.ms,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getQRTypeIcon(qrType),
                  color: AppTheme.primaryColor,
                  size: res.dp(3),
                ),
                SizedBox(width: res.wp(3)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Último QR Escaneado',
                        style: TextStyle(
                          fontSize: res.dp(1.8),
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      Text(
                        '${scanTime.day}/${scanTime.month}/${scanTime.year} ${scanTime.hour}:${scanTime.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: res.dp(1.4),
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: res.hp(2)),

            Container(
              padding: EdgeInsets.all(res.wp(3)),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(res.wp(2)),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: SelectableText(
                qrData,
                style: TextStyle(
                  fontSize: res.dp(1.6),
                  fontFamily: 'monospace',
                ),
              ),
            ),

            SizedBox(height: res.hp(2)),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: qrData));
                      AppToast.showSuccess(
                        context,
                        title: 'Copiado',
                        description: 'Contenido copiado al portapapeles',
                      );
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('Copiar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: res.wp(3)),
                if (qrType == QRType.url)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        AppToast.showInfo(
                          context,
                          title: 'URL detectada',
                          description: 'Función de abrir URL próximamente',
                        );
                      },
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Abrir'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryColor,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getQRTypeIcon(QRType type) {
    switch (type) {
      case QRType.url:
        return Icons.link;
      case QRType.wifi:
        return Icons.wifi;
      case QRType.email:
        return Icons.email;
      case QRType.phone:
        return Icons.phone;
      case QRType.text:
        return Icons.text_fields;
      case QRType.other:
        return Icons.qr_code;
    }
  }

  Widget _buildInstructions(Responsive res, ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(res.wp(4)),
      child: AppCard(
        color: AppTheme.primaryColor.withOpacity(0.05),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: AppTheme.primaryColor,
              size: res.dp(2.5),
            ),
            SizedBox(width: res.wp(3)),
            Expanded(
              child: Text(
                'Apunta la cámara hacia cualquier código QR para escanearlo',
                style: TextStyle(
                  fontSize: res.dp(1.5),
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 800.ms, delay: 600.ms);
  }

  void _showHistoryBottomSheet(
    BuildContext context,
    Responsive res,
    ThemeData theme,
  ) {
    final scannerState = ref.read(qrScannerProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: res.hp(70),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(res.wp(6))),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(res.wp(4)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Historial de Escaneos',
                    style: TextStyle(
                      fontSize: res.dp(2),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      ref.read(qrScannerProvider.notifier).clearHistory();
                      Navigator.pop(context);
                      AppToast.showInfo(
                        context,
                        title: 'Historial limpiado',
                        description: 'Se eliminaron todos los registros',
                      );
                    },
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
            ),
            Expanded(
              child: scannerState.history.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.history,
                            size: res.dp(6),
                            color: theme.colorScheme.onSurface.withOpacity(0.3),
                          ),
                          SizedBox(height: res.hp(2)),
                          Text(
                            'No hay escaneos guardados',
                            style: TextStyle(
                              fontSize: res.dp(1.8),
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: res.wp(4)),
                      itemCount: scannerState.history.length,
                      itemBuilder: (context, index) {
                        final item = scannerState.history[index];
                        return AppCard(
                          margin: EdgeInsets.only(bottom: res.hp(1)),
                          child: ListTile(
                            leading: Icon(
                              _getQRTypeIcon(item.type),
                              color: AppTheme.primaryColor,
                            ),
                            title: Text(
                              item.qrData.length > 50
                                  ? '${item.qrData.substring(0, 50)}...'
                                  : item.qrData,
                              style: TextStyle(fontSize: res.dp(1.6)),
                            ),
                            subtitle: Text(
                              '${item.scanTime.day}/${item.scanTime.month}/${item.scanTime.year} ${item.scanTime.hour}:${item.scanTime.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(fontSize: res.dp(1.3)),
                            ),
                            trailing: IconButton(
                              onPressed: () {
                                Clipboard.setData(
                                  ClipboardData(text: item.qrData),
                                );
                                AppToast.showSuccess(
                                  context,
                                  title: 'Copiado',
                                  description:
                                      'Contenido copiado al portapapeles',
                                );
                              },
                              icon: const Icon(Icons.copy),
                            ),
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
}
