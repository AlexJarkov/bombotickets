class RegisterResponse {
  final int id;
  final String nombres;
  final String apellidoP;
  final String apellidoM;
  final String email;
  final bool verificado;
  final String codigoOtp;
  final String otpExpira;
  final String password;
  final String? numeroCuenta;
  final String? nombreBanca;
  final String? imagen;
  final String? descripcion;
  final String? ci;

  RegisterResponse({
    required this.id,
    required this.nombres,
    required this.apellidoP,
    required this.apellidoM,
    required this.email,
    required this.verificado,
    required this.codigoOtp,
    required this.otpExpira,
    required this.password,
    this.numeroCuenta,
    this.nombreBanca,
    this.imagen,
    this.descripcion,
    this.ci,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      id: json['id'] as int,
      nombres: json['nombres'] as String,
      apellidoP: json['apellidoP'] as String,
      apellidoM: json['apellidoM'] as String,
      email: json['email'] as String,
      verificado: json['verificado'] as bool,
      codigoOtp: json['codigoOtp'] as String,
      otpExpira: json['otpExpira'] as String,
      password: json['password'] as String,
      numeroCuenta: json['numeroCuenta'] as String?,
      nombreBanca: json['nombreBanca'] as String?,
      imagen: json['imagen'] as String?,
      descripcion: json['descripcion'] as String?,
      ci: json['ci'] as String?,
    );
  }
}
