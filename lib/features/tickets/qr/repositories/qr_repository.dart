import 'dart:developer';
import 'package:bombotickets/config/environment.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
//import 'package:paybox_app/features/shared/infrastructure/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
// qr_repository.dart
import 'dart:convert';

class QrRepository {
  final Ref ref;
  final Dio _dio;

  QrRepository(this.ref)
 : _dio = Dio(
          BaseOptions(
            baseUrl: "https://vpay.com.bo:7778",
            connectTimeout: const Duration(seconds: 20),
            receiveTimeout: const Duration(seconds: 30),
            // Para ver el body aunque el status sea 4xx/5xx
            validateStatus: (_) => true,
          ),
        ) {
    // ===== Interceptor de logs =====
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final safeHeaders = Map<String, dynamic>.from(options.headers);
          if (safeHeaders.containsKey('Authorization')) {
            safeHeaders['Authorization'] = 'Bearer ***'; // oculta token
          }
          log('[REQ] ${options.method} ${options.uri}', name: 'DIO');
          log('headers=$safeHeaders', name: 'DIO');
          try {
            log('body=${const JsonEncoder.withIndent("  ").convert(options.data)}', name: 'DIO');
          } catch (_) {
            log('body(raw)=${options.data}', name: 'DIO');
          }
          handler.next(options);
        },
        onResponse: (res, handler) {
          log('[RES] ${res.statusCode} ${res.requestOptions.uri}', name: 'DIO');
          try {
            log('body=${const JsonEncoder.withIndent("  ").convert(res.data)}', name: 'DIO');
          } catch (_) {
            log('body(raw)=${res.data}', name: 'DIO');
          }
          handler.next(res);
        },
        onError: (e, handler) {
          log('[ERR] ${e.type} ${e.message}', name: 'DIO');
          if (e.response != null) {
            log('status=${e.response?.statusCode} url=${e.requestOptions.uri}', name: 'DIO');
            try {
              log('body=${const JsonEncoder.withIndent("  ").convert(e.response?.data)}', name: 'DIO');
            } catch (_) {
              log('body(raw)=${e.response?.data}', name: 'DIO');
            }
          }
          handler.next(e);
        },
      ),
    );
  }

  //
    //: _dio = Dio(BaseOptions(baseUrl: "https://vpay.com.bo:7778"));

  Future<Map<String, dynamic>> generateQR({
    required double monto,
    required double porcentaje,
    required double bolivianos,
    required int cantidad,
    required String additionalData,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      //final username = prefs.getString('username');
      //final companyId = prefs.getString('companyId');
      final envToken = Environment.token;
      final token = prefs.getString('token');
      log("TOKEN GENERAR QR $token");
      
      log("TOKEN GENERAR QR $envToken");
      


      /*
      if (username == null || companyId == null) {
        throw Exception('No autenticado o datos de usuario incompletos');
      }
      */

      //String montoRedondeado = truncateToTwoDecimals(monto);
      //double montoDouble = double.parse(montoRedondeado);

      //final empresa =
        //  Constants.companies.firstWhere((c) => c['id'] == companyId)['name']!;


      // Formatear fecha de expiración (hoy + 1 día)
      final expirationDate = DateFormat(
        'yyyy-MM-dd',
      ).format(DateTime.now().add(const Duration(days: 1)));

      var data = {
        "operation": "VTO041",
        "header": [
          {"attribute": "currency", "value": "BOB"},
          {
            "attribute": "gloss",
            "value": "PAYBOX COBRO SERVICIO TICKETERA",
          },
          {"attribute": "amount", "value": monto.toStringAsFixed(2)},
          {"attribute": "singleUse", "value": "true"},
          {"attribute": "expirationDate", "value": expirationDate},
          {"attribute": "additionalData", "value": additionalData},
          {"attribute": "destinationAccountId", "value": "121100"},
          {"attribute": "bank", "value": "BMSC"},
          {"attribute": "user", "value": "compradorTicket"},
          {"attribute": "company", "value": "192"},
          //{"attribute": "typeVoucher", "value": typeVoucher}
        ],
        "detail": [
          {
            "items": [
              {
                "attribute": "total_original",
                "value": (monto - bolivianos).toStringAsFixed(2),
              },
              {"attribute": "propina_porcentaje", "value": porcentaje},
              {
                "attribute": "propina_bs",
                "value": bolivianos.toStringAsFixed(2),
              },
              //{"attribute": "paso", "value": paso + 1},
              {"attribute": "cantidad_tickets", "value": cantidad},
            ],
          },
        ],
      };

      log("QR REQUEST DATA: $data");

      final response = await _dio.put(
        '/pro/api/transactions/doPayment',
        options: Options(headers: {"Authorization": envToken}),
        data: data,
      );

      log("QR GENERATE RESPONSE: ${response.data}");

      // Check if the server returned an error
        if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}: ${response.statusMessage}');
      }

      if (response.data is! Map || response.data['status'] != 'OK') {
        final msg = (response.data is Map ? response.data['message'] : null) ?? 'Error al generar QR';
        throw Exception(msg);
      }

      final responseList =
          response.data['responseList']?[0]['response'] as List?;
      if (responseList == null) throw Exception('Datos de QR no encontrados');

      String? qrId;
      String? qrImage;

      for (var item in responseList) {
        if (item['code'] == 'idQr') {
          qrId = item['identificator'];
        } else if (item['code'] == 'QR') {
          qrImage = item['identificator'];
        }
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
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw Exception('No autenticado');

      final response = await _dio.post(
        '/pro/api/operations/statusQr',
        options: Options(headers: {"Authorization": token}),
        data: {"operation": qrId},
      );

      log("QR CHECK STATUS RESPONSE: ${response.data}");

      if (response.data['status'] != 'OK') {
        throw Exception(
          response.data['message'] ?? 'Error al verificar estado',
        );
      }

      final responseList =
          response.data['responseList']?[0]['response'] as List?;
      if (responseList == null)
        throw Exception('Datos de estado no encontrados');

      for (var item in responseList) {
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
          e.response!.data['message'] ?? 'Error al verificar estado',
        );
      }
      throw Exception(e.message ?? 'Error de conexión');
    } catch (e) {
      throw Exception('Error al verificar estado: ${e.toString()}');
    }
  }
}

String truncateToTwoDecimals(double value) {
  final truncated = (value * 100).truncate() / 100.0;
  return truncated.toStringAsFixed(2);
}

final qrRepositoryProvider = Provider((ref) => QrRepository(ref));
// empresa 192 , y de nombre TICKETERA