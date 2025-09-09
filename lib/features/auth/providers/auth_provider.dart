import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bombotickets/features/auth/entities/user.dart';
import 'package:bombotickets/features/auth/repositories/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

      log("Login successful: $response");

      // Retrieve stored token to guarantee non-null String
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null || token.isEmpty) {
        throw Exception('Token de autenticación no disponible tras el inicio de sesión');
      }

      final user = User(
        username: (response is Map && response['email'] is String && (response['email'] as String).isNotEmpty)
            ? response['email'] as String
            : email,
        token: token,
      );

      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } on Exception catch (e) {
      log("Login error: ${e.toString()}");
      state = state.copyWith(
        status: AuthStatus.notAuthenticated,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
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

      log("Register successful: $response");

      // After successful registration, set status to registrationSuccess
      // so the register screen can show success toast and redirect to OTP verification
      state = state.copyWith(status: AuthStatus.registrationSuccess);
    } on Exception catch (e) {
      log("Register error: ${e.toString()}");
      state = state.copyWith(
        status: AuthStatus.notAuthenticated,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
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

      log("OTP verification successful: $response");

      // After successful OTP verification, redirect to login
      state = state.copyWith(status: AuthStatus.notAuthenticated);

      // Return the response message
      return response is String
          ? response
          : 'Correo verificado correctamente ✅';
    } on Exception catch (e) {
      log("OTP verification error: ${e.toString()}");
      state = state.copyWith(
        status: AuthStatus.notAuthenticated,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
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
