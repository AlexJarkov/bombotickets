import 'dart:developer';
import 'dart:ui';
import 'package:bombotickets/features/auth/login/presentation/login_screen.dart';
import 'package:bombotickets/features/auth/splash/presentation/splash_screen.dart';
import 'package:bombotickets/features/home/presentation/home_screen.dart';
import 'package:bombotickets/features/shared/animations/slide_fade_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

// GoRouter configuration
final appRouter = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) async {
    final prefs = await SharedPreferences.getInstance();
    //await prefs.remove('token');
    final token = prefs.getString('token');
    log("TOKEN $token");
    final loggingIn = state.matchedLocation == '/login';

    // Si está logueado y quiere ir al login, redirige al home
    if (token != null && loggingIn) return '/home';

    // Si no está logueado y quiere ir al home, redirige al login
    if (token == null && loggingIn) return '/login';

    return null; // deja pasar
  },
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(
      path: '/login',
      name: LoginScreen.name,
      builder: (context, state) => const LoginScreen(),
    ),

    GoRoute(
      path: '/home',
      name: HomeScreen.name,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: HomeScreen(),
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideAndFadeTransition(
            animation: animation,
            beginOffset: const Offset(0, 0.1),
            child: child,
          );
        },
      ),
    ),
  ],
);
