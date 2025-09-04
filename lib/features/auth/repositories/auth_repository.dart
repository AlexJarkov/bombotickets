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

  Future<dynamic> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '/login',
        data: {'username': username, 'password': password},
      );
      if (response.statusCode == 200) {
        // Store the Bearer token in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final token = response.data['token'];
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
    String username,
    String email,
    String password,
  ) async {
    try {
      final response = await _dio.post(
        '/signup',
        data: {'username': username, 'email': email, 'password': password},
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

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
    } catch (e) {
      throw Exception('Error al cerrar sesión: $e');
    }
  }
}
