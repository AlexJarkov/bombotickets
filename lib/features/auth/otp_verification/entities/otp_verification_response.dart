class OtpVerificationResponse {
  final String mensaje;

  OtpVerificationResponse({required this.mensaje});

  factory OtpVerificationResponse.fromJson(Map<String, dynamic> json) {
    return OtpVerificationResponse(mensaje: json['mensaje'] as String);
  }
}
