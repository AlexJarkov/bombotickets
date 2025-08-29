import 'package:bombotickets/features/shared/utils/responsive.dart';
import 'package:bombotickets/features/auth/providers/auth_provider.dart';
import 'package:bombotickets/features/auth/register/providers/register_form_provider.dart';
import 'package:bombotickets/features/shared/widgets/custom_filled_button.dart';
import 'package:bombotickets/features/shared/widgets/custom_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';
import 'package:bombotickets/config/theme/theme.dart';

class RegisterScreen extends ConsumerWidget {
  static String name = 'register';

  const RegisterScreen({super.key});

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
                          Align(
                            alignment: Alignment.topLeft,
                            child: IconButton(
                              onPressed: () => context.canPop()
                                  ? context.pop()
                                  : context.go('/login'),
                              icon: Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: res.wp(8),
                              ),
                            ),
                          ),
                          SizedBox(height: res.hp(4)),
                          Image.asset(
                            'assets/images/logo_masterpass.png',
                            width: res.wp(60),
                          ),
                          SizedBox(height: res.hp(4)),
                          _RegisterForm(),
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

class _RegisterForm extends ConsumerWidget {
  const _RegisterForm();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registerForm = ref.watch(registerFormProvider);
    final authState = ref.watch(authProvider);
    final colors = Theme.of(context).colorScheme;
    final Responsive responsive = Responsive.of(context);

    ref.listen(authProvider, (previous, next) {
      if (next.errorMessage != null && next.errorMessage!.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }

      if (next.status == AuthStatus.authenticated &&
          previous?.status != next.status) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registro exitoso'),
              backgroundColor: Colors.green,
            ),
          );
          context.go('/login');
        }
      }
    });

    return Container(
      padding: EdgeInsets.all(responsive.wp(6)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(responsive.wp(5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: responsive.wp(2.5),
            spreadRadius: responsive.wp(0.5),
          ),
        ],
      ),
      child: Column(
        children: [
          if (authState.errorMessage != null)
            _StatusMessage(message: authState.errorMessage!, isError: true)
          else if (registerForm.errorMessage != null)
            _StatusMessage(message: registerForm.errorMessage!, isError: true),

          if (authState.errorMessage != null ||
              registerForm.errorMessage != null)
            SizedBox(height: responsive.hp(1)),

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
                registerForm.isFormPosted &&
                    (registerForm.password2.isEmpty ||
                        registerForm.password != registerForm.password2)
                ? 'Las contraseñas no coinciden'
                : null,
            isFormPosted: registerForm.isFormPosted,
          ),

          SizedBox(height: responsive.hp(4)),

          CustomFilledButton(
            text: 'Crear cuenta',
            isLoading: registerForm.isPosting,
            onPressed: registerForm.isPosting
                ? null
                : () async {
                    if (registerForm.username.isEmpty ||
                        registerForm.email.isEmpty ||
                        registerForm.password.isEmpty ||
                        registerForm.password2.isEmpty) {
                      ref
                          .read(registerFormProvider.notifier)
                          .setError('Complete todos los campos');
                      return;
                    }

                    if (registerForm.password != registerForm.password2) {
                      ref
                          .read(registerFormProvider.notifier)
                          .setError('Las contraseñas no coinciden');
                      return;
                    }

                    await ref
                        .read(registerFormProvider.notifier)
                        .onFormSubmit();
                  },
            buttonColor: colors.primary,
          ),

          SizedBox(height: responsive.hp(3)),

          TextButton(
            onPressed: () =>
                context.canPop() ? context.pop() : context.go('/login'),
            child: Text(
              '¿Ya tienes cuenta? Inicia sesión aquí',
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
    final Responsive responsive = Responsive.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsive.wp(4)),
      margin: EdgeInsets.only(bottom: responsive.hp(2)),
      decoration: BoxDecoration(
        color: isError ? Colors.red[100] : Colors.green[100],
        borderRadius: BorderRadius.circular(responsive.wp(2.5)),
        border: Border.all(color: isError ? Colors.red : Colors.green),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: isError ? Colors.red[800] : Colors.green[800],
          fontSize: responsive.dp(1.8),
        ),
      ),
    );
  }
}
