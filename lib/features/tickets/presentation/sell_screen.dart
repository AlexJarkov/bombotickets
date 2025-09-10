import 'package:auto_size_text/auto_size_text.dart';
import 'package:bombotickets/config/theme/app_theme_new.dart';
import 'package:bombotickets/features/shared/utils/responsive.dart';
import 'package:bombotickets/features/shared/widgets/animated_background.dart';
import 'package:bombotickets/features/shared/widgets/app_card.dart';
import 'package:bombotickets/features/shared/widgets/custom_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:bombotickets/features/scanner/repositories/qr_scanner_repository.dart';
import 'package:bombotickets/features/tickets/repositories/sell_tickets_repository.dart';
import 'dart:convert';

class ScannedTicketInfo {
  final String? title;
  final DateTime? date;
  final String? venue;
  final String? category;
  final double? originalPrice;
  final String? imageUrl;
  final String? seat;

  const ScannedTicketInfo({
    this.title,
    this.date,
    this.venue,
    this.category,
    this.originalPrice,
    this.imageUrl,
    this.seat,
  });

  static ScannedTicketInfo fromDynamic(dynamic data) {
    if (data is String) {
      try {
        final decoded = jsonDecode(data);
        return fromDynamic(decoded);
      } catch (_) {
        return const ScannedTicketInfo();
      }
    }
    if (data is Map) {
      T? pick<T>(List<String> keys) {
        for (final k in keys) {
          final v = data[k];
          if (v is T) return v;
        }
        return null;
      }

      String? title = pick<String>([
        'title', 'event', 'eventName', 'name', 'evento', 'titulo'
      ]);
      String? venue = pick<String>([
        'venue', 'location', 'place', 'stadium', 'recinto'
      ]);
      String? category = pick<String>([
        'category', 'tier', 'type', 'zona', 'sector', 'seccion'
      ]);
      String? seat = pick<String>([
        'seat', 'asiento', 'butaca', 'filaAsiento', 'localidad'
      ]);
      String? imageUrl = pick<String>(['image', 'imageUrl', 'image_url']);

      double? originalPrice;
      final priceVal = pick<dynamic>([
        'originalPrice', 'original_price', 'price', 'precio', 'valor', 'amount'
      ]);
      if (priceVal is num) originalPrice = priceVal.toDouble();
      if (priceVal is String) {
        final cleaned = priceVal.replaceAll(RegExp(r'[^0-9.,-]'), '').replaceAll(',', '.');
        originalPrice = double.tryParse(cleaned);
      }

      DateTime? dt;
      final dateVal = pick<dynamic>(['date', 'fecha', 'eventDate', 'datetime']);
      if (dateVal is String) {
        dt = DateTime.tryParse(dateVal);
      } else if (dateVal is int) {
        // epoch seconds or ms
        dt = DateTime.fromMillisecondsSinceEpoch(
          dateVal > 1e12 ? dateVal : dateVal * 1000,
          isUtc: false,
        );
      }

      return ScannedTicketInfo(
        title: title,
        date: dt,
        venue: venue,
        category: category,
        originalPrice: originalPrice,
        imageUrl: imageUrl,
        seat: seat,
      );
    }
    return const ScannedTicketInfo();
  }
}

class SellTicketDetailsScreen extends StatefulWidget {
  static const String routeName = '/tickets/sell/details';

  final String ticketQr;

  const SellTicketDetailsScreen({super.key, required this.ticketQr});

  @override
  State<SellTicketDetailsScreen> createState() => _SellTicketDetailsScreenState();
}

class _SellTicketDetailsScreenState extends State<SellTicketDetailsScreen> {
  final _qtyCtrl = TextEditingController(text: '1');
  final _priceCtrl = TextEditingController();
  bool _submitting = false;
  final _repo = SellTicketsRepository();
  final _qrRepo = QrScannerRepository();

