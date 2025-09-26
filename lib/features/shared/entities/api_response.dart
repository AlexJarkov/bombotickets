import 'dart:convert';
import 'dart:developer';

class ApiResponse<T> {
  final int codigo;
  final String mensaje;
  final T? data;

  ApiResponse({required this.codigo, required this.mensaje, this.data});

  factory ApiResponse.fromJson(
    dynamic responseData,
    T? Function(dynamic)? fromJsonT,
  ) {
    try {
      // Parsing centralizado: convertir String a Map si es necesario
      Map<String, dynamic> json;
      if (responseData is String) {
        // log('ApiResponse: Parsing String response to JSON');
        json = jsonDecode(responseData) as Map<String, dynamic>;
      } else if (responseData is Map<String, dynamic>) {
        json = responseData;
      } else {
        log('ApiResponse: Unexpected data type: ${responseData.runtimeType}');
        throw Exception('Unexpected response data type');
      }

      // log('ApiResponse: Processing parsed JSON: $json');

      return ApiResponse<T>(
        codigo: json['codigo'] as int,
        mensaje: json['mensaje'] as String,
        data: json['data'] != null && fromJsonT != null
            ? fromJsonT(json['data'])
            : null,
      );
    } catch (e) {
      log('ApiResponse parsing error: $e');
      return ApiResponse<T>(
        codigo: 500,
        mensaje: 'Error al procesar respuesta del servidor',
      );
    }
  }
}
