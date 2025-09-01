import 'dart:developer';
import 'dart:io';
import 'package:bombotickets/config/router/router.dart';
import 'package:bombotickets/config/theme/theme.dart';
import 'package:bombotickets/features/settings/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bombotickets/config/environment.dart';

void main() async {
  log('Current directory: \\${Directory.current.path}');
  WidgetsFlutterBinding.ensureInitialized();
  await Environment.initEnvironment();
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final settings = ref.watch(settingsProvider);
    final reduceMotion = settings.reduceMotion;

    return MaterialApp.router(
      routerConfig: appRouter,
      theme: AppTheme(isDarkMode: false).getTheme(reduceMotion: reduceMotion),
      darkTheme: AppTheme(isDarkMode: true).getTheme(reduceMotion: reduceMotion),
      themeMode: settings.themeMode,
      builder: (context, child) {
        final data = MediaQuery.of(context);
        return MediaQuery(
          data: data.copyWith(disableAnimations: reduceMotion),
          child: child ?? const SizedBox.shrink(),
        );
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
