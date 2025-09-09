import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bombotickets/config/environment.dart';

class AuthRepository {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: Environment.apiUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
    ),
  );

  Future<dynamic> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/login',
        data: {'email': email, 'password': password},
      );
      if (response.statusCode == 200) {
        // Extract token from body or headers robustly
        String? token;

        final data = response.data;
        if (data is Map) {
          // Direct keys
          final directToken = data['token'] ?? data['access_token'] ?? data['accessToken'];
          if (directToken is String && directToken.isNotEmpty) {
            token = directToken;
          }

          // Nested under data
          if (token == null) {
            final nestedData = data['data'];
            if (nestedData is Map) {
              final nestedToken = nestedData['token'] ?? nestedData['access_token'] ?? nestedData['accessToken'];
              if (nestedToken is String && nestedToken.isNotEmpty) {
                token = nestedToken;
              }
            }
          }

          // Nested under user
          if (token == null) {
            final userMap = data['user'];
            if (userMap is Map) {
              final userToken = userMap['token'] ?? userMap['access_token'] ?? userMap['accessToken'];
              if (userToken is String && userToken.isNotEmpty) {
                token = userToken;
              }
            }
          }
        }

        // Check Authorization header
        if (token == null) {
          final authHeader = response.headers.value('authorization') ?? response.headers.value('Authorization');
          if (authHeader != null && authHeader.toLowerCase().startsWith('bearer ')) {
            token = authHeader.substring(7).trim();
          }
        }

        if (token == null || token.isEmpty) {
          throw Exception('Token de autenticación no recibido del servidor');
        }

        // Store the Bearer token in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);

        return response.data;
      } else {
        throw Exception('Error al iniciar sesión: ${response.statusMessage}');
      }
    } catch (e) {
      if (e is DioException) {
        throw Exception(
          'Error al iniciar sesión: ${e.response?.data ?? e.message}',
        );
      }
      throw Exception('Error al iniciar sesión: $e');
    }
  }

  Future<dynamic> register(
    String nombre,
    String apellidoP,
    String apellidoM,
    String email,
    String password,
  ) async {
    try {
      final response = await _dio.post(
        '/signup',
        data: {
          'nombre': nombre,
          'apellidoP': apellidoP,
          'apellidoM': apellidoM,
          'email': email,
          'password': password,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception('Error al crear la cuenta: ${response.statusMessage}');
      }
    } catch (e) {
      if (e is DioException) {
        throw Exception(
          'Error al crear la cuenta: ${e.response?.data ?? e.message}',
        );
      }
      throw Exception('Error al crear la cuenta: $e');
    }
  }

  Future<dynamic> verifyOtp(String email, String codigo) async {
    try {
      final response = await _dio.post(
        '/verificar-otp',
        data: {'email': email, 'codigo': codigo},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception('Código de verificación incorrecto');
      }
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 400) {
          throw Exception('Código de verificación incorrecto');
        }
        throw Exception(
          'Error al verificar código: ${e.response?.data ?? e.message}',
        );
      }
      throw Exception('Error al verificar código: $e');
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
    } catch (e) {
      throw Exception('Error al cerrar sesión: $e');
    }
  }
}
