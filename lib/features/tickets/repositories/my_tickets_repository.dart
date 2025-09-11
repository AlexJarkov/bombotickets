
import 'package:dio/dio.dart';
import 'dart:developer' show log;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:bombotickets/config/environment.dart';
import '../entities/ticket.dart';
import 'package:bombotickets/features/profile/repositories/profile_repository.dart';

/// Repository to fetch the current user's registered/scanned tickets
class MyTicketsRepository {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: Environment.apiUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
    ),
  );

  Future<List<MyTicket>> fetchMyTickets({String? forEmail}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final email = forEmail ?? prefs.getString('profile.email');

      log('[MyTickets] GET /marketplace/mine baseUrl=${Environment.apiUrl} tokenPresent=${token != null && token.isNotEmpty} emailHint=${email ?? '-'}');
      final response = await _dio.get(
        '/marketplace/mine',
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
            'Accept': 'application/json, text/plain, */*',
          },
        ),
      );

      log('[MyTickets] Response status=${response.statusCode} type=${response.data.runtimeType}');
      // Parse and then filter strictly by ownership (owner.id == logged user's id)
      final raw = response.data;
      final List<dynamic> list = () {
        if (raw is List) return raw;
        if (raw is Map && raw['data'] is List) return raw['data'] as List;
        return const [];
      }();

      // Determine logged user id explicitly from profile when available
      int? loggedId;
      if (email != null && email.isNotEmpty) {
        try {
          final profileRepo = ProfileRepository();
          loggedId = await profileRepo.getUserIdFromEmail(email);
          log('[MyTickets] Resolved logged user id from profile: $loggedId');
        } catch (e) {
          log('[MyTickets] Could not resolve user id from profile: $e');
        }
      }

      // Fallback: infer from payload (most frequent user_ofertante.id)
      final counts = <int, int>{};
      for (final it in list) {
        if (it is Map) {
          final u = it['user_ofertante'];
          final id = (u is Map) ? u['id'] : null;
          if (id is int) counts[id] = (counts[id] ?? 0) + 1;
        }
      }
      if (loggedId == null && counts.isNotEmpty) {
        loggedId = counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
      }

      final filteredRaw = list.whereType<Map>().where((m) {
        final ofertado = m['ticket_ofertado'];
        final owner = (ofertado is Map) ? ofertado['owner'] : null;
        final ownerId = (owner is Map) ? owner['id'] : null;
        final ofertante = m['user_ofertante'];
        final ofertanteId = (ofertante is Map) ? ofertante['id'] : null;
        final targetId = loggedId ?? ofertanteId;
        if (ownerId is int && targetId is int) return ownerId == targetId;
        // If we cannot determine IDs, pass through (endpoint should already be filtered)
        return true;
      }).toList();

      final items = filteredRaw.map((e) => _mapToMyTicket(e)).whereType<MyTicket>().toList();
      return items;
    } on DioException catch (e) {
      log('[MyTickets] DioException status=${e.response?.statusCode} message=${e.message}');
      final code = e.response?.statusCode;
      final serverMsg = e.response?.data is Map
          ? (e.response!.data['message'] ?? e.response!.data['error'])
          : e.message;
      throw Exception('Error al cargar mis tickets ($code): ${serverMsg ?? 'desconocido'}');
    }
  }

  // _parseResponse removed; using direct parsing inline

  MyTicket? _mapToMyTicket(dynamic raw) {
    if (raw is! Map) return null;

    // Helper to read keys with fallbacks
    T? g<T>(List<String> keys) {
      for (final k in keys) {
        final v = raw[k];
        if (v is T) return v;
      }
      return null;
    }

    String id = g<String>(['id', 'uuid', 'ticketId', 'codigo', 'code']) ??
        'ticket-${DateTime.now().microsecondsSinceEpoch}-${raw.hashCode}';

    // Extract nested event if present (supports marketplace listing shape)
    Map? ev;
    final ticketOfertado = raw['ticket_ofertado'];
    if (ticketOfertado is Map) {
      final evMap = ticketOfertado['evento'];
      if (evMap is Map) ev = evMap;
    }
    ev ??= (raw['evento'] is Map ? raw['evento'] as Map : null);

    String title = g<String>(['title', 'titulo', 'eventTitle', 'evento']) ??
        (ev != null ? (ev['nombre'] as String? ?? '') : 'Ticket');
    if (title.isEmpty && ev != null) title = (ev['nombre'] as String? ?? 'Ticket');

    String venue = g<String>(['venue', 'recinto', 'lugar', 'ubicacion']) ??
        (ev != null ? (ev['lugar'] as String? ?? '') : '');
    if (venue.isEmpty) venue = 'Por definir';

    DateTime date = DateTime.now();
    final dateStr = g<String>(['date', 'fecha', 'eventDate', 'fechaEvento']) ??
        (ev != null ? (ev['fecha'] as String?) : null);
    final dateNum = g<num>(['date', 'fecha', 'eventDate', 'fechaEvento']);
    if (dateStr != null) {
      try {
        // Accept dd-MM-yyyy or ISO
        try {
          date = DateFormat('dd-MM-yyyy').parse(dateStr);
        } catch (_) {
          date = DateTime.parse(dateStr);
        }
      } catch (_) {}
    } else if (dateNum != null) {
      try {
        date = DateTime.fromMillisecondsSinceEpoch(dateNum.toInt());
      } catch (_) {}
    }

    // Status mapping
    String statusRaw = g<String>(['status', 'estado']) ?? '';
    TicketStatus status = TicketStatus.activo;
    switch (statusRaw.toLowerCase()) {
      case 'activo':
      case 'available':
      case 'valid':
      case 'en_venta':
      case 'disponible':
      case 'registrado':
        status = TicketStatus.activo;
        break;
      case 'usado':
      case 'used':
      case 'invalid':
        status = TicketStatus.usado;
        break;
      case 'vendido':
      case 'sold':
      case 'transferido':
        status = TicketStatus.vendido;
        break;
      default:
        status = TicketStatus.activo;
    }

    // Price (if any)
    int purchasePrice = _asInt(g(['precioCompra', 'purchasePrice', 'price', 'precio'])) ?? 0;
    if (purchasePrice == 0 && ticketOfertado is Map) {
      final zona = ticketOfertado['zona'];
      final zp = _asInt(zona is Map ? zona['precio'] : null);
      if (zp != null && zp > 0) purchasePrice = zp;
    }

    // QR data/token
    String qrData = g<String>(['qr', 'qrData', 'token', 'qrToken', 'codigo']) ?? id;
    if (qrData == id && ticketOfertado is Map) {
      final tok = ticketOfertado['token'] ?? ticketOfertado['qrToken'];
      if (tok is String && tok.trim().isNotEmpty) qrData = tok;
    }

    // Seat/zone info
    String seatInfo = g<String>(['seat', 'asiento', 'localidad', 'filaAsiento']) ?? '';
    final zona = (ticketOfertado is Map) ? ticketOfertado['zona'] : raw['zona'];
    if (seatInfo.isEmpty && zona is Map) {
      final zn = zona['nombre'] as String?;
      if ((zn ?? '').trim().isNotEmpty) seatInfo = 'Zona: ${zn!.trim()}';
    }

    return MyTicket(
      id: id,
      eventTitle: title,
      venue: venue,
      date: date,
      status: status,
      purchasePrice: purchasePrice,
      qrData: qrData,
      seatInfo: seatInfo,
    );
  }


  int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.round();
    if (v is String) {
      final cleaned = v.replaceAll(RegExp(r'[^0-9.-]'), '');
      return int.tryParse(cleaned);
    }
    return null;
  }
}
