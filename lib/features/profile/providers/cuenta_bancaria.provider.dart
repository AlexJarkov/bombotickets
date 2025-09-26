import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bombotickets/features/profile/repositories/cuenta_bancaria.repository.dart';

class CuentaBancariaState {
  final String numeroCuenta;
  final String banco;
  final bool esPrincipal;
  final String estado;

  const CuentaBancariaState({
    this.numeroCuenta = '',
    this.banco = '',
    this.esPrincipal = false,
    this.estado = '',
  });

  CuentaBancariaState copyWith({
    String? numeroCuenta,
    String? banco,
    bool? esPrincipal,
    String? estado,
  }) {
    return CuentaBancariaState(
      numeroCuenta: numeroCuenta ?? this.numeroCuenta,
      banco: banco ?? this.banco,
      esPrincipal: esPrincipal ?? this.esPrincipal,
      estado: estado ?? this.estado,
    );
  }
}

final cuentaBancarioProvider =
    StateNotifierProvider<CuentaBancarioNotifier, CuentaBancariaState>((ref) {
  return CuentaBancarioNotifier(ref);
});

class CuentaBancarioNotifier extends StateNotifier<CuentaBancariaState> {
  final Ref ref;
  CuentaBancarioNotifier(this.ref) : super(const CuentaBancariaState()) {
    _load();
  }

  static const _kNumero = 'cuentaBancaria.numeroCuenta';
  static const _kBanco = 'cuentaBancaria.banco';
  static const _kPrincipal = 'cuentaBancaria.esPrincipal';
  static const _kEstado = 'cuentaBancaria.estado';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();

    final numeroCuenta = prefs.getString(_kNumero) ?? '';
    final banco = prefs.getString(_kBanco) ?? '';
    final esPrincipal =
        prefs.getBool(_kPrincipal) ?? prefs.getBool('cuentaBancario.esPrincipal') ?? false;
    final estado =
        prefs.getString(_kEstado) ?? prefs.getString('cuentaBancario.estado') ?? '';

    state = state.copyWith(
      numeroCuenta: numeroCuenta,
      banco: banco,
      esPrincipal: esPrincipal,
      estado: estado,
    );

    log('[CuentaBancaria] _load() -> $state');
  }

  Future<void> _saveToLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kNumero, state.numeroCuenta);
    await prefs.setString(_kBanco, state.banco);
    await prefs.setBool(_kPrincipal, state.esPrincipal);
    await prefs.setString(_kEstado, state.estado);
    log('[CuentaBancaria] _saveToLocal() -> $state');
  }

  CuentaBancariaState _fromRemoteMap(Map<String, dynamic> m) {
    final numeroCuenta = (m['numeroCuenta'] ?? m['numero_cuenta'] ?? '').toString();
    final nombreBanca =
        (m['nombreBanca'] ?? m['banco'] ?? m['nombre_banca'] ?? '').toString();
    final esPrincipal = (m['esPrincipal'] is bool)
        ? m['esPrincipal'] as bool
        : (m['es_principal']?.toString() == 'true' ||
            m['esPrincipal']?.toString() == 'true');
    final estado = (m['estado'] ?? '').toString();

    return CuentaBancariaState(
      numeroCuenta: numeroCuenta,
      banco: nombreBanca,
      esPrincipal: esPrincipal,
      estado: estado,
    );
  }

  Future<void> syncFromServer(String email) async {
    log('[CuentaBancaria] syncFromServer(email=$email)');
    final repo = ref.read(cuentaBancariaRepositoryProvider);

    final res = await repo.getCuentas();
    log('[CuentaBancaria] getCuentas() -> $res');

    dynamic data = res['data'] ?? res;
    Map<String, dynamic>? obj;

    if (data is Map<String, dynamic>) {
      obj = data;
    } else if (data is List && data.isNotEmpty) {
      final dynamic principal = data.firstWhere(
        (e) => (e is Map && (e['esPrincipal'] == true || e['es_principal'] == true)),
        orElse: () => data.first,
      );
      if (principal is Map<String, dynamic>) obj = principal;
    }

    if (obj != null) {
      final newState = _fromRemoteMap(obj);
      state = state.copyWith(
        numeroCuenta: newState.numeroCuenta,
        banco: newState.banco,
        esPrincipal: newState.esPrincipal,
        estado: newState.estado,
      );
      await _saveToLocal();
      log('[CuentaBancaria] syncFromServer() OK -> $state');
    } else {
      log('[CuentaBancaria] syncFromServer() sin datos remotos, manteniendo local');
    }
  }

  Future<void> saveBankData({
  required String numeroCuenta,
  required String banco,
  required bool esPrincipal,
  String estado = '',
  String? usuarioId,
  String? id,
}) async {
  state = state.copyWith(
    numeroCuenta: numeroCuenta.trim(),
    banco: banco.trim(),
    esPrincipal: esPrincipal,
    estado: estado,
  );
  log('[CuentaBancaria] saveBankData -> optimistic $state (id=$id)');

  final repo = ref.read(cuentaBancariaRepositoryProvider);

  final payload = <String, dynamic>{
    if (usuarioId != null) 'usuarioId': usuarioId,
    'numeroCuenta': state.numeroCuenta,
    'banco': state.banco,
    'esPrincipal': state.esPrincipal,
    'estado': state.estado,
  };

  try {
    if (id == null) {
      log('[CuentaBancaria] POST payload=$payload');
      await repo.postCuentaBanco(payload);
    } else {
      log('[CuentaBancaria] PUT id=$id payload=$payload');
      await repo.putCuentaBanco(id: id, body: payload);
    }
    await _saveToLocal();
  } catch (e) {
    log('[CuentaBancaria] saveBankData() error: $e');
    await _saveToLocal();
    rethrow;
  }
}
}
