import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import 'package:bombotickets/config/theme/app_theme_new.dart';
import 'package:bombotickets/features/shared/widgets/animated_background.dart';
import 'package:bombotickets/features/shared/utils/responsive.dart';
import 'package:bombotickets/features/shared/widgets/app_card.dart';

import 'package:bombotickets/features/profile/models/CuentaBancariaModels.dart';
import 'package:bombotickets/features/profile/repositories/cuenta_bancaria.repository.dart';
import 'package:bombotickets/features/profile/presentation/cuenta_bancaria_list.screen.dart';
import 'package:bombotickets/features/profile/presentation/cuenta_bancaria_form.screen.dart';

class CuentaBancariaDetalleScreen extends ConsumerStatefulWidget {
  static const name = 'cuenta-bancaria-detalle';
  final CuentaBancaria account;

  const CuentaBancariaDetalleScreen({super.key, required this.account});

  @override
  ConsumerState<CuentaBancariaDetalleScreen> createState() =>
      _CuentaBancariaDetalleScreenState();
}

class _CuentaBancariaDetalleScreenState
    extends ConsumerState<CuentaBancariaDetalleScreen> {
  bool _loading = false;
  late CuentaBancaria _account;

  @override
  void initState() {
    super.initState();
    _account = widget.account;
    log('[Detalle] init -> $_account');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final res = Responsive.of(context);

    return AnimatedBackground(
      style: BackgroundStyle.surface,
      animated: true,
      intensity: 0.6,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'Detalle de cuenta',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: theme.colorScheme.onSurface,
          actions: [
            IconButton(
              tooltip: 'Editar',
              icon: const Icon(Icons.edit),
              onPressed: _loading ? null : _goToEditForm,
            ),
            IconButton(
              tooltip: 'Eliminar',
              icon: const Icon(Icons.delete_outline),
              color: Colors.red,
              onPressed: _loading ? null : _confirmDelete,
            ),
          ],
        ),
        body: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.all(AppTheme.spacingMedium),
                child: AppCard(
                  padding: EdgeInsets.all(AppTheme.spacingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _chip(
                            _account.banco.isEmpty ? 'Banco —' : _account.banco,
                            AppTheme.primaryColor,
                          ),
                          if (_account.esPrincipal)
                            _chip('Principal', Colors.green),
                          if (_account.estado.isNotEmpty)
                            _chip(_account.estado, Colors.blue),
                        ],
                      ),
                      const SizedBox(height: 16),

                      _kvRow('Banco', _account.banco.isEmpty ? '—' : _account.banco),
                      _kvRow('Número de cuenta',
                          _account.numeroCuenta.isEmpty ? '—' : _account.numeroCuenta),
                      _kvRow('Principal', _account.esPrincipal ? 'Sí' : 'No'),
                      _kvRow('Estado', _account.estado.isEmpty ? '—' : _account.estado),
                      if (_account.id != null) _kvRow('ID', _account.id!),

                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _loading || _account.esPrincipal
                                  ? null
                                  : _markAsPrincipal,
                              icon: const Icon(Icons.star_rounded),
                              label: Text(_account.esPrincipal
                                  ? 'Ya es principal'
                                  : 'Marcar como principal'),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                    color: AppTheme.primaryColor, width: 1.4),
                                foregroundColor: AppTheme.primaryColor,
                                padding: EdgeInsets.symmetric(
                                  vertical: AppTheme.spacingNormal,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      AppTheme.borderRadiusSmall),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: AppTheme.spacingSmall),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _loading ? null : _goToEditForm,
                              icon: const Icon(Icons.edit_rounded),
                              label: const Text('Editar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  vertical: AppTheme.spacingNormal,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      AppTheme.borderRadiusSmall),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: _loading ? null : _confirmDelete,
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        label: const Text(
                          'Eliminar',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (_loading)
                Container(
                  color: Colors.black.withOpacity(0.08),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          color: color,
          fontSize: AppTheme.fontSizeBodyNormal,
        ),
      ),
    );
  }

  Widget _kvRow(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              k,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(v, style: GoogleFonts.inter()),
          ),
        ],
      ),
    );
  }

  Future<void> _markAsPrincipal() async {
  if (_account.id == null) {
    _showSnack('No se puede marcar como principal: falta ID', isError: true);
    return;
  }
  setState(() => _loading = true);
  try {
    final repo = ref.read(cuentaBancariaRepositoryProvider);

    final body = <String, dynamic>{
      'numeroCuenta': _account.numeroCuenta,
      'banco': _account.banco,
      'esPrincipal': true,
      'estado': _account.estado.isEmpty ? 'VERIFICADA' : _account.estado,
    };

    await repo.putCuentaBanco(id: _account.id!, body: body);

    setState(() {
      _account = CuentaBancaria(
        id: _account.id,
        numeroCuenta: _account.numeroCuenta,
        banco: _account.banco,
        esPrincipal: true,
        estado: _account.estado.isNotEmpty ? _account.estado : 'VERIFICADA',
      );
    });

    ref.invalidate(cuentasBancariasProvider);
    _showSnack('Marcada como principal');
  } catch (e) {
    _showSnack('Error al marcar como principal: $e', isError: true);
  } finally {
    if (mounted) setState(() => _loading = false);
  }
}


  void _goToEditForm() {
    context.pushNamed(
      BankAccountFormScreen.name,
      extra: BankAccountFormArgs.edit(_account),
    );
  }

  Future<void> _confirmDelete() async {
    if (_account.id == null) {
      _showSnack('No se puede eliminar: falta ID', isError: true);
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar cuenta'),
        content: const Text('¿Seguro que deseas eliminar esta cuenta bancaria?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await _deleteAccount();
    }
  }

  Future<void> _deleteAccount() async {
    setState(() => _loading = true);
    try {
      final repo = ref.read(cuentaBancariaRepositoryProvider);
      await repo.deleteCuentaBanco(_account.id!);

      ref.invalidate(cuentasBancariasProvider);
      if (mounted) Navigator.pop(context);
      _showSnack('Cuenta eliminada');
    } catch (e) {
      _showSnack('Error al eliminar: $e', isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }
}
