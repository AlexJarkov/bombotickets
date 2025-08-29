import 'package:bombotickets/features/shared/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bombotickets/features/auth/login/providers/login_form_provider.dart';
import 'package:bombotickets/features/auth/providers/auth_provider.dart';
import 'package:bombotickets/features/shared/widgets/custom_filled_button.dart';
import 'package:bombotickets/features/shared/widgets/custom_input_field.dart';
import 'package:go_router/go_router.dart';
import 'package:bombotickets/config/theme/theme.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});
  static const name = 'login';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final res = Responsive.of(context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryColor,
              AppTheme.primaryColor.withOpacity(0.7),
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: res.wp(6),
                        vertical: res.hp(6),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: res.hp(4)),
                          Image.asset(
                            'assets/images/logo_masterpass.png',
                            width: res.wp(60),
                          ),
                          SizedBox(height: res.hp(4)),
                          _LoginForm(),
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
    );
  }
}

class _LoginForm extends ConsumerStatefulWidget {
  const _LoginForm();

  @override
  ConsumerState<_LoginForm> createState() => __LoginFormState();
}

class __LoginFormState extends ConsumerState<_LoginForm> {
  final isPasswordVisible = ValueNotifier<bool>(false);
  final isPasswordFocused = ValueNotifier<bool>(false);

  @override
  void dispose() {
    isPasswordVisible.dispose();
    isPasswordFocused.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginForm = ref.watch(loginFormProvider);
    final authState = ref.watch(authProvider);
    final colors = Theme.of(context).colorScheme;
    final Responsive responsive = Responsive.of(context);

    ref.listen(authProvider, (previous, next) async {
      if (next.status == AuthStatus.authenticated &&
          previous?.status != next.status) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sesión iniciada correctamente'),
              backgroundColor: Colors.green,
            ),
          );
          await Future.delayed(const Duration(milliseconds: 1000));
          context.pushReplacement('/home');
        }
      }
    });

    return Container(
      padding: EdgeInsets.all(responsive.dp(24)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(responsive.dp(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: responsive.dp(10),
            spreadRadius: responsive.dp(2),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(height: responsive.hp(2)),
          Image.asset(
            'assets/images/logo_masterpass.png',
            width: responsive.wp(40),
            height: responsive.hp(10),
            fit: BoxFit.contain,
          ),
          SizedBox(height: responsive.hp(2)),
          if (authState.status == AuthStatus.authenticated)
            _StatusMessage(
              message: 'Sesión iniciada correctamente',
              isError: false,
            )
          else if (authState.errorMessage != null)
            _StatusMessage(message: authState.errorMessage!, isError: true)
          else if (loginForm.errorMessage != null)
            _StatusMessage(message: loginForm.errorMessage!, isError: true),

          SizedBox(height: responsive.hp(2)),

          CustomInputField(
            label: 'Código de Usuario',
            keyboardType: TextInputType.text,
            prefixIcon: Icons.person_outline,
            onChanged: ref.read(loginFormProvider.notifier).onUsernameChange,
            errorMessage: loginForm.isFormPosted && loginForm.username.isEmpty
                ? 'El código de usuario es requerido'
                : null,
            isFormPosted: loginForm.isFormPosted,
          ),

          SizedBox(height: responsive.hp(2)),

          Focus(
            onFocusChange: (hasFocus) {
              isPasswordFocused.value = hasFocus;
            },
            child: ValueListenableBuilder<bool>(
              valueListenable: isPasswordFocused,
              builder: (context, hasFocus, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ValueListenableBuilder<bool>(
                      valueListenable: isPasswordVisible,
                      builder: (context, value, child) {
                        return CustomInputField(
                          label: 'Contraseña',
                          obscureText: !value,
                          prefixIcon: Icons.lock_outline,
                          suffixIcon: IconButton(
                            icon: Icon(
                              value ? Icons.visibility_off : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () => isPasswordVisible.value = !value,
                          ),
                          onChanged: ref
                              .read(loginFormProvider.notifier)
                              .onPasswordChange,
                          errorMessage:
                              loginForm.isFormPosted &&
                                  loginForm.password.isEmpty
                              ? 'La contraseña es requerida'
                              : null,
                          isFormPosted: loginForm.isFormPosted,
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),

          SizedBox(height: responsive.hp(3)),

          CustomFilledButton(
            text: 'Entrar',
            onPressed: loginForm.isValid && !loginForm.isPosting
                ? () => ref.read(loginFormProvider.notifier).onFormSubmit()
                : null,
            isLoading: loginForm.isPosting,
            isEnabled: loginForm.isValid,
            buttonColor: colors.primary,
          ),

          SizedBox(height: responsive.hp(3)),

          TextButton(
            onPressed: () => context.push('/register'),
            child: Text(
              '¿No tienes cuenta? Crea una aquí',
              style: TextStyle(color: colors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusMessage extends StatelessWidget {
  final String message;
  final bool isError;

  const _StatusMessage({required this.message, required this.isError});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isError ? Colors.red[100] : Colors.green[100],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isError ? Colors.red : Colors.green),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: isError ? Colors.red[800] : Colors.green[800],
          fontSize: 14,
        ),
      ),
    );
  }
}
