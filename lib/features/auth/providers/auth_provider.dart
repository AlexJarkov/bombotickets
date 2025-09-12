import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bombotickets/features/auth/entities/user.dart';
import 'package:bombotickets/features/auth/repositories/auth_repository.dart';

enum AuthStatus {
  checking,
  authenticated,
  notAuthenticated,
  registrationSuccess,
}

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;

  AuthState({this.status = AuthStatus.checking, this.user, this.errorMessage});

  AuthState copyWith({AuthStatus? status, User? user, String? errorMessage}) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository authRepository;

  AuthNotifier({required this.authRepository}) : super(AuthState());

  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.checking, errorMessage: null);

    try {
      final response = await authRepository.login(email, password);

      log("Login response: ${response.mensaje}");

      if (response.codigo == 200 && response.data != null) {
        final user = User(
          username: response.data!.email,
          token: response.data!.token,
        );

        state = state.copyWith(status: AuthStatus.authenticated, user: user);
      } else {
        state = state.copyWith(
          status: AuthStatus.notAuthenticated,
          errorMessage: response.mensaje,
        );
      }
    } catch (e) {
      log("Login error: ${e.toString()}");
      state = state.copyWith(
        status: AuthStatus.notAuthenticated,
        errorMessage: 'Error de conexión',
      );
    }
  }

  Future<void> registerUser({
    required String nombre,
    required String apellidoP,
    required String apellidoM,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.checking, errorMessage: null);
    try {
      final response = await authRepository.register(
        nombre,
        apellidoP,
        apellidoM,
        email,
        password,
      );

      log("Register response: ${response.mensaje}");

      if (response.codigo == 201) {
        state = state.copyWith(status: AuthStatus.registrationSuccess);
      } else {
        state = state.copyWith(
          status: AuthStatus.notAuthenticated,
          errorMessage: response.mensaje,
        );
      }
    } catch (e) {
      log("Register error: ${e.toString()}");
      state = state.copyWith(
        status: AuthStatus.notAuthenticated,
        errorMessage: 'Error de conexión',
      );
    }
  }

  Future<String> verifyOtp({
    required String email,
    required String codigo,
  }) async {
    state = state.copyWith(status: AuthStatus.checking, errorMessage: null);
    try {
      final response = await authRepository.verifyOtp(email, codigo);

      log("OTP verification response: ${response.mensaje}");

      if (response.codigo == 201) {
        state = state.copyWith(status: AuthStatus.notAuthenticated);
        return response.mensaje;
      } else {
        state = state.copyWith(
          status: AuthStatus.notAuthenticated,
          errorMessage: response.mensaje,
        );
        throw Exception(response.mensaje);
      }
    } catch (e) {
      log("OTP verification error: ${e.toString()}");
      state = state.copyWith(
        status: AuthStatus.notAuthenticated,
        errorMessage: 'Error de conexión',
      );
      rethrow;
    }
  }

  Future<void> logout() async {
    await authRepository.logout();
    state = AuthState(status: AuthStatus.notAuthenticated);
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  void clearState() {
    state = AuthState(status: AuthStatus.notAuthenticated);
  }

  void showState() {
    log("USER: ${state.user}");
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(authRepository: AuthRepository());
});
