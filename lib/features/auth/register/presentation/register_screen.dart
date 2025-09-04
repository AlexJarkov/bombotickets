import 'package:bombotickets/features/shared/utils/responsive.dart';
import 'package:bombotickets/features/auth/providers/auth_provider.dart';
import 'package:bombotickets/features/auth/register/providers/register_form_provider.dart';
import 'package:bombotickets/features/shared/widgets/custom_filled_button.dart';
import 'package:bombotickets/features/shared/widgets/custom_input_field.dart';
import 'package:bombotickets/features/shared/widgets/animated_background.dart';
import 'package:bombotickets/features/shared/widgets/glass_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bombotickets/config/theme/app_theme_new.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class RegisterScreen extends ConsumerWidget {
  static String name = 'register';

  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final res = Responsive.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Colores dinámicos según el modo
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark
        ? Colors.white.withValues(alpha: 0.8)
        : Colors.black54;
    final iconColor = isDark ? Colors.white : Colors.black87;
    // Logo con tint claro/oscuro para integrarse con el tema

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
                            SizedBox(height: AppTheme.spacingSmall), // Reducido
                            // Botón de regresar
                            Align(
                                  alignment: Alignment.topLeft,
                                  child: GlassCard(
                                    padding: EdgeInsets.all(
                                      AppTheme.spacingSmall,
                                    ),
                                    borderRadius: AppTheme.borderRadiusNormal,
                                    child: InkWell(
                                      onTap: () => context.canPop()
                                          ? context.pop()
                                          : context.go('/login'),
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
                                )
                                .animate()
                                .slideX(
                                  duration: 200.ms,
                                  begin: -0.1, // Movimiento más sutil
                                  end: 0,
                                  curve: Curves.fastOutSlowIn,
                                )
                                .fadeIn(
                                  duration: 200.ms,
                                  curve: Curves.fastOutSlowIn,
                                ),

                            SizedBox(
                              height: res.hp(0.5),
                            ), // Reducido de 2 a 0.5 para subir el logo
                            // Logo
                            Center(
                              child:
                                  Hero(
                                        tag: 'app_logo',
                                        flightShuttleBuilder:
                                            (
                                              flightContext,
                                              animation,
                                              flightDirection,
                                              fromHeroContext,
                                              toHeroContext,
                                            ) {
                                              final curved = CurvedAnimation(
                                                parent: animation,
                                                curve: Curves.easeOutCubic,
                                              );
                                              return FadeTransition(
                                                opacity: Tween(
                                                  begin: 0.95,
                                                  end: 1.0,
                                                ).animate(curved),
                                                child: ScaleTransition(
                                                  scale:
                                                      Tween(
                                                            begin: 0.98,
                                                            end: 1.04,
                                                          )
                                                          .chain(
                                                            CurveTween(
                                                              curve: Curves
                                                                  .easeOutCubic,
                                                            ),
                                                          )
                                                          .animate(curved),
                                                  child: toHeroContext.widget,
                                                ),
                                              );
                                            },
                                        child: ColorFiltered(
                                          colorFilter: ColorFilter.mode(
                                            isDark
                                                ? Colors.white
                                                : Colors.black,
                                            BlendMode.srcIn,
                                          ),
                                          child: Image.asset(
                                            'assets/images/logo_masterpass.png',
                                            width: res.wp(48),
                                            height: res.wp(48),
                                          ),
                                        ),
                                      )
                                      .animate()
                                      .scale(
                                        duration: 300.ms,
                                        curve: Curves.easeOutCubic,
                                        begin: const Offset(0.98, 0.98),
                                        end: const Offset(1.0, 1.0),
                                      )
                                      .fadeIn(
                                        duration: 320.ms,
                                        curve: Curves.easeOutCubic,
                                        delay: 40.ms,
                                      ),
                            ),

                            SizedBox(height: res.hp(2)), // Reducido de 3 a 2
                            // Título
                            Text(
                                  'Crear Cuenta',
                                  style: GoogleFonts.inter(
                                    fontSize: res.dp(2.8),
                                    fontWeight: FontWeight.w700,
                                    color: textColor,
                                  ),
                                  textAlign: TextAlign.center,
                                )
                                .animate()
                                .slideY(
                                  duration: 360.ms,
                                  begin: 0.12, // alineado con login
                                  end: 0,
                                  curve: Curves.easeOutCubic,
                                  delay: 160.ms,
                                )
                                .fadeIn(
                                  duration: 360.ms,
                                  delay: 160.ms,
                                  curve: Curves.easeOutCubic,
                                ),

                            SizedBox(height: res.hp(1)),

                            Text(
                                  'Completa los datos para registrarte',
                                  style: GoogleFonts.inter(
                                    fontSize: res.dp(1.8),
                                    color: subtitleColor,
                                  ),
                                  textAlign: TextAlign.center,
                                )
                                .animate()
                                .slideY(
                                  duration: 360.ms,
                                  begin: 0.12,
                                  end: 0,
                                  curve: Curves.easeOutCubic,
                                  delay: 220.ms,
                                )
                                .fadeIn(
                                  duration: 360.ms,
                                  delay: 220.ms,
                                  curve: Curves.easeOutCubic,
                                ),

                            SizedBox(height: res.hp(2)), // Reducido de 3 a 2
                            // Formulario
                            _RegisterForm()
                                .animate()
                                .slideY(
                                  duration: 420.ms,
                                  begin: 0.14,
                                  end: 0,
                                  curve: Curves.easeOutCubic,
                                  delay: 280.ms,
                                )
                                .fadeIn(
                                  duration: 380.ms,
                                  delay: 300.ms,
                                  curve: Curves.easeOutCubic,
                                ),

                            SizedBox(height: res.hp(2)), // Reducido de 4 a 2

                            const Spacer(), // Agregar spacer para mejor distribución

                            const Spacer(),
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
}

class _RegisterForm extends ConsumerStatefulWidget {
  const _RegisterForm();

  @override
  ConsumerState<_RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends ConsumerState<_RegisterForm> {
  @override
  Widget build(BuildContext context) {
    final registerForm = ref.watch(registerFormProvider);
    final authState = ref.watch(authProvider);
    final Responsive responsive = Responsive.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final linkColor = isDark ? Colors.white : AppTheme.primaryColor;

    // Limpiar errores del auth provider al entrar a registro
    ref.listen(authProvider, (previous, next) {
      if (previous == null) {
        // Primera vez que se monta el widget
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(authProvider.notifier).clearError();
        });
      }

      if (next.status == AuthStatus.registrationSuccess &&
          previous?.status != next.status) {
        if (context.mounted) {
          // Mostrar overlay con GlassCard de éxito
          showDialog(
            context: context,
            barrierDismissible: false,
            barrierColor: Colors.black.withValues(alpha: 0.3),
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
                        Icons.check_circle_outline,
                        color: Colors.green[600],
                        size: responsive.dp(6),
                      ),
                      SizedBox(height: AppTheme.spacingMedium),
                      Text(
                        'Registro Exitoso',
                        style: GoogleFonts.inter(
                          fontSize: responsive.dp(2.2),
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: AppTheme.spacingSmall),
                      Text(
                        'Su cuenta ha sido creada correctamente.\nSerá redirigido al inicio de sesión.',
                        style: GoogleFonts.inter(
                          fontSize: responsive.dp(1.6),
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );

          // Redirigir después del delay
          Future.delayed(const Duration(milliseconds: 2500), () {
            if (!context.mounted) return;
            Navigator.of(context).pop(); // Cerrar dialog
            context.go('/login');
          });
        }
      }
    });

    return GlassCard(
      padding: EdgeInsets.all(AppTheme.spacingLarge),
      borderRadius: AppTheme.borderRadiusLarge,
      child: Column(
        children: [
          // Mensajes de error
          if (authState.errorMessage != null)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppTheme.spacingNormal),
              margin: EdgeInsets.only(bottom: AppTheme.spacingMedium),
              decoration: BoxDecoration(
                color: AppTheme.errorColorLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(
                  AppTheme.borderRadiusNormal,
                ),
                border: Border.all(
                  color: AppTheme.errorColorLight.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                authState.errorMessage!,
                style: GoogleFonts.inter(
                  color: AppTheme.errorColorLight,
                  fontSize: responsive.dp(1.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          else if (registerForm.errorMessage != null)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppTheme.spacingNormal),
              margin: EdgeInsets.only(bottom: AppTheme.spacingMedium),
              decoration: BoxDecoration(
                color: AppTheme.errorColorLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(
                  AppTheme.borderRadiusNormal,
                ),
                border: Border.all(
                  color: AppTheme.errorColorLight.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                registerForm.errorMessage!,
                style: GoogleFonts.inter(
                  color: AppTheme.errorColorLight,
                  fontSize: responsive.dp(1.6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

          CustomInputField(
            label: 'Nombre de usuario',
            prefixIcon: Icons.person_outline,
            onChanged: ref.read(registerFormProvider.notifier).onUsernameChange,
            errorMessage:
                registerForm.isFormPosted && registerForm.username.isEmpty
                ? 'El nombre es requerido'
                : null,
            isFormPosted: registerForm.isFormPosted,
          ),

          SizedBox(height: responsive.hp(2.5)),

          CustomInputField(
            label: 'Correo electrónico',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            onChanged: ref.read(registerFormProvider.notifier).onEmailChange,
            errorMessage:
                registerForm.isFormPosted && registerForm.email.isEmpty
                ? 'El correo es requerido'
                : null,
            isFormPosted: registerForm.isFormPosted,
          ),

          SizedBox(height: responsive.hp(2.5)),

          CustomInputField(
            label: 'Contraseña',
            prefixIcon: Icons.lock_outline,
            obscureText: true,
            onChanged: ref.read(registerFormProvider.notifier).onPasswordChange,
            errorMessage:
                registerForm.isFormPosted && registerForm.password.isEmpty
                ? 'La contraseña es requerida'
                : null,
            isFormPosted: registerForm.isFormPosted,
          ),

          SizedBox(height: responsive.hp(2.5)),

          CustomInputField(
            label: 'Confirmar contraseña',
            prefixIcon: Icons.lock_outline,
            obscureText: true,
            onChanged: ref
                .read(registerFormProvider.notifier)
                .onPassword2Change,
            errorMessage:
                registerForm.password.isNotEmpty &&
                    registerForm.password2.isNotEmpty &&
                    registerForm.password != registerForm.password2
                ? 'Las contraseñas no coinciden'
                : registerForm.isFormPosted && registerForm.password2.isEmpty
                ? 'Confirme su contraseña'
                : null,
            isFormPosted: true, // Cambiado para mostrar errores en tiempo real
          ),

          SizedBox(height: responsive.hp(4)),

          CustomFilledButton(
            text: 'Crear cuenta',
            isLoading: registerForm.isPosting,
            onPressed: registerForm.isPosting || !registerForm.isValid
                ? null
                : () async {
                    await ref
                        .read(registerFormProvider.notifier)
                        .onFormSubmit();
                  },
            buttonColor: AppTheme.primaryColor,
          ),

          SizedBox(height: AppTheme.spacingLarge),

          // Enlace de login
          Center(
            child: GestureDetector(
              onTap: () =>
                  context.canPop() ? context.pop() : context.go('/login'),
              child: Text(
                '¿Ya tienes cuenta? Iniciar sesión',
                style: GoogleFonts.inter(
                  color: linkColor,
                  fontSize: responsive.dp(1.6),
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.none,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
