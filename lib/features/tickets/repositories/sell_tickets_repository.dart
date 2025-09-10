import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bombotickets/config/environment.dart';
import 'dart:developer' show log;
import 'dart:convert';

class SellTicketsRepository {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: Environment.apiUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
    ),
  );

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
      String addBearer(String t) => t.trim().startsWith('Bearer ')
          ? t.trim()
          : 'Bearer ${t.trim()}';
      String stripBearer(String t) => t.trim().startsWith('Bearer ')
          ? t.trim().substring(7).trim()
          : t.trim();

      final tokensWithBearer = qrTokens.map(addBearer).toList();
      final tokensWithoutBearer = qrTokens.map(stripBearer).toList();
      final offeredInt = precioOfertado.round();

      void _logAttempt(String label, Map<String, dynamic> payload) {
        try {
          final qt = payload['qrTokens'];
          final qtCount = qt is List ? qt.length : 0;
          final safe = Map<String, dynamic>.from(payload);
          if (safe.containsKey('qrTokens')) safe['qrTokens'] = '[${qtCount} tokens]';
          log('[Marketplace] Attempt $label payload=${jsonEncode(safe)}');
        } catch (_) {}
      }

      void _logDioError(String label, DioException e) {
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

      Future<Response<dynamic>> postPayload(Map<String, dynamic> payload, String label) {
        _logAttempt(label, payload);
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
          _logDioError('primary', e);
          // Alt A: tokens without Bearer
          try {
            final r = await postPayload({
              'qrTokens': tokensWithoutBearer,
              'cantidad': cantidad,
              'precioOfertado': offeredInt,
            }, 'altA_noBearer');
            if (r.statusCode == 200 || r.statusCode == 201) return r.data;
          } on DioException catch (eA) {
            _logDioError('altA_noBearer', eA);
          }

          // Alt B: wrap in 'entrada'
          try {
            final r = await postPayload({'entrada': primary}, 'altB_wrapped');
            if (r.statusCode == 200 || r.statusCode == 201) return r.data;
          } on DioException catch (eB) {
            _logDioError('altB_wrapped', eB);
          }

          // Alt C: wrap + tokens without Bearer
          try {
            final r = await postPayload({
              'entrada': {
                'qrTokens': tokensWithoutBearer,
                'cantidad': cantidad,
                'precioOfertado': offeredInt,
              }
            }, 'altC_wrapped_noBearer');
            if (r.statusCode == 200 || r.statusCode == 201) return r.data;
          } on DioException catch (eC) {
            _logDioError('altC_wrapped_noBearer', eC);
          }

          // If all alternatives fail, rethrow original
          rethrow;
        } else {
          _logDioError('non-400', e);
          rethrow;
        }
      }

      throw Exception('Error al publicar: respuesta no exitosa');
    } catch (e) {
      if (e is DioException) {
        final data = e.response?.data;
        String msg = e.message ?? 'Error de red';
        if (data is Map) {
          if (data['mensaje'] != null) msg = data['mensaje'].toString();
          else if (data['message'] != null) msg = data['message'].toString();
          else if (data['error'] != null) msg = data['error'].toString();
          else if (data['errors'] != null) msg = data['errors'].toString();
        } else if (data != null) {
          msg = data.toString();
        }
        log('[Marketplace] Throwing error: $msg');
        throw Exception('Error al publicar: $msg');
      }
      rethrow;
    }
  }
}
