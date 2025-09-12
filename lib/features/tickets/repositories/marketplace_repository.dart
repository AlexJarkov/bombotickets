import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:bombotickets/config/environment.dart';
import '../entities/ticket.dart';

class MarketplaceRepository {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: Environment.apiUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
    ),
  );

  Future<List<EventTicket>> fetchMarketplaceTickets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await _dio.get(
        '/marketplace',
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
            'Accept': 'application/json, text/plain, */*',
          },
        ),
      );

      final data = response.data;

      // The API may return a list or wrap it in a `data` or `entradas` field.
      List<dynamic> items;
      if (data is List) {
        items = data;
      } else if (data is Map && data['data'] is List) {
        items = data['data'] as List;
      } else if (data is Map && data['entradas'] is List) {
        items = data['entradas'] as List;
      } else if (data is String) {
        // try to parse stringified JSON
        try {
          final decoded = jsonDecode(data);
          if (decoded is List) {
            items = decoded;
          } else if (decoded is Map && decoded['data'] is List) {
            items = decoded['data'] as List;
          } else if (decoded is Map && decoded['entradas'] is List) {
            items = decoded['entradas'] as List;
          } else {
            items = const [];
          }
        } catch (_) {
          items = const [];
        }
      } else {
        items = const [];
      }

      return items
          .map((e) => _mapToEventTicket(e))
          .whereType<EventTicket>()
          .toList();
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      final serverMsg = e.response?.data is Map
          ? (e.response!.data['message'] ?? e.response!.data['error'])
          : e.message;
      throw Exception(
        'Error al cargar marketplace ($code): ${serverMsg ?? 'desconocido'}',
      );
    }
  }

  EventTicket? _mapToEventTicket(dynamic raw) {
    if (raw is! Map) return null;

    // Helpers to read keys with fallbacks
    T? g<T>(List<String> keys) {
      for (final k in keys) {
        final v = raw[k];
        if (v is T) return v;
      }
      return null;
    }

    String id =
        g<String>(['id', 'uuid', 'listingId', 'ticketId']) ??
        'listing-${DateTime.now().microsecondsSinceEpoch}-${raw.hashCode}';
    String title =
        g<String>(['title', 'titulo', 'eventTitle', 'evento']) ?? 'Evento';
    String artist = g<String>(['artist', 'artista', 'performer']) ?? '';
    String venue = g<String>(['venue', 'recinto', 'lugar']) ?? '';

    // Parse date from various keys (ISO or millis)
    DateTime date = DateTime.now();
    final dateStr = g<String>(['date', 'fecha', 'eventDate', 'fechaEvento']);
    final dateNum = g<num>(['date', 'fecha', 'eventDate', 'fechaEvento']);
    if (dateStr != null) {
      try {
        date = DateTime.parse(dateStr);
      } catch (_) {}
    } else if (dateNum != null) {
      try {
        date = DateTime.fromMillisecondsSinceEpoch(dateNum.toInt());
      } catch (_) {}
    }

    int price =
        _asInt(g(['precioOfertado', 'price', 'precio', 'precio_ofertado'])) ??
        0;
    int originalPrice =
        _asInt(
          g([
            'precioOriginal',
            'original_price',
            'precio_referencia',
            'precioBase',
          ]),
        ) ??
        price;

    String imageUrl =
        g<String>(['imageUrl', 'imagen', 'image', 'poster', 'banner']) ?? '';
    if (imageUrl.isEmpty) {
      // Use a generic placeholder if none provided
      imageUrl = 'https://picsum.photos/600/400?random=${id.hashCode & 0xFFFF}';
    }

    String category = g<String>(['category', 'categoria']) ?? 'General';
    int availableTickets =
        _asInt(g(['cantidad', 'availableTickets', 'disponibles', 'stock'])) ??
        1;
    bool isResale = g<bool>(['isResale', 'is_resale', 'reventa']) ?? true;

    // Adapt for marketplace payload structure with nested ticket_ofertado/evento
    final ticketOfertado = raw['ticket_ofertado'];
    if (ticketOfertado is Map) {
      final evento = ticketOfertado['evento'];
      if (evento is Map) {
        title = (evento['nombre'] as String?)?.trim().isNotEmpty == true
            ? (evento['nombre'] as String)
            : title;
        venue = (evento['lugar'] as String?)?.trim().isNotEmpty == true
            ? (evento['lugar'] as String)
            : (venue.isEmpty ? 'Por definir' : venue);
        final ciudad = evento['ciudad'] as String?;
        if (ciudad != null && ciudad.trim().isNotEmpty) {
          // Append city to venue if available
          venue = venue.isEmpty ? ciudad : '$venue · $ciudad';
        }

        final img = evento['imagen'] as String?;
        if (img != null && img.trim().isNotEmpty) {
          imageUrl = img;
        }

        // Category nested
        final cat = evento['categoria'];
        if (cat is Map && cat['nombre'] is String) {
          category = cat['nombre'] as String;
        }

        // Date string like dd-MM-yyyy
        final evFecha = evento['fecha'];
        if (evFecha is String && evFecha.trim().isNotEmpty) {
          try {
            // Common formats: dd-MM-yyyy or dd/MM/yyyy
            date = DateFormat('dd-MM-yyyy').parse(evFecha);
          } catch (_) {
            try {
              date = DateFormat('dd/MM/yyyy').parse(evFecha);
            } catch (_) {
              // As a last resort, attempt ISO parse
              try {
                date = DateTime.parse(evFecha);
              } catch (_) {}
            }
          }
        }
      }

      // Zone info: sets a friendly subtitle and original price when present
      final zona = ticketOfertado['zona'];
      if (zona is Map) {
        final zonaNombre = zona['nombre'] as String?;
        if ((zonaNombre ?? '').trim().isNotEmpty) {
          artist = 'Zona: ${zonaNombre!.trim()}';
        }
        final zonaPrecio = zona['precio'];
        final zp = _asInt(zonaPrecio);
        if (zp != null && zp > 0) {
          originalPrice = zp;
        }
      }
    }

    // Fallbacks
    if (artist.isEmpty) artist = category;
    if (venue.isEmpty) venue = 'Por definir';

    return EventTicket(
      id: id,
      title: title,
      artist: artist,
      venue: venue,
      date: date,
      price: price,
      originalPrice: originalPrice,
      imageUrl: imageUrl,
      category: category,
      availableTickets: availableTickets,
      isResale: isResale,
    );
  }

  int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) {
      final s = v.replaceAll(RegExp(r'[^0-9-]'), '');
      return int.tryParse(s);
    }
    return null;
  }
}
