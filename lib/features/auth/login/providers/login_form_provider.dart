import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bombotickets/features/auth/providers/auth_provider.dart';

class LoginFormState {
  final String email;
  final String password;
  final bool isPosting;
  final bool isFormPosted;
  final String? errorMessage;

  LoginFormState({
    this.email = '',
    this.password = '',
    this.isPosting = false,
    this.isFormPosted = false,
    this.errorMessage,
  });

  bool get isValid => email.isNotEmpty && password.isNotEmpty;

  LoginFormState copyWith({
    String? email,
    String? password,
    String? companyId,
    bool? isPosting,
    bool? isFormPosted,
    String? errorMessage,
  }) {
    return LoginFormState(
      email: email ?? this.email,
      password: password ?? this.password,
      isPosting: isPosting ?? this.isPosting,
      isFormPosted: isFormPosted ?? this.isFormPosted,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class LoginFormNotifier extends StateNotifier<LoginFormState> {
  final Ref ref;

  LoginFormNotifier(this.ref) : super(LoginFormState());

  void onEmailChange(String value) {
    state = state.copyWith(email: value);
  }

  void onPasswordChange(String value) {
    state = state.copyWith(password: value);
  }

  Future<void> onFormSubmit() async {
    state = state.copyWith(isPosting: true, errorMessage: null);

    try {
      await ref
          .read(authProvider.notifier)
          .loginUser(email: state.email, password: state.password);
    } catch (e) {
      state = state.copyWith(isPosting: false, errorMessage: e.toString());
    } finally {
      state = state.copyWith(isPosting: false);
    }
  }
}

final loginFormProvider =
    StateNotifierProvider.autoDispose<LoginFormNotifier, LoginFormState>((ref) {
      return LoginFormNotifier(ref);
    });
