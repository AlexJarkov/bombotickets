import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bombotickets/features/shared/utils/responsive.dart';
import 'package:bombotickets/config/theme/app_theme_new.dart';
import 'package:bombotickets/features/shared/widgets/app_card.dart';
import 'package:bombotickets/features/shared/widgets/animated_background.dart';
import 'package:bombotickets/features/shared/widgets/glass_card.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:bombotickets/features/scanner/repositories/qr_scanner_repository.dart';

// Provider para manejar el estado del escáner
final qrScannerProvider =
    StateNotifierProvider<QrScannerNotifier, QrScannerState>((ref) {
      return QrScannerNotifier();
    });

class QrScannerState {
  final bool isLoading;
  final String? result;
  final String? errorMessage;
  final List<QrScanHistory> history;

  QrScannerState({
    this.isLoading = false,
    this.result,
    this.errorMessage,
    this.history = const [],
  });

  QrScannerState copyWith({
    bool? isLoading,
    String? result,
    String? errorMessage,
    List<QrScanHistory>? history,
    bool clearResult = false,
  }) {
    return QrScannerState(
      isLoading: isLoading ?? this.isLoading,
      result: clearResult ? null : (result ?? this.result),
      errorMessage: errorMessage,
      history: history ?? this.history,
    );
  }
}

class QrScanHistory {
  final String result;
  final DateTime scanTime;
  final String method; // 'camera' or 'gallery'

  QrScanHistory({
    required this.result,
    required this.scanTime,
    required this.method,
  });
}

class QrScannerNotifier extends StateNotifier<QrScannerState> {
  final QrScannerRepository _repository = QrScannerRepository();

  QrScannerNotifier() : super(QrScannerState());

  Future<void> scanFromFile(File imageFile, String method) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      clearResult: true,
    );

    try {
      final result = await _repository.scanQrFromFile(imageFile);

      final newHistory = QrScanHistory(
        result: result,
        scanTime: DateTime.now(),
        method: method,
      );

      state = state.copyWith(
        isLoading: false,
        result: result,
        history: [newHistory, ...state.history.take(19)],
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        clearResult: true,
      );
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void clearResult() {
    state = state.copyWith(clearResult: true);
  }
}

class QrScannerScreen extends ConsumerWidget {
  static String name = 'qr-scanner';

