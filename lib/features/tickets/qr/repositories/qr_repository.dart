// lib/features/tickets/qr/repositories/qr_repository.dart
import 'dart:convert';
import 'dart:developer';
import 'package:bombotickets/config/environment.dart';
import 'package:bombotickets/features/profile/repositories/profile_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QrRepository {
  final Ref ref;
  final Dio _dio;
  final Dio _backend;
  final ProfileRepository _profile;

  QrRepository(this.ref)
      : _profile = ref.read(profileRepositoryProvider),
        _dio = Dio(
          BaseOptions(
            baseUrl: 'https://vpay.com.bo:7778',
            connectTimeout: const Duration(seconds: 20),
            receiveTimeout: const Duration(seconds: 30),
            validateStatus: (_) => true,
          ),
        ),
        _backend = Dio(
          BaseOptions(
            baseUrl: Environment.apiUrl,
            connectTimeout: const Duration(seconds: 20),
            receiveTimeout: const Duration(seconds: 30),
            validateStatus: (_) => true,
          ),
        ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final safeHeaders = Map<String, dynamic>.from(options.headers);
          if (safeHeaders.containsKey('Authorization')) {
            safeHeaders['Authorization'] = 'Bearer ***';
          }
          log('[REQ] ${options.method} ${options.uri}', name: 'VPay');
          log('req.headers=$safeHeaders', name: 'VPay');
          if (options.data != null) {
            log('req.body=${options.data}', name: 'VPay');
          }
          handler.next(options);
        },
        onResponse: (res, handler) {
          log('[RES] ${res.statusCode} ${res.requestOptions.uri}', name: 'VPay');
          log('res.headers=${res.headers.map}', name: 'VPay');
          log('res.body=${res.data}', name: 'VPay');
          handler.next(res);
        },
        onError: (e, handler) {
          log('[ERR] ${e.type} ${e.message}', name: 'VPay');
          final r = e.response;
          if (r != null) {
            log('res.status=${r.statusCode} url=${e.requestOptions.uri}', name: 'VPay');
            log('res.headers=${r.headers.map}', name: 'VPay');
            log('res.body=${r.data}', name: 'VPay');
          }
          handler.next(e);
        },
      ),
    );

    _backend.interceptors.add(
      InterceptorsWrapper(
        onRequest: (o, h) {
          final safeHeaders = Map<String, dynamic>.from(o.headers);
          if (safeHeaders.containsKey('Authorization')) {
            safeHeaders['Authorization'] = 'Bearer ***';
          }
          log('[B-REQ] ${o.method} ${o.uri}', name: 'API');
          log('req.headers=$safeHeaders', name: 'API');
          if (o.data != null) {
            log('req.body=${o.data}', name: 'API');
          }
          h.next(o);
        },
        onResponse: (r, h) {
          log('[B-RES] ${r.statusCode} ${r.requestOptions.uri}', name: 'API');
          log('res.headers=${r.headers.map}', name: 'API');
          log('res.body=${r.data}', name: 'API');
          h.next(r);
        },
        onError: (e, h) {
          log('[B-ERR] ${e.type} ${e.message}', name: 'API');
          final r = e.response;
          if (r != null) {
            log('res.status=${r.statusCode} url=${e.requestOptions.uri}', name: 'API');
            log('res.headers=${r.headers.map}', name: 'API');
            log('res.body=${r.data}', name: 'API');
          }
          h.next(e);
        },
      ),
    );
  }

  Map<String, dynamic>? _decodeJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      return json.decode(payload) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<String?> _emailFromToken() async {
    final prefs = await SharedPreferences.getInstance();
    final t = prefs.getString('token');
    if (t == null || t.isEmpty) return null;
    final p = _decodeJwt(t);
    return (p?['email'] ?? p?['correo'] ?? p?['sub'] ?? p?['username'])?.toString();
  }

  Future<Map<String, dynamic>> generateQR({
    required double monto,
    required double porcentaje,
    required double bolivianos,
    required int cantidad,
    required String additionalData,
    String? correoCliente,
    String? correoVendedor,
    String? nombreEvento,
    String? nombreZona,
    int? publicacionId,
  }) async {
    try {
      final envToken = Environment.token;

      

      final compradorEmail = correoCliente ??
        await _emailFromToken() ??
        (throw Exception('No se pudo determinar el correo del cliente'));

    final userClienteResponse = await _profile.getUserByEmail(compradorEmail);
    final userCliente = userClienteResponse['data'] as Map<String, dynamic>?;  // ← ACCEDE A 'data'
    if (userCliente == null) {
      throw Exception('No se encontraron datos del usuario cliente para $compradorEmail');
    }

    Map<String, dynamic>? userVendedorResponse;
    Map<String, dynamic>? userVendedor;
    if ((correoVendedor ?? '').isNotEmpty) {
      userVendedorResponse = await _profile.getUserByEmail(correoVendedor!);
      userVendedor = userVendedorResponse['data'] as Map<String, dynamic>?;  // ← ACCEDE A 'data'
      if (userVendedor == null) {
        log('Advertencia: No se encontraron datos del vendedor para $correoVendedor');
        // Opcional: throw si es crítico
      }
    }

     final nombreCliente = userCliente['nombres']?.toString().trim() ?? 'Cliente Anónimo';  // ← Mejora: default amigable
    final apellidoPCliente = userCliente['apellidoP']?.toString().trim() ?? '';
    final apellidoMCliente = userCliente['apellidoM']?.toString().trim() ?? '';

    final nombreVend = userVendedor?['nombres']?.toString().trim() ?? (correoVendedor ?? 'Vendedor Anónimo');
    final apellidoPVend = userVendedor?['apellidoP']?.toString().trim() ?? '';
    final apellidoMVend = userVendedor?['apellidoM']?.toString().trim() ?? '';

    // Valida evento y zona (agrega defaults o required si son obligatorios)
    final eventoFinal = nombreEvento?.trim() ?? 'Evento Desconocido';
    final zonaFinal = nombreZona?.trim() ?? 'Zona Desconocida';

      final expirationDate = DateFormat('yyyy-MM-dd')
          .format(DateTime.now().add(const Duration(days: 1)));

      final header = <Map<String, dynamic>>[
        {"attribute": "currency", "value": "BOB"},
        {"attribute": "gloss", "value": "PAYBOX COBRO SERVICIO TICKETERA"},
        {"attribute": "amount", "value": monto.toStringAsFixed(2)},
        {"attribute": "singleUse", "value": "true"},
        {"attribute": "expirationDate", "value": expirationDate},
        {"attribute": "additionalData", "value": additionalData},
        {"attribute": "destinationAccountId", "value": "121100"},
        {"attribute": "bank", "value": "BMSC"},
        {"attribute": "user", "value": "compradorTicket"},
        {"attribute": "company", "value": "192"}
      ];
      final data = {
        "operation": "VTO041",
        "header": header,
        "detail": [
          {
            "items": [
              {
                "attribute": "total_original",
                "value": (monto - bolivianos).toStringAsFixed(2),
              },
              {"attribute": "propina_porcentaje", "value": porcentaje},
              {"attribute": "propina_bs", "value": bolivianos.toStringAsFixed(2)},
              {"attribute": "cantidad_tickets", "value": cantidad},
        {"attribute": "NOMBRE CLIENTE", "value": nombreCliente},
        {"attribute": "APELLIDO CLIENTE", "value": apellidoPCliente},
        {"attribute": "CORREO", "value": compradorEmail},
          {"attribute": "NOMBRE VENDEDOR", "value": nombreVend},
          {"attribute": "APELLIDO PATERNO VENDEDOR", "value": apellidoPVend},
          {"attribute": "APELLIDO MATERNO VENDEDOR", "value": apellidoMVend},
          {"attribute": "CORREO VENDEDOR", "value": correoVendedor},
       {"attribute": "EVENTO", "value": eventoFinal},
       {"attribute": "ZONA", "value": zonaFinal},
       {"attribute":"Publicacion ID","value" :publicacionId}
            ],
          },
        ],
      };


      final response = await _dio.put(
        '/test/api/transactions/doPayment',
        options: Options(headers: {"Authorization": envToken}),
        data: data,
      );

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}: ${response.statusMessage}');
      }
      if (response.data is! Map || response.data['status'] != 'OK') {
        final msg = (response.data is Map ? response.data['message'] : null) ??
            'Error al generar QR';
        throw Exception(msg);
      }

      final responseList =
          response.data['responseList']?[0]['response'] as List?;
      if (responseList == null) throw Exception('Datos de QR no encontrados');

      String? qrId;
      String? qrImage;
      for (final item in responseList) {
        if (item['code'] == 'idQr') qrId = item['identificator'];
        if (item['code'] == 'QR') qrImage = item['identificator'];
      }
      if (qrId == null || qrImage == null) {
        throw Exception('No se pudo obtener el ID o imagen del QR');
      }

      return {'qrId': qrId, 'qrImage': qrImage, 'amount': monto};
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Tiempo de conexión agotado');
      }
      if (e.response?.data != null && e.response!.data is Map) {
        throw Exception(e.response!.data['message'] ?? 'Error al generar QR');
      }
      throw Exception(e.message ?? 'Error de conexión');
    } catch (e) {
      throw Exception('Error al generar QR: ${e.toString()}');
    }
  }

  Future<String> checkStatusQR(String qrId) async {
    try {
      final token = Environment.token;
      if (token == null) throw Exception('No autenticado');

      final response = await _dio.post(
        '/test/api/operations/statusQr',
        options: Options(headers: {"Authorization": token}),
        data: {"operation": qrId},
      );

      if (response.data['status'] != 'OK') {
        throw Exception(response.data['message'] ?? 'Error al verificar estado');
      }

      final responseList =
          response.data['responseList']?[0]['response'] as List?;
      if (responseList == null) {
        throw Exception('Datos de estado no encontrados');
      }

      for (final item in responseList) {
        if (item['code'] == 'statusQr') {
          return item['identificator']; // "PEN" o "PAG"
        }
      }
      throw Exception('Estado de QR no encontrado en la respuesta');
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Tiempo de conexión agotado');
      }
      if (e.response?.data != null && e.response!.data is Map) {
        throw Exception(
            e.response!.data['message'] ?? 'Error al verificar estado');
      }
      throw Exception(e.message ?? 'Error de conexión');
    } catch (e) {
      throw Exception('Error al verificar estado: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> getQrDetalles(String idQr) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bearer = prefs.getString('token');

      final res = await _backend.get(
        '/qrDetalles/$idQr',
        options: Options(
          headers: bearer != null ? {'Authorization': 'Bearer $bearer'} : null,
        ),
      );

      if (res.statusCode == 200) {
        final data = res.data;
        if (data is Map<String, dynamic>) return data;
        return {'data': data};
      }
      if (res.statusCode == 204) return {};
      throw Exception(
          'HTTP ${res.statusCode}: ${res.statusMessage ?? 'Error al obtener detalles del QR'}');
    } on DioException catch (e) {
      final msg = e.response?.data ?? e.message ?? 'Error de red';
      throw Exception('Error al obtener detalles del QR: $msg');
    } catch (e) {
      rethrow;
    }
  }
}

final qrRepositoryProvider = Provider<QrRepository>((ref) => QrRepository(ref));
