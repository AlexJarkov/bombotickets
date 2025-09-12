import 'package:dio/dio.dart';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';
import '../entities/real_event.dart';
import '../entities/event_type.dart';
import '../../shared/entities/api_response.dart';
import 'package:bombotickets/config/environment.dart';

class RealEventsRepository {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: Environment.apiUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
    ),
  );

  // Helper method to get headers with bearer token
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  // Obtener todos los eventos
  Future<List<RealEvent>> getAllEvents() async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '/eventos',
        options: Options(headers: headers),
      );

      log('=== GET ALL EVENTS RESPONSE ===');
      log('Status Code: ${response.statusCode}');
      log('Response data: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        try {
          log('Attempting to parse ApiResponse...');
          final apiResponse = ApiResponse<List<dynamic>>.fromJson(
            response.data as Map<String, dynamic>,
            (data) => data as List<dynamic>,
          );

          log('ApiResponse parsed successfully');
          log('ApiResponse codigo: ${apiResponse.codigo}');
          log('ApiResponse data type: ${apiResponse.data.runtimeType}');

          if (apiResponse.codigo == 200 && apiResponse.data != null) {
            return apiResponse.data!
                .map((item) => RealEvent.fromJson(item as Map<String, dynamic>))
                .toList();
          } else {
            throw Exception(apiResponse.mensaje);
          }
        } catch (parseError) {
          log('ApiResponse parsing error: $parseError');
          throw Exception('Error al procesar respuesta del servidor');
        }
      } else {
        throw Exception('Error al obtener eventos');
      }
    } on DioException catch (e) {
      log('DioException in getAllEvents: ${e.message}');
      if (e.response?.data != null) {
        log('Error response: ${e.response!.data}');
      }
      throw Exception('Error de conexión al obtener eventos');
    } catch (e) {
      log('Unexpected error in getAllEvents: $e');
      rethrow;
    }
  }

  // Obtener categorías (reutilizamos del tickets_repository)
  Future<List<EventType>> getEventTypes() async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '/categorias',
        options: Options(headers: headers),
      );

      log('=== GET EVENT TYPES RESPONSE ===');
      log('Status Code: ${response.statusCode}');
      log('Response data: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> eventTypesData = response.data as List<dynamic>;
        return eventTypesData
            .map((item) => EventType.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Error al obtener categorías de eventos');
      }
    } on DioException catch (e) {
      log('DioException in getEventTypes: ${e.message}');
      if (e.response?.data != null) {
        log('Error response: ${e.response!.data}');
      }
      throw Exception('Error de conexión al obtener categorías');
    } catch (e) {
      log('Unexpected error in getEventTypes: $e');
      rethrow;
    }
  }
}
