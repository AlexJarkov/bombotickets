import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bombotickets/config/environment.dart';
import 'dart:convert';

class QrScannerRepository {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: Environment.apiUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
    ),
  );

  Future<String> readQrFromText(String qrContent) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception(
          'Token de autenticación no disponible. Por favor, inicia sesión nuevamente.',
        );
      }

      // Try to parse the QR content as JSON; if valid, send the object.
      dynamic parsed;
      try {
        parsed = jsonDecode(qrContent);
      } catch (_) {
        parsed = null;
      }

      final payload = (parsed is Map || parsed is List)
          ? parsed
          : {
              // Send multiple aliases to maximize backend compatibility
              'qr': qrContent,
              'data': qrContent,
              'qrData': qrContent,
              'content': qrContent,
            };

      final response = await _dio.post(
        '/read-qr',
        data: payload,
        options: Options(
          responseType: ResponseType.plain, // server may return non-JSON
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json, text/plain, */*',
          },
        ),
      );

      if (response.statusCode == 200) {
        final raw = response.data?.toString() ?? '';
        if (raw.isEmpty) return qrContent; // fallback to raw QR if no body
        try {
          final parsed = jsonDecode(raw);
          return jsonEncode(parsed);
        } catch (_) {
          return raw;
        }
      } else {
        throw Exception(
          'Error al enviar QR: ${response.statusMessage}',
        );
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response?.data != null) {
          final errorData = e.response!.data;
          if (errorData is Map && errorData.containsKey('message')) {
            throw Exception('Error del servidor: ${errorData['message']}');
          } else if (errorData is Map && errorData.containsKey('error')) {
            throw Exception('Error del servidor: ${errorData['error']}');
          } else {
            throw Exception('Error del servidor: ${errorData.toString()}');
          }
        } else {
          final msg = e.message ?? e.error?.toString() ?? 'Sin respuesta del servidor';
          throw Exception('Error de conexión: $msg');
        }
      }
      throw Exception('Error al enviar QR: $e');
    }
  }

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
          final msg = e.message ?? e.error?.toString() ?? 'Sin respuesta del servidor';
          throw Exception('Error de conexión: $msg');
        }
      }
      throw Exception('Error al escanear QR: $e');
    }
  }
}
