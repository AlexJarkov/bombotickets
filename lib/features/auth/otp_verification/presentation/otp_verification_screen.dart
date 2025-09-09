import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bombotickets/features/auth/providers/auth_provider.dart';
import 'package:bombotickets/features/auth/otp_verification/providers/otp_verification_provider.dart';
import 'package:bombotickets/features/shared/widgets/animated_background.dart';
import 'package:bombotickets/features/shared/widgets/glass_card.dart';
import 'package:bombotickets/features/shared/widgets/custom_filled_button.dart';
import 'package:bombotickets/config/theme/app_theme_new.dart';
import 'package:bombotickets/features/shared/utils/responsive.dart';
import 'package:flutter_animate/flutter_animate.dart';

class OtpVerificationScreen extends ConsumerWidget {
  static String name = 'otp-verification';
  final String email;

  const OtpVerificationScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final res = Responsive.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authProvider);
    final otpState = ref.watch(otpVerificationProvider(email));

    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark
        ? Colors.white.withValues(alpha: 0.8)
        : Colors.black54;
    final iconColor = isDark ? Colors.white : Colors.black87;

    // Escuchar cambios en el provider de OTP para mostrar mensajes
    ref.listen(otpVerificationProvider(email), (previous, next) {
      if (previous?.successMessage != next.successMessage &&
          next.successMessage != null) {
        if (context.mounted) {
          _showResultDialog(context, res, true, next.successMessage!);
          // Redirigir al login después de 3 segundos
          Future.delayed(const Duration(seconds: 3), () {
            if (context.mounted) {
              Navigator.of(context).pop(); // Cerrar dialog
              context.go('/login');
            }
          });
        }
      }

      if (previous?.errorMessage != next.errorMessage &&
          next.errorMessage != null) {
        if (context.mounted) {
          _showResultDialog(context, res, false, next.errorMessage!);
          // Cerrar dialog después de 3 segundos y limpiar mensaje
          Future.delayed(const Duration(seconds: 3), () {
            if (context.mounted) {
              Navigator.of(context).pop(); // Cerrar dialog
              ref.read(otpVerificationProvider(email).notifier).clearMessages();
            }
          });
        }
      }
    });

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: AnimatedBackground(
        style: BackgroundStyle.surface,
        animated: true,
        intensity: 0.6,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: EdgeInsets.all(AppTheme.spacingMedium),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: AppTheme.spacingSmall),

                            // Botón de regresar
                            Align(
                              alignment: Alignment.topLeft,
                              child: GlassCard(
                                padding: EdgeInsets.all(AppTheme.spacingSmall),
                                borderRadius: AppTheme.borderRadiusNormal,
                                child: InkWell(
                                  onTap: () => context.canPop()
                                      ? context.pop()
                                      : context.go('/register'),
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.borderRadiusNormal,
                                  ),
                                  child: Icon(
                                    Icons.arrow_back_rounded,
                                    color: iconColor,
                                    size: res.dp(2.4),
                                  ),
                                ),
                              ),
                            ).animate().slideX(duration: 300.ms, begin: -0.1),

                            SizedBox(height: res.hp(4)),

                            // Logo
                            Center(
                              child: Hero(
                                tag: 'app_logo',
                                child: Container(
                                  width: res.dp(12),
                                  height: res.dp(12),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      res.dp(3),
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.email_outlined,
                                    color: AppTheme.primaryColor,
                                    size: res.dp(6),
                                  ),
                                ),
                              ),
                            ).animate().scale(
                              duration: 500.ms,
                              curve: Curves.elasticOut,
                            ),

                            SizedBox(height: res.hp(3)),

                            // Título y descripción
                            Text(
                                  'Verificar Email',
                                  style: TextStyle(
                                    fontSize: res.dp(2.8),
                                    fontWeight: FontWeight.w700,
                                    color: textColor,
                                  ),
                                  textAlign: TextAlign.center,
                                )
                                .animate()
                                .slideY(duration: 300.ms, begin: 0.1)
                                .fadeIn(),

                            SizedBox(height: res.hp(1)),

                            Text(
                                  'Hemos enviado un código de 4 dígitos a:\n$email',
                                  style: TextStyle(
                                    fontSize: res.dp(1.6),
                                    color: subtitleColor,
                                  ),
                                  textAlign: TextAlign.center,
                                )
                                .animate()
                                .slideY(
                                  duration: 300.ms,
                                  begin: 0.1,
                                  delay: 100.ms,
                                )
                                .fadeIn(),

                            const Spacer(),

                            // Contenido principal
                            _buildMainContent(
                              context,
                              ref,
                              res,
                              otpState,
                              authState,
                              isDark,
                            ),

                            const Spacer(flex: 2),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(
    BuildContext context,
    WidgetRef ref,
    Responsive responsive,
    OtpVerificationState otpState,
    AuthState authState,
    bool isDark,
  ) {
    return GlassCard(
      padding: EdgeInsets.all(AppTheme.spacingLarge),
      borderRadius: AppTheme.borderRadiusLarge,
      child: Column(
        children: [
          // Campo de OTP
          TextFormField(
                onChanged: ref
                    .read(otpVerificationProvider(email).notifier)
                    .onOtpChange,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 4,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                style: TextStyle(
                  fontSize: responsive.dp(2.4),
                  fontWeight: FontWeight.w600,
                  letterSpacing: responsive.dp(0.8),
                  color: isDark ? Colors.white : Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: '0000',
                  hintStyle: TextStyle(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.3),
                    fontSize: responsive.dp(2.4),
                    fontWeight: FontWeight.w600,
                    letterSpacing: responsive.dp(0.8),
                  ),
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AppTheme.borderRadiusNormal,
                    ),
                    borderSide: BorderSide(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.2)
                          : Colors.black.withValues(alpha: 0.2),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AppTheme.borderRadiusNormal,
                    ),
                    borderSide: BorderSide(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.2)
                          : Colors.black.withValues(alpha: 0.2),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AppTheme.borderRadiusNormal,
                    ),
                    borderSide: BorderSide(
                      color: AppTheme.primaryColor,
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AppTheme.borderRadiusNormal,
                    ),
                    borderSide: BorderSide(
                      color: AppTheme.errorColorLight,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.02),
                ),
              )
              .animate()
              .slideY(duration: 300.ms, begin: 0.1, delay: 200.ms)
              .fadeIn(),

          SizedBox(height: AppTheme.spacingLarge),

          // Botón de verificar
          CustomFilledButton(
                text: otpState.isVerifying ? '' : 'Verificar Código',
                isLoading: otpState.isVerifying,
                onPressed: otpState.isVerifying || !otpState.isValid
                    ? null
                    : () async {
                        await ref
                            .read(otpVerificationProvider(email).notifier)
                            .verifyOtp();
                      },
                buttonColor: AppTheme.primaryColor,
              )
              .animate()
              .slideY(duration: 300.ms, begin: 0.1, delay: 300.ms)
              .fadeIn(),

          SizedBox(height: AppTheme.spacingMedium),
        ],
      ),
    ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack);
  }

  void _showResultDialog(
    BuildContext context,
    Responsive responsive,
    bool isSuccess,
    String message,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (context) => Center(
        child: Padding(
          padding: EdgeInsets.all(AppTheme.spacingLarge),
          child: GlassCard(
            padding: EdgeInsets.all(AppTheme.spacingLarge),
            borderRadius: AppTheme.borderRadiusLarge,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSuccess ? Icons.check_circle_outline : Icons.error_outline,
                  color: isSuccess ? Colors.green : AppTheme.errorColorLight,
                  size: responsive.dp(8),
                ),
                SizedBox(height: AppTheme.spacingMedium),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: responsive.dp(1.8),
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack),
    );
  }
}
