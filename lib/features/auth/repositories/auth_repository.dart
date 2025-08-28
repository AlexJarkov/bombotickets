import 'package:dio/dio.dart';
import 'package:bombotickets/config/environment.dart';

class AuthRepository {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: Environment.apiUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
    ),
  );

  Future<dynamic> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '/usuarios/login/',
        data: {'username': username, 'password': password},
      );
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Error al iniciar sesión: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Error al iniciar sesión $e');
    }
  }

  Future<dynamic> register(
    String username,
    String email,
    String password,
    String password2,
  ) async {
    try {
      final response = await _dio.post(
        '/usuarios/register/',
        data: {
          'username': username,
          'email': email,
          'password': password,
          'password2': password2,
        },
      );
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Error al crear la cuenta: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Error al crear la cuenta $e');
    }
  }
}
