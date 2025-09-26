import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:bombotickets/config/theme/app_theme_new.dart';
import 'package:bombotickets/features/shared/utils/responsive.dart';
import 'package:bombotickets/features/shared/widgets/animated_background.dart';
import 'package:bombotickets/features/shared/widgets/app_card.dart';

import 'package:bombotickets/features/auth/providers/auth_provider.dart';
import 'package:bombotickets/features/profile/providers/profile_provider.dart';
import 'package:bombotickets/features/profile/providers/cuenta_bancaria.provider.dart';
import 'package:bombotickets/features/profile/models/CuentaBancariaModels.dart';

class BankAccountFormScreen extends ConsumerStatefulWidget {
  static const name = 'bank-account-form';
  final BankAccountFormArgs args;
  const BankAccountFormScreen({super.key, required this.args});

  @override
  ConsumerState<BankAccountFormScreen> createState() =>
      _BankAccountFormScreenState();
}

class _BankAccountFormScreenState extends ConsumerState<BankAccountFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _numeroCtrl;
  late final TextEditingController _bancoCtrl;

  bool _saving = false;
  bool _esPrincipal = false;

  bool get _isEdit => widget.args.mode == BankFormMode.edit;

  @override
  void initState() {
    super.initState();

    if (_isEdit && widget.args.account != null) {
      final a = widget.args.account!;
      _numeroCtrl = TextEditingController(text: a.numeroCuenta);
      _bancoCtrl  = TextEditingController(text: a.banco);
      _esPrincipal = a.esPrincipal;
      log('[BankForm] EDIT -> precargado con $a');
    } else {
      _numeroCtrl = TextEditingController();
      _bancoCtrl  = TextEditingController();
      _esPrincipal = false;
      log('[BankForm] CREATE -> vacío');
    }
  }

  @override
  void dispose() {
    _numeroCtrl.dispose();
    _bancoCtrl.dispose();
    super.dispose();
  }

  String _getEmail() {
    final authEmail = ref.read(authProvider).user?.username ?? '';
    final cachedEmail = ref.read(profileProvider).email;
    return authEmail.isNotEmpty ? authEmail : cachedEmail;
  }

  Future<void> _onSave() async {
  if (!_formKey.currentState!.validate()) return;

  final email = _getEmail();
  if (email.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No se encontró el email del usuario')),
    );
    return;
  }

  setState(() => _saving = true);
  try {
    final String? id = _isEdit ? widget.args.account?.id : null;

    await ref.read(cuentaBancarioProvider.notifier).saveBankData(
      numeroCuenta: _numeroCtrl.text.trim(),
      banco: _bancoCtrl.text.trim(),
      esPrincipal: _esPrincipal,
      estado: '',
      id: id,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isEdit ? 'Cambios guardados' : 'Cuenta creada')),
    );
    Navigator.of(context).pop();
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al guardar: $e')),
    );
  } finally {
    if (mounted) setState(() => _saving = false);
  }
}

  @override
  Widget build(BuildContext context) {
    final res = Responsive.of(context);

    return AnimatedBackground(
      style: BackgroundStyle.surface,
      animated: true,
      intensity: 0.6,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            _isEdit ? 'Editar cuenta' : 'Nueva cuenta',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.all(AppTheme.spacingMedium),
            child: AppCard(
              padding: EdgeInsets.all(AppTheme.spacingMedium),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Número de cuenta
                    Padding(
                      padding: EdgeInsets.only(bottom: AppTheme.spacingNormal),
                      child: TextFormField(
                        controller: _numeroCtrl,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        validator: (v) {
                          final value = (v ?? '').trim();
                          if (value.isEmpty) return 'Ingresa tu número de cuenta';
                          if (!RegExp(r'^\d{6,}$').hasMatch(value)) {
                            return 'Solo dígitos (mín. 6)';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Número de Cuenta',
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppTheme.borderRadiusSmall),
                          ),
                        ),
                      ),
                    ),

                    // Banco
                    Padding(
                      padding: EdgeInsets.only(bottom: AppTheme.spacingNormal),
                      child: TextFormField(
                        controller: _bancoCtrl,
                        textInputAction: TextInputAction.done,
                        validator: (v) {
                          final value = (v ?? '').trim();
                          if (value.isEmpty) return 'Ingresa el banco';
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Banco',
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(AppTheme.borderRadiusSmall),
                          ),
                        ),
                      ),
                    ),

                    // Es principal
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Cuenta principal'),
                      value: _esPrincipal,
                      onChanged: (v) => setState(() => _esPrincipal = v),
                    ),

                    SizedBox(height: AppTheme.spacingLarge),

                    // Botones
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _saving ? null : () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: res.hp(1.2)),
                            ),
                            child: const Text('Cancelar'),
                          ),
                        ),
                        SizedBox(width: res.wp(3)),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saving ? null : _onSave,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: res.hp(1.2)),
                            ),
                            child: _saving
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : Text(_isEdit ? 'Guardar cambios' : 'Crear'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
