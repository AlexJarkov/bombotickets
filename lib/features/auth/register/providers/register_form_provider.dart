import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bombotickets/features/auth/providers/auth_provider.dart';

class RegisterFormState {
  final String username;
  final String email;
  final String password;
  final String password2;
  final bool isPosting;
  final bool isFormPosted;
  final String? errorMessage;

  RegisterFormState({
    this.username = '',
    this.email = '',
    this.password = '',
    this.password2 = '',
    this.isPosting = false,
    this.isFormPosted = false,
    this.errorMessage,
  });

  bool get isValid =>
      username.isNotEmpty &&
      email.isNotEmpty &&
      password.isNotEmpty &&
      password == password2;

  RegisterFormState copyWith({
    String? username,
    String? email,
    String? password,
    String? password2,
    bool? isPosting,
    bool? isFormPosted,
    String? errorMessage,
  }) {
    return RegisterFormState(
      username: username ?? this.username,
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

  void onUsernameChange(String value) {
    state = state.copyWith(username: value);
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
            username: state.username,
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
