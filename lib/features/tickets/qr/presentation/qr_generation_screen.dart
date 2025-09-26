import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:bombotickets/config/theme/app_theme_new.dart';
import 'package:bombotickets/features/tickets/qr/providers/qr_form_provider.dart';
import 'package:bombotickets/features/tickets/qr/providers/qr_payment_process_provider.dart';
import 'package:bombotickets/features/shared/utils/responsive.dart';

class QrGenerationScreen extends ConsumerStatefulWidget {
  static const name = 'qr-generation';
  const QrGenerationScreen({super.key});


  @override
  ConsumerState<QrGenerationScreen> createState() => _QrGenerationScreenState();
}

class _QrGenerationScreenState extends ConsumerState<QrGenerationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isModalVisible = false; // Protección contra modales duplicados

  @override
  void initState() {
    super.initState();

    // Configurar la animación de rotación
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );

    // Generar el QR al entrar a la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(qrPaymentProcessProvider.notifier).generateQRForCurrentPayer();
    });
  }

  @override
  void dispose() {
    // Importante: Detener el animation controller cuando el widget se destruye
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
    final qrForm = ref.watch(qrFormProvider);
    final qrProcess = ref.watch(qrPaymentProcessProvider);
    final currentAmount = qrForm.currentAmount;

    // En QrGenerationScreen.build() (en la sección de desglose)
    final base = qrForm.tableTotal;          // sin comisión
    final comBs = qrForm.tipBolivianos;      // comisión en Bs
    final total = qrForm.currentAmount;      // total cobrado (base + comisión)

    // Escuchar cambios en el estado de pago confirmado
    ref.listen<bool>(
      qrPaymentProcessProvider.select((state) => state.isPaymentConfirmed),
      (previous, isPaymentConfirmed) {
        if (isPaymentConfirmed) {
          _navigateAfterPayment();
        }
      },
    );

    // Mostrar mensaje de consulta manual como modal
    ref.listen<int>(
      qrPaymentProcessProvider.select((state) => state.manualCheckMessageId),
      (previous, messageId) {
        final message = ref.read(qrPaymentProcessProvider).manualCheckMessage;
        if (message != null && messageId > 0 && !_isModalVisible) {
          _showManualCheckModal(message);
        }
      },
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final shouldPop = await _confirmCancelarQR(true);
          if (shouldPop && mounted) {
            ref.read(qrPaymentProcessProvider.notifier).reset();
            context.pop();
          }
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: responsive.wp(4),
                vertical: responsive.hp(2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: responsive.hp(3)),
                  Text(
                        'Cliente ${qrForm.currentPayerIndex + 1}',
                        style: TextStyle(
                          fontSize: responsive.dp(2.2),
                          fontWeight: FontWeight.w600,
                        ),
                      )
                      .animate()
                      .fadeIn(duration: 600.ms, curve: Curves.easeOutQuart)
                      .slideY(
                        begin: -0.3,
                        duration: 600.ms,
                        curve: Curves.easeOutBack,
                      ),

                  SizedBox(height: responsive.hp(4)),

                  // QR Code o loading
                  if (qrProcess.qrImage != null)
                    Container(
                          padding: EdgeInsets.all(responsive.dp(1)),
                          width: responsive.wp(66),
                          height: responsive.wp(66),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                              AppTheme.borderRadiusLarge,
                            ),
                          ),
                          child: Image.memory(
                            base64Decode(qrProcess.qrImage!),
                            fit: BoxFit.contain,
                          ),
                        )
                        .animate(delay: 400.ms)
                        .fadeIn(duration: 800.ms, curve: Curves.easeOutQuart)
                        .scale(
                          begin: const Offset(0.8, 0.8),
                          duration: 800.ms,
                          curve: Curves.easeOutBack,
                        )
                  else if (qrProcess.isLoading)
                    Container(
                          padding: EdgeInsets.all(responsive.dp(1)),
                          width: responsive.wp(64),
                          height: responsive.wp(64),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                              AppTheme.borderRadiusLarge,
                            ),
                          ),
                          child: RotationTransition(
                            turns: _animation,
                            child: SvgPicture.asset(
                              "assets/images/transaction-process-arrows.svg",
                              fit: BoxFit.contain,
                            ),
                          ),
                        )
                        .animate(delay: 300.ms)
                        .fadeIn(duration: 600.ms)
                        .scale(
                          begin: const Offset(0.9, 0.9),
                          duration: 600.ms,
                          curve: Curves.easeOutQuart,
                        )
                  else
                    Text(
                          'Error al generar QR',
                          style: TextStyle(
                            fontSize: responsive.dp(2),
                            color: Colors.red,
                          ),
                        )
                        .animate(delay: 300.ms)
                        .fadeIn(duration: 600.ms)
                        .shake(duration: 600.ms, hz: 2),

                  SizedBox(height: responsive.hp(3)),

                  Text(
                        'Escanear QR por favor',
                        style: TextStyle(
                          fontSize: responsive.dp(2),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      )
                      .animate(delay: 200.ms)
                      .fadeIn(duration: 600.ms, curve: Curves.easeOutQuart)
                      .slideY(
                        begin: 0.2,
                        duration: 600.ms,
                        curve: Curves.easeOutQuart,
                      ),

                  SizedBox(height: responsive.hp(3)),

                  // Desglose de montos
                  Container(
                        padding: EdgeInsets.all(responsive.dp(2)),
                        margin: EdgeInsets.symmetric(
                          horizontal: responsive.wp(6),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            AppTheme.borderRadiusNormal,
                          ),
                        ),
                        child: Column(
                          children: [
                            // Monto base (sin propina)
                            Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Monto base:',
                                      style: TextStyle(
                                        fontSize: responsive.dp(1.8),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      'Bs. ${(qrForm.tableTotal +qrForm.tipPercentage).toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: responsive.dp(1.8),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                )
                                .animate(delay: 800.ms)
                                .fadeIn(duration: 400.ms)
                                .slideX(begin: -0.2, duration: 400.ms),
                            SizedBox(height: responsive.hp(1)),
                            // Propina
                            Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      ' (${qrForm.tipPercentage.toStringAsFixed(0)}%):',
                                      style: TextStyle(
                                        fontSize: responsive.dp(1.8),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      'Bs. ${(qrForm.tipBolivianos).toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: responsive.dp(1.8),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                )
                                .animate(delay: 900.ms)
                                .fadeIn(duration: 400.ms)
                                .slideX(begin: -0.2, duration: 400.ms),
                            Divider(height: responsive.hp(2)),
                            
                            // Total
                            Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Total a pagar:',
                                      style: TextStyle(
                                        fontSize: responsive.dp(2),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      'Bs. ${currentAmount.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: responsive.dp(2),
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                )
                                .animate(delay: 1000.ms)
                                .fadeIn(duration: 400.ms)
                                .slideX(begin: -0.2, duration: 400.ms)
                                .then(delay: 200.ms)
                                .scale(
                                  begin: const Offset(1.0, 1.0),
                                  end: const Offset(1.05, 1.05),
                                  duration: 300.ms,
                                  curve: Curves.easeInOut,
                                )
                                .then()
                                .scale(
                                  begin: const Offset(1.05, 1.05),
                                  end: const Offset(1.0, 1.0),
                                  duration: 300.ms,
                                  curve: Curves.easeInOut,
                                ),
                          ],
                        ),
                      )
                      .animate(delay: 600.ms)
                      .fadeIn(duration: 600.ms, curve: Curves.easeOutQuart)
                      .slideY(
                        begin: 0.3,
                        duration: 600.ms,
                        curve: Curves.easeOutQuart,
                      ),

                  SizedBox(height: responsive.hp(2)),

                  // Botón de consulta manual
                  ElevatedButton.icon(
                        onPressed:
                            qrProcess.isManualCheckLoading ||
                                    qrProcess.isPaymentConfirmed ||
                                    qrProcess.qrId == null
                                ? null
                                : () {
                                  ref
                                      .read(qrPaymentProcessProvider.notifier)
                                      .manualCheckPaymentStatus();
                                },
                        icon:
                            qrProcess.isManualCheckLoading
                                ? SizedBox(
                                  width: responsive.dp(2),
                                  height: responsive.dp(2),
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                : Icon(Icons.refresh, size: responsive.dp(2.5)),
                        label: Text(
                          qrProcess.isManualCheckLoading
                              ? 'Consultando...'
                              : 'Consultar Estado',
                          style: TextStyle(
                            fontSize: responsive.dp(1.8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: responsive.wp(6),
                            vertical: responsive.hp(1.5),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppTheme.borderRadiusNormal,
                            ),
                          ),
                        ),
                      )
                      .animate(delay: 1200.ms)
                      .fadeIn(duration: 600.ms, curve: Curves.easeOutQuart)
                      .slideY(
                        begin: 0.3,
                        duration: 600.ms,
                        curve: Curves.easeOutBack,
                      )
                      .animate(target: qrProcess.isManualCheckLoading ? 1 : 0)
                      .scale(
                        begin: const Offset(1.0, 1.0),
                        end: const Offset(0.95, 0.95),
                        duration: 100.ms,
                        curve: Curves.easeOut,
                      ),

                  SizedBox(height: responsive.hp(4)),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomNavBar(),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    final responsive = Responsive.of(context);
    return Container(
          padding: EdgeInsets.only(
            top: responsive.hp(1.8),
            bottom: responsive.hp(1.8),
            left: responsive.wp(3.8),
            right: responsive.wp(3.8),
          ),
          decoration: BoxDecoration(
            color: AppTheme.scaffoldBackground,
            border: Border(
              top: BorderSide(color: AppTheme.navBorderColor, width: 1),
            ),
          ),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                      onPressed: () async {
                        final shouldGoBack = await _confirmCancelarQR(true);
                        if (shouldGoBack && mounted) {
                          context.pop();
                        }
                      },
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
                    )
                    .animate(target: 1)
                    .scale(
                      duration: 100.ms,
                      curve: Curves.easeOut,
                      begin: const Offset(1.0, 1.0),
                      end: const Offset(0.95, 0.95),
                    ),
                ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.greyBtnColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppTheme.borderRadiusSmall,
                          ),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: responsive.wp(6),
                          vertical: responsive.hp(1.2),
                        ),
                      ),
                      onPressed: () async {
                        final shouldCancel = await _confirmCancelarQR(false);
                        if (shouldCancel && mounted) {
                          context.pop();
                        }
                      },
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
                    )
                    .animate(target: 1)
                    .scale(
                      duration: 100.ms,
                      curve: Curves.easeOut,
                      begin: const Offset(1.0, 1.0),
                      end: const Offset(0.95, 0.95),
                    ),
              ],
            ),
          ),
        )
        .animate(delay: 1300.ms)
        .fadeIn(duration: 600.ms)
        .slideY(begin: 1.0, duration: 600.ms, curve: Curves.easeOutQuart);
  }

  void _navigateAfterPayment() {
    if (!mounted) return; // Verificar si el widget todavía está montado
    final qrProcess = ref.read(qrPaymentProcessProvider);
    final qrForm = ref.read(qrFormProvider);

    if (qrProcess.allPaymentsCompleted && qrForm.isPaymentComplete) {
      // Todos los pagos completados, ir a pantalla de éxito
      context.go('/qr-success');
    } else {
      // Aún hay pagos pendientes, ir a pantalla de siguiente pagador
      context.go('/qr-next-payer');
    }
  }

  Future<bool> _confirmCancelarQR(bool retroceder) async {
    final responsive = Responsive.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            icon: Icon(
              Icons.warning_amber_outlined,
              size: responsive.dp(14),
              color: Colors.amber,
            ),
            title: Text(
              'Alerta',
              style: TextStyle(
                fontSize: responsive.dp(3.8),
                fontWeight: FontWeight.bold,
              ),
            ),
            content:
                retroceder
                    ? Text(
                      '¿Estás seguro que deseas volver atrás?',
                      style: TextStyle(fontSize: responsive.dp(1.8)),
                    )
                    : Text(
                      '¿Estás seguro que deseas cancelar este QR?',
                      style: TextStyle(fontSize: responsive.dp(1.8)),
                    ),
            actions: [
              TextButton(
                onPressed: () => context.pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () {
                  ref.read(qrPaymentProcessProvider.notifier).reset();
                  context.pop(true);
                },
                child: const Text('Sí'),
              ),
            ],
          ),
    );

    return result ?? false;
  }

  void _showManualCheckModal(String message) {
    if (_isModalVisible) return; // Evitar modales duplicados

    _isModalVisible = true;
    final responsive = Responsive.of(context);
    final isSuccess = message.contains('confirmado');
    final isError = message.contains('Error');

    showDialog(
      context: context,
      barrierDismissible: true,
      builder:
          (context) => AlertDialog(
                icon: Icon(
                      isError
                          ? Icons.error_outline
                          : isSuccess
                          ? Icons.check_circle_outline
                          : Icons.info_outline,
                      size: responsive.dp(6),
                      color:
                          isError
                              ? Colors.red
                              : isSuccess
                              ? Colors.green
                              : Colors.orange,
                    )
                    .animate()
                    .scale(duration: 400.ms, curve: Curves.easeOutBack)
                    .then(delay: 100.ms)
                    .shake(duration: isSuccess ? 0.ms : 300.ms, hz: 3),
                title: Text(
                      isError
                          ? 'Error'
                          : isSuccess
                          ? '¡Éxito!'
                          : 'Información',
                      style: TextStyle(
                        fontSize: responsive.dp(2.5),
                        fontWeight: FontWeight.bold,
                        color:
                            isError
                                ? Colors.red
                                : isSuccess
                                ? Colors.green
                                : Colors.orange,
                      ),
                    )
                    .animate(delay: 100.ms)
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: -0.2, duration: 300.ms),
                content: Text(
                      message,
                      style: TextStyle(
                        fontSize: responsive.dp(1.8),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    )
                    .animate(delay: 200.ms)
                    .fadeIn(duration: 300.ms)
                    .slideX(begin: 0.2, duration: 300.ms),
                actions: [
                  TextButton(
                        onPressed: () {
                          _closeModal();
                        },
                        child: Text(
                          'Cerrar',
                          style: TextStyle(
                            fontSize: responsive.dp(1.8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                      .animate(delay: 300.ms)
                      .fadeIn(duration: 300.ms)
                      .scale(
                        begin: const Offset(0.8, 0.8),
                        duration: 300.ms,
                        curve: Curves.easeOutBack,
                      ),
                ],
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppTheme.borderRadiusNormal,
                  ),
                ),
              )
              .animate()
              .fadeIn(duration: 300.ms)
              .scale(
                begin: const Offset(0.8, 0.8),
                duration: 400.ms,
                curve: Curves.easeOutBack,
              )
              .then(delay: isSuccess ? 200.ms : 0.ms)
              .shimmer(
                duration: isSuccess ? 800.ms : 0.ms,
                color: Colors.white.withOpacity(0.5),
              ),
    ).then((_) {
      // Cuando el modal se cierra (por cualquier motivo)
      _isModalVisible = false;
    });

    // Auto-cerrar el modal después de 3 segundos para todos los tipos
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _isModalVisible && Navigator.of(context).canPop()) {
        _closeModal();
      }
    });
  }

  void _closeModal() {
    if (_isModalVisible) {
      _isModalVisible = false;
      ref.read(qrPaymentProcessProvider.notifier).clearManualCheckMessage();
      Navigator.of(context).pop();
    }
  }
}
