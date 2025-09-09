import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bombotickets/features/auth/providers/auth_provider.dart';

class RegisterFormState {
  final String nombre;
  final String apellidoP;
  final String apellidoM;
  final String email;
  final String password;
  final String password2;
  final bool isPosting;
  final bool isFormPosted;
  final String? errorMessage;

  RegisterFormState({
    this.nombre = '',
    this.apellidoP = '',
    this.apellidoM = '',
    this.email = '',
    this.password = '',
    this.password2 = '',
    this.isPosting = false,
    this.isFormPosted = false,
    this.errorMessage,
  });

  bool get isValid =>
      nombre.isNotEmpty &&
      apellidoP.isNotEmpty &&
      apellidoM.isNotEmpty &&
      email.isNotEmpty &&
      password.isNotEmpty &&
      password == password2;

  RegisterFormState copyWith({
    String? nombre,
    String? apellidoP,
    String? apellidoM,
    String? email,
    String? password,
    String? password2,
    bool? isPosting,
    bool? isFormPosted,
    String? errorMessage,
  }) {
    return RegisterFormState(
      nombre: nombre ?? this.nombre,
      apellidoP: apellidoP ?? this.apellidoP,
      apellidoM: apellidoM ?? this.apellidoM,
      email: email ?? this.email,
      password: password ?? this.password,
      password2: password2 ?? this.password2,
      isPosting: isPosting ?? this.isPosting,
      isFormPosted: isFormPosted ?? this.isFormPosted,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class RegisterFormNotifier extends StateNotifier<RegisterFormState> {
  final Ref ref;

  RegisterFormNotifier(this.ref) : super(RegisterFormState());

  void onNombreChange(String value) {
    state = state.copyWith(nombre: value);
  }

  void onApellidoPChange(String value) {
    state = state.copyWith(apellidoP: value);
  }

  void onApellidoMChange(String value) {
    state = state.copyWith(apellidoM: value);
  }

  void onEmailChange(String value) {
    state = state.copyWith(email: value);
  }

  void onPasswordChange(String value) {
    state = state.copyWith(password: value);
  }

  void onPassword2Change(String value) {
    state = state.copyWith(password2: value);
  }

  void setError(String error) {
    state = state.copyWith(isFormPosted: true, errorMessage: error);
  }

  Future<void> onFormSubmit() async {
    state = state.copyWith(isPosting: true, errorMessage: null);

    try {
      await ref
          .read(authProvider.notifier)
          .registerUser(
            nombre: state.nombre,
            apellidoP: state.apellidoP,
            apellidoM: state.apellidoM,
            email: state.email,
            password: state.password,
          );
    } catch (e) {
      state = state.copyWith(isPosting: false, errorMessage: e.toString());
    } finally {
      state = state.copyWith(isPosting: false);
    }
  }
}

final registerFormProvider =
    StateNotifierProvider.autoDispose<RegisterFormNotifier, RegisterFormState>((
      ref,
    ) {
      return RegisterFormNotifier(ref);
    });
