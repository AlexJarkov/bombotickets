import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bombotickets/config/environment.dart';

class QrScannerRepository {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: Environment.apiUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
    ),
  );

  Future<String> scanQrFromFile(File imageFile) async {
    try {
      // Obtener el token de SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception(
          'Token de autenticación no disponible. Por favor, inicia sesión nuevamente.',
        );
      }

      // Crear FormData con el archivo
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'qr_image.${imageFile.path.split('.').last}',
        ),
      });

      final response = await _dio.post(
        '/read-qr-from-file',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200) {
        final result = response.data.toString();
        return result;
      } else {
        throw Exception(
          'Error al procesar la imagen: ${response.statusMessage}',
        );
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response?.data != null) {
          // Intentar extraer mensaje de error del servidor
          final errorData = e.response!.data;
          if (errorData is Map && errorData.containsKey('message')) {
            throw Exception('Error del servidor: ${errorData['message']}');
          } else if (errorData is Map && errorData.containsKey('error')) {
            throw Exception('Error del servidor: ${errorData['error']}');
          } else {
            throw Exception('Error del servidor: ${errorData.toString()}');
          }
        } else {
          throw Exception('Error de conexión: ${e.message}');
        }
      }
      throw Exception('Error al escanear QR: $e');
    }
  }
}
