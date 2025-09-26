import 'package:flutter/foundation.dart';

class CuentaBancaria {
  final String? id;
  final String numeroCuenta;
  final String banco;
  final bool esPrincipal;
  final String estado;

  const CuentaBancaria({
    this.id,
    required this.numeroCuenta,
    required this.banco,
    required this.esPrincipal,
    required this.estado,
  });

  factory CuentaBancaria.fromMap(Map<String, dynamic> m) {
    return CuentaBancaria(
      id: (m['id'] ?? m['cuentaId'] ?? m['ID'])?.toString(),
      numeroCuenta: (m['numeroCuenta'] ?? m['numero'] ?? m['numero_cuenta'] ?? '').toString(),
      banco: (m['nombreBanca'] ?? m['banco'] ?? m['nombre_banca'] ?? '').toString(),
      esPrincipal: m['esPrincipal'] is bool
          ? (m['esPrincipal'] as bool)
          : (m['es_principal']?.toString() == 'true' || m['esPrincipal']?.toString() == 'true'),
      estado: (m['estado'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'numeroCuenta': numeroCuenta,
        'nombreBanca': banco,
        'esPrincipal': esPrincipal,
        'estado': estado,
      };

  @override
  String toString() =>
      'CuentaBancaria(id=$id, banco=$banco, numero=$numeroCuenta, principal=$esPrincipal, estado=$estado)';
}

/// Modo del formulario
enum BankFormMode { create, edit }

/// Args para el form (distingue crear/editar)
@immutable
class BankAccountFormArgs {
  final BankFormMode mode;
  final CuentaBancaria? account;

  const BankAccountFormArgs._(this.mode, this.account);

  const BankAccountFormArgs.create() : this._(BankFormMode.create, null);
  const BankAccountFormArgs.edit(CuentaBancaria a) : this._(BankFormMode.edit, a);
}
