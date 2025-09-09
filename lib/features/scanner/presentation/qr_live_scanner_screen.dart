import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';

import 'package:bombotickets/features/shared/utils/responsive.dart';
import 'package:bombotickets/config/theme/app_theme_new.dart';
import 'package:bombotickets/features/scanner/presentation/qr_scanner_screen.dart';

class QrLiveScannerScreen extends ConsumerStatefulWidget {
  static String name = 'qr-scanner-live';

  const QrLiveScannerScreen({super.key});

  @override
  ConsumerState<QrLiveScannerScreen> createState() => _QrLiveScannerScreenState();
}

class _QrLiveScannerScreenState extends ConsumerState<QrLiveScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.unrestricted,
    facing: CameraFacing.back,
    torchEnabled: false,
    formats: [BarcodeFormat.qrCode],
  );

  bool _processing = false;

  @override
  void initState() {
    super.initState();
    // Ensure camera starts
    _controller.start();
    // Slight zoom helps recognition at a small distance
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await _controller.setZoomScale(1.2);
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final res = Responsive.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;
          final cutOutSize = size.width * 0.7;
          final cutOutTop = (size.height - cutOutSize) / 2;
          final cutOutLeft = (size.width - cutOutSize) / 2;
          final cutOutRect =
              Rect.fromLTWH(cutOutLeft, cutOutTop, cutOutSize, cutOutSize);

          return Stack(
            fit: StackFit.expand,
            children: [
              // Camera preview
              MobileScanner(
                controller: _controller,
                fit: BoxFit.cover,
                // Only analyze barcodes within the square cutout
                scanWindow: cutOutRect,
                onDetect: (capture) async {
                  if (_processing) return;
                  final barcodes = capture.barcodes;
                  if (barcodes.isEmpty) return;

                  // Try to extract a non-null, non-empty value from any barcode
                  String? value;
                  for (final b in barcodes) {
                    final rv = b.rawValue;
                    if (rv != null && rv.isNotEmpty) {
                      value = rv;
                      break;
                    }
                    final bytes = b.rawBytes;
                    if (bytes != null && bytes.isNotEmpty) {
                      try {
                        value = utf8.decode(bytes, allowMalformed: true);
                        if (value.isNotEmpty) break;
                      } catch (_) {
                        try {
                          value = latin1.decode(bytes);
                          if (value.isNotEmpty) break;
                        } catch (_) {}
                      }
                    }
                  }

                  if (value == null || value.isEmpty) return;

                  setState(() => _processing = true);
                  // Provide instant feedback and pause camera while validating
                  HapticFeedback.mediumImpact();
                  await _controller.stop();

                  try {
                    await ref
                        .read(qrScannerProvider.notifier)
                        .scanFromText(value, 'scanner');

                    if (mounted) context.pop();
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error al procesar QR: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    setState(() => _processing = false);
                    // Resume camera if user stays on screen
                    await _controller.start();
                  }
                },
                errorBuilder: (context, error, child) {
                  return Center(
                    child: Text(
                      'No se pudo acceder a la cámara: $error',
                      style: GoogleFonts.inter(color: Colors.white),
                    ),
                  );
                },
              ),

              // Overlay + in-camera controls below the square
              Positioned.fill(
                child: _ScannerOverlay(
                  cutOutRect: cutOutRect,
                  processing: _processing,
                  onBack: () => context.pop(),
                  onToggleTorch: () async {
                    await _controller.toggleTorch();
                    setState(() {});
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ScannerOverlay extends StatefulWidget {
  final Rect cutOutRect;
  final VoidCallback onBack;
  final VoidCallback onToggleTorch;
  final bool processing;

  const _ScannerOverlay({
    super.key,
    required this.cutOutRect,
    required this.onBack,
    required this.onToggleTorch,
    required this.processing,
  });

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
            final cutOutLeft = cutOutRect.left;
            final cutOutSize = cutOutRect.width;
            final t = _glowCtrl.value; // 0..1
            final glowOpacity = 0.35 + 0.35 * t; // 0.35..0.7
            final blur = 8.0 + 16.0 * t; // 8..24

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
                    child: Container(
                      color: Colors.black.withOpacity(0.25),
                    ),
                  ),
                ),

                // Border of the cutout with animated outer glow (no inner glow)
                Positioned.fill(
                  child: CustomPaint(
                    painter: _CutoutBorderPainter(
                      cutOutRect: cutOutRect,
                      radius: 16,
                      glowT: t,
                    ),
                  ),
                ),

                // Buttons row below the square
                Positioned(
                  top: cutOutTop + cutOutSize + 16,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _CircleButton(
                        icon: Icons.arrow_back_rounded,
                        onTap: widget.onBack,
                        isDark: true,
                      ),
                      const SizedBox(width: 24),
                      _CircleButton(
                        icon: Icons.flash_on_rounded,
                        onTap: widget.onToggleTorch,
                        isDark: true,
                      ),
                    ],
                  ),
                ),

                // Hint text under buttons
                Positioned(
                  top: cutOutTop + cutOutSize + 72,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      'Apunta al código QR',
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
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.white),
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

    // Animated outer glow only (clip out the inside so it does not bleed in)
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
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}