  const QrScannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final res = Responsive.of(context);
    final scannerState = ref.watch(qrScannerProvider);
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
            child: Padding(
              padding: EdgeInsets.all(AppTheme.spacingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: AppTheme.spacingLarge),

                  // Header
                  Row(
                    children: [
                      GlassCard(
                            padding: EdgeInsets.all(AppTheme.spacingSmall),
                            borderRadius: AppTheme.borderRadiusNormal,
                            child: InkWell(
                              onTap: () => context.pop(),
                              borderRadius: BorderRadius.circular(
                                AppTheme.borderRadiusNormal,
                              ),
                              child: Icon(
                                Icons.arrow_back_rounded,
                                color: isDark ? Colors.white : Colors.black87,
                                size: res.dp(2.4),
                              ),
                            ),
                          )
                          .animate()
                          .slideX(
                            duration: 200.ms,
                            begin: -0.1,
                            end: 0,
                            curve: Curves.fastOutSlowIn,
                          )
                          .fadeIn(
                            duration: 200.ms,
                            curve: Curves.fastOutSlowIn,
                          ),

                      SizedBox(width: AppTheme.spacingMedium),

                      Expanded(
                        child:
                            Text(
                                  'Escáner QR',
                                  style: GoogleFonts.inter(
                                    fontSize: res.dp(2.8),
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                )
                                .animate()
                                .slideY(
                                  duration: 360.ms,
                                  begin: 0.12,
                                  end: 0,
                                  curve: Curves.easeOutCubic,
                                  delay: 100.ms,
                                )
                                .fadeIn(
                                  duration: 360.ms,
                                  delay: 100.ms,
                                  curve: Curves.easeOutCubic,
                                ),
                      ),
                    ],
                  ),

                  SizedBox(height: AppTheme.spacingLarge),

                  // Información del escáner
                  AppCard(
                        padding: EdgeInsets.all(AppTheme.spacingLarge),
                        child: Column(
                          children: [
                            Icon(
                              Icons.qr_code_scanner_rounded,
                              size: res.dp(8),
                              color: AppTheme.primaryColor,
                            ),
                            SizedBox(height: AppTheme.spacingMedium),
                            Text(
                              'Escanear Código QR',
                              style: GoogleFonts.inter(
                                fontSize: res.dp(2.4),
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: AppTheme.spacingSmall),
                            Text(
                              'Toma una foto del código QR o selecciona una imagen desde tu galería',
                              style: GoogleFonts.inter(
                                fontSize: res.dp(1.6),
                                color: isDark ? Colors.white70 : Colors.black54,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 200.ms)
                      .slideY(
                        duration: 400.ms,
                        begin: 0.1,
                        end: 0,
                        delay: 200.ms,
                      ),

                  SizedBox(height: AppTheme.spacingLarge),

                  // Botones de acción
                  Row(
                        children: [
                          Expanded(
                            child: _ScanButton(
                              icon: Icons.photo_camera_rounded,
                              title: 'Tomar Foto',
                              subtitle: 'Usar cámara',
                              onTap: () =>
                                  _pickImage(context, ref, ImageSource.camera),
                              isLoading: scannerState.isLoading,
                            ),
                          ),
                          SizedBox(width: AppTheme.spacingMedium),
                          Expanded(
                            child: _ScanButton(
                              icon: Icons.photo_library_rounded,
                              title: 'Galería',
                              subtitle: 'Seleccionar imagen',
                              onTap: () =>
                                  _pickImage(context, ref, ImageSource.gallery),
                              isLoading: scannerState.isLoading,
                            ),
                          ),
                        ],
                      )
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 300.ms)
                      .slideY(
                        duration: 400.ms,
                        begin: 0.1,
                        end: 0,
                        delay: 300.ms,
                      ),

                  SizedBox(height: AppTheme.spacingLarge),

                  // Resultado o error
                  if (scannerState.result != null)
                    _ResultCard(result: scannerState.result!)
                        .animate()
                        .fadeIn(duration: 300.ms)
                        .slideY(begin: 0.1, end: 0),

                  if (scannerState.errorMessage != null)
                    _ErrorCard(
                          error: scannerState.errorMessage!,
                          onDismiss: () =>
                              ref.read(qrScannerProvider.notifier).clearError(),
                        )
                        .animate()
                        .fadeIn(duration: 300.ms)
                        .slideY(begin: 0.1, end: 0),

                  // Historial
                  if (scannerState.history.isNotEmpty) ...[
                    SizedBox(height: AppTheme.spacingLarge),
                    _HistorySection(history: scannerState.history)
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 400.ms)
                        .slideY(begin: 0.1, end: 0, delay: 400.ms),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(
    BuildContext context,
    WidgetRef ref,
    ImageSource source,
  ) async {
    final picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: source);
      if (image != null) {
        final File imageFile = File(image.path);
        final method = source == ImageSource.camera ? 'camera' : 'gallery';
        await ref
            .read(qrScannerProvider.notifier)
            .scanFromFile(imageFile, method);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar imagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _ScanButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isLoading;

  const _ScanButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final res = Responsive.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      padding: EdgeInsets.all(AppTheme.spacingLarge),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        child: Column(
          children: [
            if (isLoading)
              SizedBox(
                width: res.dp(4),
                height: res.dp(4),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryColor,
                  ),
                ),
              )
            else
              Icon(icon, size: res.dp(4), color: AppTheme.primaryColor),

            SizedBox(height: AppTheme.spacingSmall),

            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: res.dp(1.8),
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),

            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: res.dp(1.4),
                color: isDark ? Colors.white60 : Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final String result;

  const _ResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final res = Responsive.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      padding: EdgeInsets.all(AppTheme.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: Colors.green,
                size: res.dp(2.4),
              ),
              SizedBox(width: AppTheme.spacingSmall),
              Text(
                'Resultado del escaneo',
                style: GoogleFonts.inter(
                  fontSize: res.dp(1.8),
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacingMedium),
          Container(
            width: double.infinity,
            constraints: BoxConstraints(
              minHeight: res.dp(12),
              maxHeight: res.dp(25),
            ),
            padding: EdgeInsets.all(AppTheme.spacingMedium),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusNormal),
              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
            ),
            child: SingleChildScrollView(
              child: SelectableText(
                result,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: res.dp(1.3),
                  color: isDark ? Colors.white : Colors.black87,
                  height: 1.4,
                ),
              ),
            ),
          ),
          SizedBox(height: AppTheme.spacingMedium),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: result));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Resultado copiado al portapapeles'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              icon: Icon(Icons.copy_rounded),
              label: Text('Copiar resultado'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: AppTheme.spacingMedium),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppTheme.borderRadiusNormal,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String error;
  final VoidCallback onDismiss;

  const _ErrorCard({required this.error, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final res = Responsive.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      padding: EdgeInsets.all(AppTheme.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_rounded, color: Colors.red, size: res.dp(2.4)),
              SizedBox(width: AppTheme.spacingSmall),
              Expanded(
                child: Text(
                  'Error en el escaneo',
                  style: GoogleFonts.inter(
                    fontSize: res.dp(1.8),
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              IconButton(
                onPressed: onDismiss,
                icon: Icon(
                  Icons.close_rounded,
                  color: isDark ? Colors.white54 : Colors.black54,
                  size: res.dp(2),
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacingMedium),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(AppTheme.spacingMedium),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusNormal),
              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
            ),
            child: Text(
              error,
              style: GoogleFonts.inter(
                fontSize: res.dp(1.4),
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistorySection extends StatelessWidget {
  final List<QrScanHistory> history;

  const _HistorySection({required this.history});

  @override
  Widget build(BuildContext context) {
    final res = Responsive.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      padding: EdgeInsets.all(AppTheme.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Historial de escaneos',
            style: GoogleFonts.inter(
              fontSize: res.dp(1.8),
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: AppTheme.spacingMedium),
          ...history.take(5).map((item) => _HistoryItem(item: item)),
        ],
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final QrScanHistory item;

  const _HistoryItem({required this.item});

  @override
  Widget build(BuildContext context) {
    final res = Responsive.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: AppTheme.spacingSmall),
      padding: EdgeInsets.all(AppTheme.spacingMedium),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusNormal),
      ),
      child: Row(
        children: [
          Icon(
            item.method == 'camera'
                ? Icons.photo_camera_rounded
                : Icons.photo_library_rounded,
            size: res.dp(2),
            color: AppTheme.primaryColor,
          ),
          SizedBox(width: AppTheme.spacingSmall),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.result,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: res.dp(1.3),
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${item.scanTime.hour.toString().padLeft(2, '0')}:${item.scanTime.minute.toString().padLeft(2, '0')} - ${item.method}',
                  style: GoogleFonts.inter(
                    fontSize: res.dp(1.2),
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget de contenido para usar en el PageView del MainLayout
class QRScannerContent extends ConsumerWidget {
  final bool showAppBar;

  const QRScannerContent({super.key, this.showAppBar = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final res = Responsive.of(context);
    final scannerState = ref.watch(qrScannerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBackground(
      style: BackgroundStyle.surface,
      animated: true,
      intensity: 0.6,
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(AppTheme.spacingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (showAppBar) ...[
                  SizedBox(height: AppTheme.spacingLarge),

                  // Header
                  Row(
                    children: [
                      GlassCard(
                            padding: EdgeInsets.all(AppTheme.spacingSmall),
                            borderRadius: AppTheme.borderRadiusNormal,
                            child: InkWell(
                              onTap: () => context.pop(),
                              borderRadius: BorderRadius.circular(
                                AppTheme.borderRadiusNormal,
                              ),
                              child: Icon(
                                Icons.arrow_back_rounded,
                                color: isDark ? Colors.white : Colors.black87,
                                size: res.dp(2.4),
                              ),
                            ),
                          )
                          .animate()
                          .slideX(
                            duration: 200.ms,
                            begin: -0.1,
                            end: 0,
                            curve: Curves.fastOutSlowIn,
                          )
                          .fadeIn(
                            duration: 200.ms,
                            curve: Curves.fastOutSlowIn,
                          ),

                      SizedBox(width: AppTheme.spacingMedium),

                      Expanded(
                        child:
                            Text(
                                  'Escáner QR',
                                  style: GoogleFonts.inter(
                                    fontSize: res.dp(2.8),
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                )
                                .animate()
                                .slideY(
                                  duration: 360.ms,
                                  begin: 0.12,
                                  end: 0,
                                  curve: Curves.easeOutCubic,
                                  delay: 100.ms,
                                )
                                .fadeIn(
                                  duration: 360.ms,
                                  delay: 100.ms,
                                  curve: Curves.easeOutCubic,
                                ),
                      ),
                    ],
                  ),
                ] else ...[
                  SizedBox(height: AppTheme.spacingMedium),

                  // Header para PageView (sin botón de volver)
                  Text(
                        'Escáner QR',
                        style: GoogleFonts.inter(
                          fontSize: res.dp(2.8),
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      )
                      .animate()
                      .slideY(
                        duration: 360.ms,
                        begin: 0.12,
                        end: 0,
                        curve: Curves.easeOutCubic,
                        delay: 100.ms,
                      )
                      .fadeIn(
                        duration: 360.ms,
                        delay: 100.ms,
                        curve: Curves.easeOutCubic,
                      ),
                ],

                SizedBox(height: AppTheme.spacingLarge),

                // Información del escáner
                AppCard(
                      padding: EdgeInsets.all(AppTheme.spacingLarge),
                      child: Column(
                        children: [
                          Icon(
                            Icons.qr_code_scanner_rounded,
                            size: res.dp(8),
                            color: AppTheme.primaryColor,
                          ),
                          SizedBox(height: AppTheme.spacingMedium),
                          Text(
                            'Escanear Código QR',
                            style: GoogleFonts.inter(
                              fontSize: res.dp(2.4),
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: AppTheme.spacingSmall),
                          Text(
                            'Toma una foto del código QR o selecciona una imagen desde tu galería',
                            style: GoogleFonts.inter(
                              fontSize: res.dp(1.6),
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 200.ms)
                    .slideY(
                      duration: 400.ms,
                      begin: 0.1,
                      end: 0,
                      delay: 200.ms,
                    ),

                SizedBox(height: AppTheme.spacingLarge),

                // Botones de acción
                Row(
                      children: [
                        Expanded(
                          child: _ScanButton(
                            icon: Icons.photo_camera_rounded,
                            title: 'Tomar Foto',
                            subtitle: 'Usar cámara',
                            onTap: () =>
                                _pickImage(context, ref, ImageSource.camera),
                            isLoading: scannerState.isLoading,
                          ),
                        ),
                        SizedBox(width: AppTheme.spacingMedium),
                        Expanded(
                          child: _ScanButton(
                            icon: Icons.photo_library_rounded,
                            title: 'Galería',
                            subtitle: 'Seleccionar imagen',
                            onTap: () =>
                                _pickImage(context, ref, ImageSource.gallery),
                            isLoading: scannerState.isLoading,
                          ),
                        ),
                      ],
                    )
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 300.ms)
                    .slideY(
                      duration: 400.ms,
                      begin: 0.1,
                      end: 0,
                      delay: 300.ms,
                    ),

                SizedBox(height: AppTheme.spacingLarge),

                // Resultado o error
                if (scannerState.result != null)
                  _ResultCard(result: scannerState.result!)
                      .animate()
                      .fadeIn(duration: 300.ms)
                      .slideY(begin: 0.1, end: 0),

                if (scannerState.errorMessage != null)
                  _ErrorCard(
                        error: scannerState.errorMessage!,
                        onDismiss: () =>
                            ref.read(qrScannerProvider.notifier).clearError(),
                      )
                      .animate()
                      .fadeIn(duration: 300.ms)
                      .slideY(begin: 0.1, end: 0),

                // Historial
                if (scannerState.history.isNotEmpty) ...[
                  SizedBox(height: AppTheme.spacingLarge),
                  _HistorySection(history: scannerState.history)
                      .animate()
                      .fadeIn(duration: 400.ms, delay: 400.ms)
                      .slideY(begin: 0.1, end: 0, delay: 400.ms),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(
    BuildContext context,
    WidgetRef ref,
    ImageSource source,
  ) async {
    final picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: source);
      if (image != null) {
        final File imageFile = File(image.path);
        final method = source == ImageSource.camera ? 'camera' : 'gallery';
        await ref
            .read(qrScannerProvider.notifier)
            .scanFromFile(imageFile, method);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar imagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
