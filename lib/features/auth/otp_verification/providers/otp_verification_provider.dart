import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bombotickets/features/auth/providers/auth_provider.dart';

class OtpVerificationState {
  final String email;
  final String otpCode;
  final bool isVerifying;
  final bool isFormPosted;
  final String? errorMessage;
  final String? successMessage;

  OtpVerificationState({
    this.email = '',
    this.otpCode = '',
    this.isVerifying = false,
    this.isFormPosted = false,
    this.errorMessage,
    this.successMessage,
  });

  bool get isValid => otpCode.length == 4 && email.isNotEmpty;

  OtpVerificationState copyWith({
    String? email,
    String? otpCode,
    bool? isVerifying,
    bool? isFormPosted,
    String? errorMessage,
    String? successMessage,
  }) {
    return OtpVerificationState(
      email: email ?? this.email,
      otpCode: otpCode ?? this.otpCode,
      isVerifying: isVerifying ?? this.isVerifying,
      isFormPosted: isFormPosted ?? this.isFormPosted,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
    );
  }
}

class OtpVerificationNotifier extends StateNotifier<OtpVerificationState> {
  final Ref ref;

  OtpVerificationNotifier(this.ref, String email)
    : super(OtpVerificationState(email: email));

  void onOtpChange(String value) {
    // Solo permitir números y máximo 4 dígitos
    final numericValue = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (numericValue.length <= 4) {
      state = state.copyWith(
        otpCode: numericValue,
        errorMessage: null,
        successMessage: null,
      );
    }
  }

  void clearMessages() {
    state = state.copyWith(errorMessage: null, successMessage: null);
  }

  void setSuccessMessage(String message) {
    state = state.copyWith(successMessage: message);
  }

  Future<void> verifyOtp() async {
    if (!state.isValid) {
      state = state.copyWith(
        isFormPosted: true,
        errorMessage: 'Por favor ingresa un código de 4 dígitos',
      );
      return;
    }

    state = state.copyWith(
      isVerifying: true,
      errorMessage: null,
      successMessage: null,
      isFormPosted: true,
    );

    try {
      final successMessage = await ref
          .read(authProvider.notifier)
          .verifyOtp(email: state.email, codigo: state.otpCode);

      state = state.copyWith(
        isVerifying: false,
        successMessage: successMessage,
      );
    } catch (e) {
      state = state.copyWith(isVerifying: false, errorMessage: e.toString());
    }
  }
}

final otpVerificationProvider = StateNotifierProvider.family
    .autoDispose<OtpVerificationNotifier, OtpVerificationState, String>((
      ref,
      email,
    ) {
      return OtpVerificationNotifier(ref, email);
    });
