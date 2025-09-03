import 'package:bombotickets/features/settings/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bombotickets/config/theme/app_theme_new.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';

class SettingsScreen extends ConsumerWidget {
  static const String name = 'settings';

  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(
          'Configuración',
          style: GoogleFonts.poppins(
            fontSize: AppTheme.fontSizeH3,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
        ),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: AppTheme.spacingNormal,
          vertical: AppTheme.spacingSmall,
        ),
        children: [
          Card(
            margin: EdgeInsets.symmetric(vertical: AppTheme.spacingSmall),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusNormal),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: AutoSizeText(
                    'Tema de la app',
                    style: GoogleFonts.poppins(
                      fontSize: AppTheme.fontSizeBodyLarge,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                  ),
                  subtitle: AutoSizeText(
                    'Selecciona cómo se adapta la interfaz',
                    style: GoogleFonts.inter(
                      fontSize: AppTheme.fontSizeBodyNormal,
                      color: AppTheme.grey1,
                    ),
                    maxLines: 1,
                  ),
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('Automático'),
                  subtitle: const Text('Usa el tema del dispositivo'),
                  value: ThemeMode.system,
                  groupValue: settings.themeMode,
                  onChanged: (m) =>
                      ref.read(settingsProvider.notifier).setThemeMode(m!),
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('Claro'),
                  value: ThemeMode.light,
                  groupValue: settings.themeMode,
                  onChanged: (m) =>
                      ref.read(settingsProvider.notifier).setThemeMode(m!),
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('Oscuro'),
                  value: ThemeMode.dark,
                  groupValue: settings.themeMode,
                  onChanged: (m) =>
                      ref.read(settingsProvider.notifier).setThemeMode(m!),
                ),
              ],
            ),
          ),

          Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: SwitchListTile(
              title: const Text('Reducir animaciones'),
              subtitle: const Text(
                'Limita transiciones y efectos para menor movimiento',
              ),
              value: settings.reduceMotion,
              onChanged: (value) =>
                  ref.read(settingsProvider.notifier).setReduceMotion(value),
            ),
          ),
        ],
      ),
    );
  }
}
