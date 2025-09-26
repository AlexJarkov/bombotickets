import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bombotickets/config/environment.dart';

class CuentaBancariaRepository {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: Environment.apiUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
    ),
  );

  Future<Map<String, dynamic>> _authorizedHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    log('[Headers] Token recuperado: ${token != null ? 'OK' : 'NULL'}');
    return {
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      'Accept': 'application/json, text/plain, */*',
    };
  }

  Future<void> deleteCuentaBanco(dynamic id) async {
    try {
      final headers = await _authorizedHeaders();
      final pathId = Uri.encodeComponent(id.toString());
      log('[DELETE] /cuenta-banco-usuario/$pathId headers=$headers');

      final res = await _dio.delete(
        '/cuenta-banco-usuario/$pathId',
        options: Options(headers: headers),
      );

      log('[DELETE] Response code=${res.statusCode} data=${res.data}');

      if (res.statusCode == 200 || res.statusCode == 202 || res.statusCode == 204) {
        return;
      }
      throw Exception('HTTP ${res.statusCode}: ${res.statusMessage ?? 'Error al eliminar cuenta'}');
    } on DioException catch (e) {
      log('[DELETE] DioException: ${e.response?.data ?? e.message}');
      final msg = e.response?.data ?? e.message ?? 'Error de red';
      throw Exception('Error al eliminar cuenta: $msg');
    } catch (e) {
      log('[DELETE] Error inesperado: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getCuentas() async {
    try {
      final headers = await _authorizedHeaders();
      log('[GET] /cuenta-banco-usuario/mis-cuentas headers=$headers');

      final response = await _dio.get(
        '/cuenta-banco-usuario/mis-cuentas/',
        options: Options(headers: headers),
      );

      log('[GET] Response code=${response.statusCode} data=${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) return data;
        return {'data': data};
      }
      throw Exception('Error al obtener el usuario: ${response.statusMessage}');
    } on DioException catch (e) {
      log('[GET] DioException: ${e.response?.data ?? e.message}');
      final msg = e.response?.data ?? e.message ?? 'Error de red';
      throw Exception('Error al obtener el usuario: $msg');
    } catch (e) {
      log('[GET] Error inesperado: $e');
      rethrow;
    }
  }

    Future<Map<String, dynamic>> putCuentaBanco({
  required dynamic id,
  required Map<String, dynamic> body,
}) async {
  try {
    final headers = await _authorizedHeaders();
    final pathId = Uri.encodeComponent(id.toString());
    final url = '/cuenta-banco-usuario/$pathId/';
    log('[PUT] $url body=$body');
    final res = await _dio.put(url, data: body, options: Options(headers: headers));
    log('[PUT] code=${res.statusCode} data=${res.data}');
    if (res.statusCode == 200 || res.statusCode == 201) {
      final data = res.data;
      return data is Map<String, dynamic> ? data : {'data': data};
    }
    throw Exception('Error al actualizar: ${res.statusMessage}');
  } on DioException catch (e) {
    log('[PUT] DioException: ${e.response?.data ?? e.message}');
    throw Exception('Error al actualizar: ${e.response?.data ?? e.message ?? 'Error de red'}');
  }
}

  Future<Map<String, dynamic>> postCuentaBanco(
    Map<String, dynamic> body,
  ) async {
    try {
      final headers = await _authorizedHeaders();
      log('[POST] /cuenta-banco-usuario body=$body headers=$headers');

      final response = await _dio.post(
        '/cuenta-banco-usuario/',
        data: body,
        options: Options(headers: {
          ...headers,
          'Content-Type': 'application/json',
        }),
      );

      log('[POST] Response code=${response.statusCode} data=${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map<String, dynamic>) return data;
        return {'data': data};
      }
      throw Exception('Error al actualizar el usuario: ${response.statusMessage}');
    } on DioException catch (e) {
      log('[POST] DioException: ${e.response?.data ?? e.message}');
      final msg = e.response?.data ?? e.message ?? 'Error de red';
      throw Exception('Error al actualizar el usuario: $msg');
    } catch (e) {
      log('[POST] Error inesperado: $e');
      rethrow;
    }
  }
}

final cuentaBancariaRepositoryProvider =
    Provider<CuentaBancariaRepository>((ref) => CuentaBancariaRepository());
