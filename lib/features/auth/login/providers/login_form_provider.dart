import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bombotickets/features/auth/providers/auth_provider.dart';

class LoginFormState {
  final String username;
  final String password;
  final bool isPosting;
  final bool isFormPosted;
  final String? errorMessage;

  LoginFormState({
    this.username = '',
    this.password = '',
    this.isPosting = false,
    this.isFormPosted = false,
    this.errorMessage,
  });

  bool get isValid => username.isNotEmpty && password.isNotEmpty;

  LoginFormState copyWith({
    String? username,
    String? password,
    String? companyId,
    bool? isPosting,
    bool? isFormPosted,
    String? errorMessage,
  }) {
    return LoginFormState(
      username: username ?? this.username,
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

  void onUsernameChange(String value) {
    state = state.copyWith(username: value);
  }

  void onPasswordChange(String value) {
    state = state.copyWith(password: value);
  }

  Future<void> onFormSubmit() async {
    state = state.copyWith(isPosting: true, errorMessage: null);

    try {
      await ref
          .read(authProvider.notifier)
          .loginUser(username: state.username, password: state.password);
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
