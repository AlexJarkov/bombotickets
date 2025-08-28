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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 48,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: 40),
                          Icon(
                            Icons.confirmation_number,
                            size: 64,
                            color: AppTheme.primaryColor,
                          ),
                          SizedBox(height: 24),
                          Text(
                            'Bombotickets',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.bodyFontColor,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Tu app de tickets',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.bodyFontColor,
                            ),
                          ),
                          SizedBox(height: 32),
                          _LoginForm(),
                          Spacer(),
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          if (authState.status == AuthStatus.authenticated)
            _StatusMessage(
              message: 'Sesión iniciada correctamente',
              isError: false,
            )
          else if (authState.errorMessage != null)
            _StatusMessage(message: authState.errorMessage!, isError: true)
          else if (loginForm.errorMessage != null)
            _StatusMessage(message: loginForm.errorMessage!, isError: true),

          const SizedBox(height: 16),

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

          const SizedBox(height: 16),

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

          const SizedBox(height: 24),

          CustomFilledButton(
            text: 'Entrar',
            onPressed: loginForm.isValid && !loginForm.isPosting
                ? () => ref.read(loginFormProvider.notifier).onFormSubmit()
                : null,
            isLoading: loginForm.isPosting,
            isEnabled: loginForm.isValid,
            buttonColor: colors.primary,
          ),

          const SizedBox(height: 24),

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
