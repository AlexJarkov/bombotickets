import 'package:bombotickets/features/settings/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerWidget {
  static const String name = 'settings';

  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ListTile(
                  title: Text('Tema de la app'),
                  subtitle: Text('Selecciona cómo se adapta la interfaz'),
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
                  'Limita transiciones y efectos para menor movimiento'),
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