  bool _loadingInfo = true;
  String? _infoError;
  ScannedTicketInfo? _info;
  bool _formPosted = false;
  String? _qtyError;
  String? _priceError;
  String? _submitError;

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _priceCtrl.dispose();
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
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + AppTheme.spacingMedium,
            ),
            child: Padding(
              padding: EdgeInsets.all(AppTheme.spacingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: AppTheme.spacingLarge),

                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded),
                        onPressed: () => context.pop(),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Publicar Ticket',
                          style: GoogleFonts.inter(
                            fontSize: res.dp(2.6),
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: AppTheme.spacingLarge),

                  // Ticket info card removed by request.

                  SizedBox(height: AppTheme.spacingLarge),

                  AppCard(
                    padding: EdgeInsets.all(AppTheme.spacingLarge),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_submitError != null) ...[
                          _ErrorBanner(message: _submitError!),
                          const SizedBox(height: 12),
                        ],
                        Text('Precio de Reventa',
                            style: GoogleFonts.inter(
                              fontSize: res.dp(1.8),
                              fontWeight: FontWeight.w700,
                            )),
                        const SizedBox(height: 16),
                        if (_info?.originalPrice != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              'Precio Original: \$${_formatPrice(_info!.originalPrice!)}',
                              style: GoogleFonts.inter(
                                fontSize: res.dp(1.35),
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.7),
                              ),
                            ),
                          ),
                        Row(
                          children: [
                            Expanded(
                              child: CustomInputField(
                                controller: _qtyCtrl,
                                label: 'Cantidad',
                                keyboardType: TextInputType.number,
                                prefixIcon: Icons.confirmation_number_outlined,
                                isFormPosted: _formPosted,
                                errorMessage: _qtyError,
                                focusedBorder: true,
                                onChanged: (_) {
                                  if (_formPosted) setState(() { _qtyError = null; _submitError = null; });
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CustomInputField(
                                controller: _priceCtrl,
                                label: 'Precio unitario',
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                prefixIcon: Icons.attach_money_rounded,
                                isFormPosted: _formPosted,
                                errorMessage: _priceError,
                                focusedBorder: true,
                                onChanged: (_) {
                                  if (_formPosted) setState(() { _priceError = null; _submitError = null; });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _PresetButton(
                                label: '-10%',
                                onTap: () => _applyPreset(-0.10),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _PresetButton(
                                label: 'Precio Original',
                                onTap: () => _applyOriginal(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _PresetButton(
                                label: '+10%',
                                onTap: () => _applyPreset(0.10),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _submitting ? null : _submit,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: _submitting
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text('Continuar con la Reventa'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            'Comisión de la app: 5% del precio final',
                            style: GoogleFonts.inter(
                              fontSize: res.dp(1.2),
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 260.ms, delay: 80.ms).slideY(begin: 0.08, end: 0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatQrPreview(String v) {
    if (v.length <= 160) return v;
    return '${v.substring(0, 160)}…';
  }

  String _formatPrice(double v) {
    final s = v.toStringAsFixed(0);
    final withSep = s.replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    return withSep;
  }

  @override
  void initState() {
    super.initState();
    _fetchInfo();
  }

  Future<void> _fetchInfo() async {
    setState(() {
      _loadingInfo = true;
      _infoError = null;
    });
    try {
      if (widget.ticketQr.isEmpty) {
        throw Exception('QR no recibido');
      }
      final str = await _qrRepo.readQrFromText(widget.ticketQr);
      dynamic parsed;
      try {
        parsed = jsonDecode(str);
      } catch (_) {
        parsed = str; // may still be useful, but we won't show raw token
      }
      final info = ScannedTicketInfo.fromDynamic(parsed);
      setState(() {
        _info = info;
        _loadingInfo = false;
      });
      // Pre-fill price with original if empty
      if (_priceCtrl.text.trim().isEmpty && info.originalPrice != null) {
        _priceCtrl.text = info.originalPrice!.toStringAsFixed(0);
      }
    } catch (e) {
      setState(() {
        _loadingInfo = false;
        _infoError = e.toString();
      });
    }
  }

  void _applyPreset(double pct) {
    if (_priceCtrl.text.trim().isEmpty) {
      if (_info?.originalPrice == null) return;
      final base = _info!.originalPrice!;
      final newVal = (base * (1 + pct)).clamp(0, double.infinity);
      _priceCtrl.text = newVal.toStringAsFixed(0);
      return;
    }
    final current = double.tryParse(_priceCtrl.text.trim().replaceAll(',', '.'));
    if (current == null) return;
    final newVal = (current * (1 + pct)).clamp(0, double.infinity);
    _priceCtrl.text = newVal.toStringAsFixed(0);
  }

  void _applyOriginal() {
    if (_info?.originalPrice != null) {
      _priceCtrl.text = _info!.originalPrice!.toStringAsFixed(0);
    }
  }

  Future<void> _submit() async {
    HapticFeedback.lightImpact();
    setState(() {
      _formPosted = true;
      _qtyError = null;
      _priceError = null;
      _submitError = null;
    });

    // Manual validation aligned with CustomInputField API
    final qtyText = _qtyCtrl.text.trim();
    final qty = int.tryParse(qtyText);
    if (qty == null || qty <= 0) {
      setState(() => _qtyError = 'Ingresa una cantidad válida');
    }

    final priceStr = _priceCtrl.text.trim().replaceAll(',', '.');
    final priceVal = double.tryParse(priceStr);
    if (priceVal == null || priceVal <= 0) {
      setState(() => _priceError = 'Ingresa un precio válido');
    }

    if (_qtyError != null || _priceError != null) return;

    setState(() => _submitting = true);

    try {
      final quantity = qty!;
      final price = priceVal!;

      // Simple guard: we currently support 1 QR per publicación
      if (quantity > 1) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Por ahora publica 1 ticket por escaneo (1 QR).'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }
      await _repo.createResaleListing(
        qrTokens: [widget.ticketQr],
        cantidad: quantity,
        precioOfertado: price,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ticket publicado exitosamente')),
      );
      context.pop(); // back to previous (likely Tickets screen)
    } catch (e) {
      if (!mounted) return;
      final friendly = _friendlyError(e.toString());
      setState(() => _submitError = friendly);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String _friendlyError(String raw) {
    final msg = raw
        .replaceAll('Exception: ', '')
        .replaceAll('Error al publicar: ', '')
        .trim()
        .toLowerCase();

    if (msg.contains('no pertenece') || msg.contains('pertenece al usuario')) {
      return 'Este ticket no pertenece a tu cuenta.';
    }
    if (msg.contains('repetido') || msg.contains('mismo ticket')) {
      return 'Ese ticket ya fue agregado a la solicitud.';
    }
    if (msg.contains('no válido') || msg.contains('estado no valido') || msg.contains('en_venta') || msg.contains('usado')) {
      return 'El ticket no está disponible para publicar (ya en venta o usado).';
    }
    return 'No pudimos publicar este ticket. Verifica los datos y vuelve a intentar.';
  }
}

class _PresetButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PresetButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: Text(label),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_rounded, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.inter(color: Colors.red.shade800, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// Ticket info card intentionally removed per request.

class SellTicketScanScreen extends StatefulWidget {
  static const String routeName = '/tickets/sell/scan';

  const SellTicketScanScreen({super.key});

  @override
  State<SellTicketScanScreen> createState() => _SellTicketScanScreenState();
}

class _SellTicketScanScreenState extends State<SellTicketScanScreen> {
  bool _loading = false;

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
            child: Padding(
              padding: EdgeInsets.all(AppTheme.spacingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: AppTheme.spacingLarge),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded),
                        onPressed: () => context.pop(),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Publicar Ticket',
                          style: GoogleFonts.inter(
                            fontSize: res.dp(2.6),
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: AppTheme.spacingLarge),

                  AppCard(
                    padding: EdgeInsets.all(AppTheme.spacingLarge),
                    child: Column(
                      children: [
                        Icon(
                          Icons.sell_outlined,
                          size: res.dp(6),
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(height: 8),
                        AutoSizeText(
                          'Escanea el QR del ticket que quieres vender',
                          maxLines: 1,
                          style: GoogleFonts.inter(
                            fontSize: res.dp(1.8),
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.tonalIcon(
                                onPressed: _loading ? null : _scanWithCamera,
                                icon: const Icon(Icons.qr_code_scanner_rounded),
                                label: const Text('Usar cámara'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _loading ? null : _scanFromGallery,
                                icon: const Icon(Icons.photo_library_rounded),
                                label: const Text('Desde galería'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 260.ms).slideY(begin: 0.08, end: 0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _scanWithCamera() async {
    HapticFeedback.lightImpact();
    final qr = await context.push<String>('/scanner/live-result');
    if (qr == null || qr.isEmpty) return;
    if (!mounted) return;
    context.push(SellTicketDetailsScreen.routeName, extra: {'qr': qr});
  }

  Future<void> _scanFromGallery() async {
    setState(() => _loading = true);
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;
      final repo = QrScannerRepository();
      final result = await repo.scanQrFromFile(File(image.path));
      if (!mounted) return;
      if (result.isNotEmpty) {
        context.push(SellTicketDetailsScreen.routeName, extra: {'qr': result});
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al leer imagen: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
