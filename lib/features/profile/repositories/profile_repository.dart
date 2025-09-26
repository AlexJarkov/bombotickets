import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bombotickets/config/environment.dart';

class ProfileRepository {
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
    return {
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      'Accept': 'application/json, text/plain, */*',
    };
  }

  Future<Map<String, dynamic>> getUserByEmail(String email) async {
    try {
      final headers = await _authorizedHeaders();
      final response = await _dio.get(
        '/user/$email',
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) return data;
        return {'data': data};
      }
      throw Exception('Error al obtener el usuario: ${response.statusMessage}');
    } on DioException catch (e) {
      final msg = e.response?.data ?? e.message ?? 'Error de red';
      throw Exception('Error al obtener el usuario: $msg');
    } catch (e) {
      rethrow;
    }
  }


  Future<Map<String, dynamic>> updateUserByEmail(
    String email,
    Map<String, dynamic> body,
  ) async {
    try {
      final headers = await _authorizedHeaders();
      // Backward compatibility: accept 'nombres' but send as 'nombre'
      if (body.containsKey('nombres') && !body.containsKey('nombre')) {
        body = {
          ...body,
          'nombre': body['nombres'],
        }..remove('nombres');
      }
      final response = await _dio.put(
        '/update-user/$email',
        data: body,
        options: Options(headers: {
          ...headers,
          'Content-Type': 'application/json',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map<String, dynamic>) return data;
        return {'data': data};
      }
      throw Exception('Error al actualizar el usuario: ${response.statusMessage}');
    } on DioException catch (e) {
      final msg = e.response?.data ?? e.message ?? 'Error de red';
      throw Exception('Error al actualizar el usuario: $msg');
    } catch (e) {
      rethrow;
    }
  }

  Future<int> getUserIdFromEmail(String email) async {
    final raw = await getUserByEmail(email);
    final data = (raw['data'] is Map) ? (raw['data'] as Map) : raw;
    final idDyn = data['id'] ?? data['ID'] ?? data['userId'] ?? data['UserId'];
    if (idDyn is int) return idDyn;
    if (idDyn is String) return int.tryParse(idDyn) ?? (throw Exception('ID de usuario no válido'));
    throw Exception('ID de usuario no encontrado en la respuesta');
  }

  Future<Map<String, dynamic>> uploadProfileImageByEmail(
    String email,
    File imageFile,
  ) async {
    try {
      final headers = await _authorizedHeaders();
      final id = await getUserIdFromEmail(email);

      final form = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      final response = await _dio.post(
        '/$id/upload-imagen',
        data: form,
        options: Options(headers: {
          ...headers,
          'Content-Type': 'multipart/form-data',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map<String, dynamic>) return data;
        return {'data': data};
      }
      throw Exception('Error al subir la imagen: ${response.statusMessage}');
    } on DioException catch (e) {
      final msg = e.response?.data ?? e.message ?? 'Error de red';
      throw Exception('Error al subir la imagen: $msg');
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> deleteProfileImageByEmail(String email) async {
    return updateUserByEmail(email, {'imagen': ''});
  }
}
final profileRepositoryProvider = Provider<ProfileRepository>((ref) => ProfileRepository());

