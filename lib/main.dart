import 'package:bombotickets/config/router/router.dart';
import 'package:bombotickets/config/theme/app_theme_new.dart';
import 'package:bombotickets/features/settings/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:bombotickets/config/environment.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Prevent runtime font fetching only on mobile (Android/iOS).
  // Desktop platforms keep runtime fetching enabled to avoid missing-assets errors.
  // if (defaultTargetPlatform == TargetPlatform.android ||
  //     defaultTargetPlatform == TargetPlatform.iOS) {
  //   GoogleFonts.config.allowRuntimeFetching = false;
  // } else {
  //   GoogleFonts.config.allowRuntimeFetching = true;
  // }
  await Environment.initEnvironment();
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final settings = ref.watch(settingsProvider);
    final reduceMotion = settings.reduceMotion;

    // Lock orientation to portrait for phones only (not tablets/desktop)
    final media = MediaQueryData.fromView(
      WidgetsBinding.instance.platformDispatcher.views.first,
    );
    final shortestSide = media.size.shortestSide;
    final isTablet = shortestSide >= 600;
    final isMobilePlatform =
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android;
    if (isMobilePlatform && !isTablet) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } else {
      SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    }

    return MaterialApp.router(
      routerConfig: appRouter,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
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
