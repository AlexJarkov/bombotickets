import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SplashStatus { loading, checkingAuth, navigateToLogin, navigateToHome }

class SplashState {
  final SplashStatus status;
  final String? errorMessage;

  const SplashState({this.status = SplashStatus.loading, this.errorMessage});

  SplashState copyWith({SplashStatus? status, String? errorMessage}) {
    return SplashState(
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }
}

class SplashNotifier extends StateNotifier<SplashState> {
  final Ref ref;

  SplashNotifier(this.ref) : super(const SplashState());

  Future<void> checkAuthentication() async {
    try {
      state = state.copyWith(status: SplashStatus.checkingAuth);

      // Check if we have stored Bearer token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      log("Splash: Checking stored token - token: ${token != null}");

      // Add a minimum splash duration for smooth UX
      await Future.delayed(const Duration(milliseconds: 1500));

      if (token != null && token.isNotEmpty) {
        // We have a token, assume user is authenticated
        // In a real app, you might want to validate the token here
        state = state.copyWith(status: SplashStatus.navigateToHome);
        log("Splash: Navigating to home - user has valid token");
      } else {
        // No token, user needs to login
        state = state.copyWith(status: SplashStatus.navigateToLogin);
        log("Splash: Navigating to login - no token found");
      }
    } catch (e) {
      log("Splash: Error checking authentication - $e");
      // On error, navigate to login for safety
      state = state.copyWith(
        status: SplashStatus.navigateToLogin,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() {
    state = const SplashState();
  }
}

final splashProvider = StateNotifierProvider<SplashNotifier, SplashState>((
  ref,
) {
  return SplashNotifier(ref);
});
