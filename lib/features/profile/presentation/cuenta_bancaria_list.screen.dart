import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:bombotickets/config/theme/app_theme_new.dart';
import 'package:bombotickets/features/shared/utils/responsive.dart';
import 'package:bombotickets/features/shared/widgets/animated_background.dart';
import 'package:bombotickets/features/shared/widgets/app_card.dart';
import 'package:bombotickets/features/shared/widgets/glass_card.dart';

import 'package:bombotickets/features/profile/models/CuentaBancariaModels.dart';
import 'package:bombotickets/features/profile/repositories/cuenta_bancaria.repository.dart';
import 'package:bombotickets/features/profile/presentation/cuenta_bancario_detail.screen.dart';
import 'package:bombotickets/features/profile/presentation/cuenta_bancaria_form.screen.dart';

final cuentasBancariasProvider =
    FutureProvider.autoDispose<List<CuentaBancaria>>((ref) async {
  final repo = ref.read(cuentaBancariaRepositoryProvider);
  final raw = await repo.getCuentas();
  log('[cuentasBancariasProvider] raw=$raw');

  final root = raw['data'] ?? raw;
  List list;

  if (root is List) {
    list = root;
  } else if (root is Map) {
    if (root['cuentas'] is List) {
      list = root['cuentas'];
    } else if (root['cuentasBancarias'] is List) {
      list = root['cuentasBancarias'];
    } else {
      list = const [];
    }
  } else {
    list = const [];
  }

  return list
      .whereType<Map>()
      .map((e) => CuentaBancaria.fromMap(e.cast<String, dynamic>()))
      .toList();
});

/// Pantalla de listado
class MisCuentasBancariasScreen extends ConsumerWidget {
  static const name = 'mis-cuentas-bancarias';
  const MisCuentasBancariasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final res = Responsive.of(context);

    return AnimatedBackground(
      style: BackgroundStyle.surface,
      animated: true,
      intensity: 0.6,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'Mis Cuentas Bancarias',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
          ),
          backgroundColor: Colors.transparent,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Actualizar',
              onPressed: () => ref.invalidate(cuentasBancariasProvider),
            ),
            IconButton(
              icon: const Icon(Icons.add_card_rounded),
              tooltip: 'Agregar cuenta',
              onPressed: () => context.pushNamed(
                BankAccountFormScreen.name,
                extra: const BankAccountFormArgs.create(),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async => ref.invalidate(cuentasBancariasProvider),
            child: Consumer(
              builder: (context, ref, _) {
                final cuentasAsync = ref.watch(cuentasBancariasProvider);

                return cuentasAsync.when(
                  loading: () => const _CenteredLoader(),
                  error: (e, st) => _ErrorView(message: e.toString()),
                  data: (cuentas) {
                    if (cuentas.isEmpty) return const _EmptyView();
                    return ListView.builder(
                      padding: EdgeInsets.all(AppTheme.spacingMedium),
                      itemCount: cuentas.length,
                      itemBuilder: (_, i) => _CuentaCard(
                        account: cuentas[i],
                        res: res,
                        onDetail: () {
                          context.pushNamed(
                           'cuenta-bancaria-detalle', 
                            extra: cuentas[i],
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Card de cuenta
class _CuentaCard extends StatelessWidget {
  final CuentaBancaria account;
  final VoidCallback onDetail;
  final Responsive res;

  const _CuentaCard({
    required this.account,
    required this.onDetail,
    required this.res,
  });

  String _mask(String n) {
    final s = n.replaceAll(' ', '');
    if (s.length <= 4) return s;
    final last4 = s.substring(s.length - 4);
    return '•••• •••• •••• $last4';
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: EdgeInsets.only(bottom: AppTheme.spacingMedium),
      padding: EdgeInsets.all(AppTheme.spacingNormal),
      animated: true,
      child: Row(
        children: [
          Container(
            width: res.dp(5.2),
            height: res.dp(5.2),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.account_balance_rounded),
          ),
          SizedBox(width: AppTheme.spacingNormal),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banco
                Text(
                  account.banco.isEmpty ? 'Banco —' : account.banco,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: AppTheme.fontSizeBodyNormal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),

                // Número (enmascarado)
                Text(
                  account.numeroCuenta.isEmpty
                      ? 'Número de cuenta —'
                      : _mask(account.numeroCuenta),
                  style: GoogleFonts.inter(
                    fontSize: AppTheme.fontSizeBodyNormal,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 8),

                // Chips
                Wrap(
                  spacing: 8,
                  children: [
                    if (account.esPrincipal) _chip('Principal', Colors.green),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(width: AppTheme.spacingNormal),

          ElevatedButton(
            onPressed: onDetail,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Detalle'),
          ),
        ],
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
          fontSize: AppTheme.fontSizeBodyMedium,
        ),
      ),
    );
  }
}

/// Estados
class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AppCard(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.account_balance_outlined, size: 48),
            const SizedBox(height: 8),
            Text(
              'No tiene cuentas bancarias registradas',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: AppTheme.fontSizeBodyLarge,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Agregue una cuenta para recibir pagos.',
              style: GoogleFonts.inter(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => context.pushNamed(
                BankAccountFormScreen.name,
                extra: const BankAccountFormArgs.create(),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Agregar cuenta'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenteredLoader extends StatelessWidget {
  const _CenteredLoader();
  @override
  Widget build(BuildContext context) => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      );
}

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: AppCard(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 8),
            Text('Error al cargar',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(message, style: GoogleFonts.inter(), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
