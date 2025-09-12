import 'package:dio/dio.dart';
import 'dart:developer';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../entities/event_type.dart';
import '../entities/event.dart';
import '../entities/ticket.dart';
import 'package:bombotickets/config/environment.dart';

class TicketsRepository {
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

  // Helper method to safely parse JSON response
  Map<String, dynamic>? _parseResponse(dynamic responseData) {
    try {
      if (responseData == null || responseData == '') {
        log('Response data is null or empty');
        return null;
      }

      if (responseData is Map<String, dynamic>) {
        return responseData;
      } else if (responseData is String) {
        log('Parsing String response: $responseData');
        return jsonDecode(responseData) as Map<String, dynamic>;
      } else {
        log('Unexpected response type: ${responseData.runtimeType}');
        return null;
      }
    } catch (e) {
      log('Error parsing response: $e');
      return null;
    }
  }

  // 1. Obtener tipos de eventos
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
        // La respuesta es directamente un array de categorías
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

  // 2. Obtener eventos por tipo
  Future<List<Event>> getEventsByType(int tipoEventoId) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '/eventos/tipo/$tipoEventoId',
        options: Options(headers: headers),
      );

      log('=== GET EVENTS BY TYPE RESPONSE ===');
      log('Status Code: ${response.statusCode}');
      log('Response data: ${response.data}');

      final parsedData = _parseResponse(response.data);
      if (parsedData == null) {
        throw Exception('Respuesta del servidor inválida');
      }

      if (parsedData['codigo'] == 200 && parsedData['data'] != null) {
        final List<dynamic> eventsData = parsedData['data'] as List<dynamic>;
        return eventsData
            .map((item) => Event.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(parsedData['mensaje'] ?? 'Error al obtener eventos');
      }
    } on DioException catch (e) {
      log('DioException in getEventsByType: ${e.message}');
      if (e.response?.data != null) {
        final errorData = _parseResponse(e.response!.data);
        if (errorData != null && errorData['mensaje'] != null) {
          throw Exception(errorData['mensaje']);
        }
      }
      throw Exception('Error de conexión');
    } catch (e) {
      log('Unexpected error in getEventsByType: $e');
      rethrow;
    }
  }

  // 3. Obtener tickets de un evento
  Future<List<MyTicket>> getTicketsByEvent(int eventoId) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '/tickets/evento/$eventoId',
        options: Options(headers: headers),
      );

      log('=== GET TICKETS BY EVENT RESPONSE ===');
      log('Status Code: ${response.statusCode}');
      log('Response data: ${response.data}');

      final parsedData = _parseResponse(response.data);
      if (parsedData == null) {
        throw Exception('Respuesta del servidor inválida');
      }

      if (parsedData['codigo'] == 200 && parsedData['data'] != null) {
        final List<dynamic> ticketsData = parsedData['data'] as List<dynamic>;
        return ticketsData
            .map((item) => MyTicket.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(parsedData['mensaje'] ?? 'Error al obtener tickets');
      }
    } on DioException catch (e) {
      log('DioException in getTicketsByEvent: ${e.message}');
      if (e.response?.data != null) {
        final errorData = _parseResponse(e.response!.data);
        if (errorData != null && errorData['mensaje'] != null) {
          throw Exception(errorData['mensaje']);
        }
      }
      throw Exception('Error de conexión');
    } catch (e) {
      log('Unexpected error in getTicketsByEvent: $e');
      rethrow;
    }
  }
}
