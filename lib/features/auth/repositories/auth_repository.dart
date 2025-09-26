import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bombotickets/config/environment.dart';
import '../../shared/entities/entities.dart';
import '../login/entities/login_response.dart';
import '../register/entities/register_response.dart';
import 'dart:developer';

class AuthRepository {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: Environment.apiUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
    ),
  );

  Future<ApiResponse<LoginResponse>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await _dio.post(
        '/login',
        data: {'email': email, 'password': password},
      );

      // log('=== LOGIN RESPONSE DEBUG ===');
      // log('Status Code: ${response.statusCode}');
      // log('Response data type: ${response.data.runtimeType}');
      log('LOGIN RESPONSE: ${response.data}');

      // Usar el factory method que manejará el parsing
      final apiResponse = ApiResponse.fromJson(
        response.data,
        (data) => data != null ? LoginResponse.fromJson(data) : null,
      );

      // Si el login es exitoso, guardar token
      if (apiResponse.codigo == 200 && apiResponse.data != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', apiResponse.data!.token);
        // log('Token saved: ${apiResponse.data!.token}');
      }

      return apiResponse;
    } on DioException catch (e) {
      log('DioException in login: ${e.message}');
      log('DioException response: ${e.response?.data}');
      log('DioException status: ${e.response?.statusCode}');

      if (e.response?.data != null) {
        return ApiResponse.fromJson(
          e.response!.data,
          (data) => data != null ? LoginResponse.fromJson(data) : null,
        );
      }
      return ApiResponse<LoginResponse>(
        codigo: 500,
        mensaje: 'Error de conexión',
      );
    } catch (e) {
      log('Unexpected error in login: $e');
      return ApiResponse<LoginResponse>(
        codigo: 500,
        mensaje: 'Error inesperado: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse<RegisterResponse>> register(
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
          'nombres': nombre,
          'apellidoP': apellidoP,
          'apellidoM': apellidoM,
          'email': email,
          'password': password,
        },
      );

      return ApiResponse.fromJson(
        response.data,
        (json) => json != null ? RegisterResponse.fromJson(json) : null,
      );
    } on DioException catch (e) {
      if (e.response?.data != null) {
        return ApiResponse.fromJson(
          e.response!.data,
          (json) => json != null ? RegisterResponse.fromJson(json) : null,
        );
      }
      return ApiResponse<RegisterResponse>(
        codigo: 500,
        mensaje: 'Error de conexión',
      );
    } catch (e) {
      return ApiResponse<RegisterResponse>(
        codigo: 500,
        mensaje: 'Error inesperado: ${e.toString()}',
      );
    }
  }

  Future<ApiResponse<void>> verifyOtp(String email, String codigo) async {
    try {
      final response = await _dio.post(
        '/verificar-otp',
        data: {'email': email, 'codigo': codigo},
      );

      return ApiResponse<void>(
        codigo: response.data['codigo'] as int,
        mensaje: response.data['mensaje'] as String,
      );
    } on DioException catch (e) {
      if (e.response?.data != null) {
        return ApiResponse<void>(
          codigo: e.response!.data['codigo'] as int,
          mensaje: e.response!.data['mensaje'] as String,
        );
      }
      return ApiResponse<void>(codigo: 500, mensaje: 'Error de conexión');
    } catch (e) {
      return ApiResponse<void>(
        codigo: 500,
        mensaje: 'Error inesperado: ${e.toString()}',
      );
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
