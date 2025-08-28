import 'package:bombotickets/features/auth/providers/auth_provider.dart';
import 'package:bombotickets/features/auth/register/providers/register_form_provider.dart';
import 'package:bombotickets/features/shared/widgets/custom_filled_button.dart';
import 'package:bombotickets/features/shared/widgets/custom_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

class RegisterScreen extends ConsumerWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colors.primary,
              colors.primary.withOpacity(0.5),
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
                        vertical: 32,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 16),
                          _BackButton(),
                          const SizedBox(height: 16),
                          const _BrandingSection(),
                          const SizedBox(height: 16),
                          const _RegisterForm(),
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

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: IconButton(
        onPressed: () =>
            context.canPop() ? context.pop() : context.go('/login'),
        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
      ),
    );
  }
}

class _BrandingSection extends StatelessWidget {
  const _BrandingSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Image.asset("assets/images/logo_si2.png", width: 400),
        const SizedBox(height: 20),
        Text(
          'Crear cuenta',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 40),
      ],
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
          if (authState.errorMessage != null)
            _StatusMessage(message: authState.errorMessage!, isError: true)
          else if (registerForm.errorMessage != null)
            _StatusMessage(message: registerForm.errorMessage!, isError: true),

          const SizedBox(height: 16),

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

          const SizedBox(height: 16),

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

          const SizedBox(height: 16),

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

          const SizedBox(height: 16),

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

          const SizedBox(height: 24),

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

          const SizedBox(height: 24),

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
