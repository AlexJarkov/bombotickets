import 'package:dio/dio.dart';
import 'dart:developer';
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../entities/event_type.dart';
import '../entities/event.dart';
import '../entities/ticket.dart';
import '../entities/real_event.dart';
import '../../shared/entities/api_response.dart';
import 'package:bombotickets/config/environment.dart';

/// Repositorio unificado para manejo de tickets, marketplace y eventos
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

  // 3. Obtener tickets de un evento (DEPRECATED - usar getMarketplaceTicketsByEvent)
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

  // === MARKETPLACE METHODS ===

  // 4. Obtener todos los tickets del marketplace
  Future<List<MarketplaceOffer>> getMarketplaceTickets() async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '/marketplace',
        options: Options(headers: headers),
      );

      log('=== GET MARKETPLACE TICKETS RESPONSE ===');
      log('Status Code: ${response.statusCode}');
      log('Response data: ${response.data}');

      final data = response.data;

      // The API may return a list or wrap it in a `data` field
      List<dynamic> items;
      if (data is List) {
        items = data;
      } else if (data is Map && data['data'] is List) {
        items = data['data'] as List;
      } else if (data is String) {
        try {
          final decoded = jsonDecode(data);
          if (decoded is List) {
            items = decoded;
          } else if (decoded is Map && decoded['data'] is List) {
            items = decoded['data'] as List;
          } else {
            throw Exception('Formato de respuesta inesperado');
          }
        } catch (e) {
          throw Exception('Error al parsear respuesta JSON');
        }
      } else {
        throw Exception('Formato de respuesta no válido');
      }

      return items
          .map(
            (item) => MarketplaceOffer.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    } on DioException catch (e) {
      log('DioException in getMarketplaceTickets: ${e.message}');
      throw Exception('Error de conexión al obtener tickets del marketplace');
    } catch (e) {
      log('Unexpected error in getMarketplaceTickets: $e');
      rethrow;
    }
  }

  // 5. Obtener tickets del marketplace por evento específico
  Future<List<MarketplaceOffer>> getMarketplaceTicketsByEvent(
    String eventName,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '/publicaciones/by-evento',
        queryParameters: {'evento': eventName},
        options: Options(headers: headers),
      );

      log('=== GET MARKETPLACE TICKETS BY EVENT RESPONSE ===');
      log('Status Code: ${response.statusCode}');
      log('Event: $eventName');
      log('Response data: ${response.data}');

      final parsedData = _parseResponse(response.data);
      if (parsedData == null) {
        throw Exception('Respuesta del servidor inválida');
      }

      if (parsedData['codigo'] == 200) {
        // Si data es null, devolver lista vacía
        if (parsedData['data'] == null) {
          log('No tickets found for event: $eventName');
          return [];
        }

        final List<dynamic> publicationsData =
            parsedData['data'] as List<dynamic>;

        // Convertir las publicaciones del servidor a MarketplaceOffer
        final List<MarketplaceOffer> offers = [];
        //final Set<int> seenIds = <int>{}; // Para evitar duplicados

        for (final item in publicationsData) {
          try {
            final publication = MarketplacePublication.fromEventJson(
              item as Map<String, dynamic>,
            );

            // Verificar si ya hemos procesado esta publicación
            /*
            if (seenIds.contains(publication.id)) {
              log('Skipping duplicate publication with id: ${publication.id}');
              continue;
            }
            seenIds.add(publication.id);
            */

            final offer = publication.toMarketplaceOffer(
              eventName: eventName,
              zoneName: 'Zona General', // Valor por defecto, se puede mejorar
            );
            offers.add(offer);
          } catch (e) {
            log('Error parsing publication item: $e');
            log('Item data: $item');
            // Continúa con los siguientes elementos si uno falla
            continue;
          }
        }

        return offers;
      } else {
        throw Exception(
          parsedData['mensaje'] ?? 'Error al obtener tickets del evento',
        );
      }
    } on DioException catch (e) {
      log('DioException in getMarketplaceTicketsByEvent: ${e.message}');
      if (e.response?.data != null) {
        final errorData = _parseResponse(e.response!.data);
        if (errorData != null && errorData['mensaje'] != null) {
          throw Exception(errorData['mensaje']);
        }
      }
      throw Exception('Error de conexión');
    } catch (e) {
      log('Unexpected error in getMarketplaceTicketsByEvent: $e');
      rethrow;
    }
  }

  // 6. Obtener mis tickets en venta
  Future<List<MarketplaceOffer>> getMyMarketplaceOffers({
    String? forEmail,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '/marketplace/mine',
        options: Options(headers: headers),
      );

      log('=== GET MY MARKETPLACE OFFERS RESPONSE ===');
      log('Status Code: ${response.statusCode}');
      log('Email hint: ${forEmail ?? '-'}');
      log('Response data: ${response.data}');

      final parsedData = _parseResponse(response.data);
      if (parsedData == null) {
        throw Exception('Respuesta del servidor inválida');
      }

      if (parsedData['codigo'] == 200 && parsedData['data'] != null) {
        final List<dynamic> offersData = parsedData['data'] as List<dynamic>;
        return offersData
            .map(
              (item) => MarketplaceOffer.fromApiResponse(
                item as Map<String, dynamic>,
              ),
            )
            .toList();
      } else {
        throw Exception(
          parsedData['mensaje'] ?? 'Error al obtener mis ofertas',
        );
      }
    } on DioException catch (e) {
      log('DioException in getMyMarketplaceOffers: ${e.message}');
      if (e.response?.data != null) {
        final errorData = _parseResponse(e.response!.data);
        if (errorData != null && errorData['mensaje'] != null) {
          throw Exception(errorData['mensaje']);
        }
      }
      throw Exception('Error de conexión');
    } catch (e) {
      log('Unexpected error in getMyMarketplaceOffers: $e');
      rethrow;
    }
  }

  // === ZONES METHODS ===

  // 7. Obtener todas las zonas
  Future<List<Zone>> getZones() async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '/zonas',
        options: Options(headers: headers),
      );

      log('=== GET ZONES RESPONSE ===');
      log('Status Code: ${response.statusCode}');
      log('Response data: ${response.data}');

      final parsedData = _parseResponse(response.data);
      if (parsedData == null) {
        throw Exception('Respuesta del servidor inválida');
      }

      if (parsedData['codigo'] == 200 && parsedData['data'] != null) {
        final List<dynamic> zonesData = parsedData['data'] as List<dynamic>;
        return zonesData
            .map((item) => Zone.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(parsedData['mensaje'] ?? 'Error al obtener zonas');
      }
    } on DioException catch (e) {
      log('DioException in getZones: ${e.message}');
      if (e.response?.data != null) {
        final errorData = _parseResponse(e.response!.data);
        if (errorData != null && errorData['mensaje'] != null) {
          throw Exception(errorData['mensaje']);
        }
      }
      throw Exception('Error de conexión');
    } catch (e) {
      log('Unexpected error in getZones: $e');
      rethrow;
    }
  }

  // 8. Obtener zona específica por ID
  Future<Zone> getZoneById(int zoneId) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '/zonas/$zoneId',
        options: Options(headers: headers),
      );

      log('=== GET ZONE BY ID RESPONSE ===');
      log('Status Code: ${response.statusCode}');
      log('Zone ID: $zoneId');
      log('Response data: ${response.data}');

      final parsedData = _parseResponse(response.data);
      if (parsedData == null) {
        throw Exception('Respuesta del servidor inválida');
      }

      if (parsedData['codigo'] == 200 && parsedData['data'] != null) {
        return Zone.fromJson(parsedData['data'] as Map<String, dynamic>);
      } else {
        throw Exception(parsedData['mensaje'] ?? 'Error al obtener zona');
      }
    } on DioException catch (e) {
      log('DioException in getZoneById: ${e.message}');
      if (e.response?.data != null) {
        final errorData = _parseResponse(e.response!.data);
        if (errorData != null && errorData['mensaje'] != null) {
          throw Exception(errorData['mensaje']);
        }
      }
      throw Exception('Error de conexión');
    } catch (e) {
      log('Unexpected error in getZoneById: $e');
      rethrow;
    }
  }

  // === REAL EVENTS METHODS ===

  // 9. Obtener todos los eventos reales
  Future<List<RealEvent>> getAllRealEvents() async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '/eventos',
        options: Options(headers: headers),
      );

      log('=== GET ALL REAL EVENTS RESPONSE ===');
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
          log('Code: ${apiResponse.codigo}, Message: ${apiResponse.mensaje}');

          if (apiResponse.codigo == 200 && apiResponse.data != null) {
            final List<dynamic> eventsData = apiResponse.data!;
            log('Found ${eventsData.length} real events');
            return eventsData
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
        throw Exception('Error al obtener eventos reales');
      }
    } on DioException catch (e) {
      log('DioException in getAllRealEvents: ${e.message}');
      if (e.response?.data != null) {
        log('Error response: ${e.response!.data}');
      }
      throw Exception('Error de conexión al obtener eventos reales');
    } catch (e) {
      log('Unexpected error in getAllRealEvents: $e');
      rethrow;
    }
  }

  // === SELL TICKETS METHODS ===

  // 10. Crear listing de reventa
  Future<dynamic> createResaleListing({
    required List<String> qrTokens,
    required int cantidad,
    required num precioOfertado,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null || token.isEmpty) {
        throw Exception('No autenticado. Inicia sesión nuevamente.');
      }

      // Prepare tokens (with/without Bearer) and offered price as int
      String addBearer(String t) =>
          t.trim().startsWith('Bearer ') ? t.trim() : 'Bearer ${t.trim()}';
      String stripBearer(String t) => t.trim().startsWith('Bearer ')
          ? t.trim().substring(7).trim()
          : t.trim();

      final tokensWithBearer = qrTokens.map(addBearer).toList();
      final tokensWithoutBearer = qrTokens.map(stripBearer).toList();
      final offeredInt = precioOfertado.round();

      void logAttempt(String label, Map<String, dynamic> payload) {
        try {
          final qt = payload['qrTokens'];
          final qtCount = qt is List ? qt.length : 0;
          final safe = Map<String, dynamic>.from(payload);
          if (safe.containsKey('qrTokens'))
            safe['qrTokens'] = '[${qtCount} tokens]';
          log('[Marketplace] Attempt $label payload=${jsonEncode(safe)}');
        } catch (_) {}
      }

      void logDioError(String label, DioException e) {
        final code = e.response?.statusCode;
        final path = e.requestOptions.uri.toString();
        String body;
        final data = e.response?.data;
        if (data == null) {
          body = '<no body>';
        } else if (data is String) {
          body = data;
        } else {
          try {
            body = jsonEncode(data);
          } catch (_) {
            body = data.toString();
          }
        }
        log('[Marketplace] Error ($label) status=$code url=$path body=$body');
      }

      Future<Response<dynamic>> postPayload(
        Map<String, dynamic> payload,
        String label,
      ) {
        logAttempt(label, payload);
        return _dio.post(
          '/marketplace',
          data: payload,
          options: Options(
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        );
      }

      final primary = {
        'qrTokens': tokensWithBearer,
        'cantidad': cantidad,
        'precioOfertado': offeredInt,
      };

      try {
        final response = await postPayload(primary, 'primary');
        if (response.statusCode == 200 || response.statusCode == 201) {
          return response.data;
        }
      } on DioException catch (e) {
        if (e.response?.statusCode == 400) {
          logDioError('primary', e);
          // Alt A: tokens without Bearer
          try {
            final r = await postPayload({
              'qrTokens': tokensWithoutBearer,
              'cantidad': cantidad,
              'precioOfertado': offeredInt,
            }, 'altA_noBearer');
            if (r.statusCode == 200 || r.statusCode == 201) return r.data;
          } on DioException catch (eA) {
            logDioError('altA_noBearer', eA);
          }

          // Alt B: wrapped with Bearer
          try {
            final r = await postPayload({
              'entrada': {
                'qrTokens': tokensWithBearer,
                'cantidad': cantidad,
                'precioOfertado': offeredInt,
              },
            }, 'altB_wrapped_Bearer');
            if (r.statusCode == 200 || r.statusCode == 201) return r.data;
          } on DioException catch (eB) {
            logDioError('altB_wrapped_Bearer', eB);
          }

          // Alt C: wrapped without Bearer
          try {
            final r = await postPayload({
              'entrada': {
                'qrTokens': tokensWithoutBearer,
                'cantidad': cantidad,
                'precioOfertado': offeredInt,
              },
            }, 'altC_wrapped_noBearer');
            if (r.statusCode == 200 || r.statusCode == 201) return r.data;
          } on DioException catch (eC) {
            logDioError('altC_wrapped_noBearer', eC);
          }

          // If all alternatives fail, rethrow original
          rethrow;
        } else {
          logDioError('non-400', e);
          rethrow;
        }
      }

      throw Exception('Error al publicar: respuesta no exitosa');
    } catch (e) {
      if (e is DioException) {
        final data = e.response?.data;
        String msg = e.message ?? 'Error de red';
        if (data is Map) {
          if (data['mensaje'] != null)
            msg = data['mensaje'].toString();
          else if (data['message'] != null)
            msg = data['message'].toString();
          else if (data['error'] != null)
            msg = data['error'].toString();
          else if (data['errors'] != null)
            msg = data['errors'].toString();
        } else if (data != null) {
          msg = data.toString();
        }
        log('[Marketplace] Throwing error: $msg');
        throw Exception('Error al publicar: $msg');
      }
      rethrow;
    }
  }

  /// Obtener mis listados del marketplace (ventas)
  Future<List<MarketplaceOffer>> getMyMarketplaceListings() async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '/publicaciones/mine',
        options: Options(headers: headers),
      );

      final responseData = _parseResponse(response.data);
      if (responseData == null) {
        log('Failed to parse response data');
        return [];
      }

      log('getMyMarketplaceListings response: $responseData');

      if (responseData['codigo'] == 200 && responseData['data'] != null) {
        final List<dynamic> dataList = responseData['data'] as List<dynamic>;
        return dataList
            .map(
              (json) => MarketplaceOffer.fromApiResponse(
                json as Map<String, dynamic>,
              ),
            )
            .toList();
      } else {
        log(
          'API returned codigo: ${responseData['codigo']} - ${responseData['mensaje'] ?? 'Unknown error'}',
        );
        return [];
      }
    } on DioException catch (e) {
      log('DioException in getMyMarketplaceListings: ${e.message}');
      return [];
    } catch (e) {
      log('Unexpected error in getMyMarketplaceListings: $e');
      return [];
    }
  }

  // 11. Validar código QR de ticket
  Future<Map<String, dynamic>> validateQRCode(String qrToken) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.post(
        '/read-qr',
        data: {'qr': qrToken},
        options: Options(headers: headers),
      );

      log('=== VALIDATE QR RESPONSE ===');
      log('Status Code: ${response.statusCode}');
      log('QR Token: $qrToken');
      log('Response data: ${response.data}');

      final parsedData = _parseResponse(response.data);
      if (parsedData == null) {
        throw Exception('Respuesta del servidor inválida');
      }

      if (parsedData['codigo'] == 200 && parsedData['data'] != null) {
        return parsedData['data'] as Map<String, dynamic>;
      } else {
        throw Exception(parsedData['mensaje'] ?? 'Error al validar código QR');
      }
    } on DioException catch (e) {
      log('DioException in validateQRCode: ${e.message}');
      if (e.response?.data != null) {
        final errorData = _parseResponse(e.response!.data);
        if (errorData != null && errorData['mensaje'] != null) {
          throw Exception(errorData['mensaje']);
        }
      }
      throw Exception('Error de conexión al validar QR');
    } catch (e) {
      log('Unexpected error in validateQRCode: $e');
      rethrow;
    }
  }

  // 11.5. Leer QR desde archivo de imagen
  Future<Map<String, dynamic>> readQRFromFile(File imageFile) async {
    try {
      final headers = await _getHeaders();

      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'qr_image.jpg',
        ),
      });

      final response = await _dio.post(
        '/read-qr-from-file',
        data: formData,
        options: Options(
          headers: {
            'Accept': 'application/json',
            if (headers['Authorization'] != null)
              'Authorization': headers['Authorization'],
          },
        ),
      );

      log('QR from file response: ${response.data}');

      final parsed = _parseResponse(response.data);
      if (parsed == null) {
        throw Exception('Failed to parse QR from file response');
      }

      return parsed;
    } on DioException catch (e) {
      log('DioException in readQRFromFile: ${e.message}');
      log('Response data: ${e.response?.data}');
      if (e.response?.data != null) {
        final parsed = _parseResponse(e.response!.data);
        if (parsed != null) {
          return parsed;
        }
      }
      rethrow;
    } catch (e) {
      log('Unexpected error in readQRFromFile: $e');
      rethrow;
    }
  }

  // 12. Crear publicación en marketplace
  Future<List<MarketplaceOffer>> createMarketplaceListing({
    required List<String> qrTokens,
    required int cantidad,
    required double precioOfertado,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.post(
        '/marketplace',
        data: {
          'qrTokens': qrTokens,
          'cantidad': cantidad,
          'precioOfertado': precioOfertado,
        },
        options: Options(headers: headers),
      );

      log('=== CREATE MARKETPLACE LISTING RESPONSE ===');
      log('Status Code: ${response.statusCode}');
      log('QR Tokens count: ${qrTokens.length}');
      log('Cantidad: $cantidad');
      log('Precio ofertado: $precioOfertado');
      log('Response data: ${response.data}');

      final parsedData = _parseResponse(response.data);
      if (parsedData == null) {
        throw Exception('Respuesta del servidor inválida');
      }

      if (parsedData['codigo'] == 201 && parsedData['data'] != null) {
        final List<dynamic> offersData = parsedData['data'] as List<dynamic>;
        return offersData
            .map(
              (item) => MarketplaceOffer.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      } else {
        throw Exception(
          parsedData['mensaje'] ?? 'Error al crear la publicación',
        );
      }
    } on DioException catch (e) {
      log('DioException in createMarketplaceListing: ${e.message}');
      if (e.response?.data != null) {
        final errorData = _parseResponse(e.response!.data);
        if (errorData != null && errorData['mensaje'] != null) {
          throw Exception(errorData['mensaje']);
        }
      }
      throw Exception('Error de conexión al crear publicación');
    } catch (e) {
      log('Unexpected error in createMarketplaceListing: $e');
      rethrow;
    }
  }
}
