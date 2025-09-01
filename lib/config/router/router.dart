import 'package:bombotickets/features/auth/login/presentation/login_screen.dart';
import 'package:bombotickets/features/auth/register/presentation/register_screen.dart';
import 'package:bombotickets/features/auth/splash/presentation/splash_screen.dart';
import 'package:bombotickets/features/shared/presentation/main_layout.dart';
import 'package:bombotickets/features/settings/presentation/settings_screen.dart';
import 'package:go_router/go_router.dart';

// GoRouter configuration
final appRouter = GoRouter(
  initialLocation: '/home',
  // redirect: (context, state) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   //await prefs.remove('token');
  //   final token = prefs.getString('token');
  //   log("TOKEN $token");
  //   final loggingIn = state.matchedLocation == '/login';
  //   final onAuthPage =
  //       state.matchedLocation == '/login' ||
  //       state.matchedLocation == '/register' ||
  //       state.matchedLocation == '/splash';

  //   // Si está logueado y quiere ir al login, redirige al home
  //   if (token != null && loggingIn) return '/home';

  //   // Si no está logueado y NO está en una página de auth, redirige al login
  //   if (token == null && !onAuthPage) return '/login';

  //   return null; // deja pasar
  // },
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(
      path: '/login',
      name: LoginScreen.name,
      builder: (context, state) => const LoginScreen(),
    ),

    GoRoute(
      path: '/register',
      name: RegisterScreen.name,
      builder: (context, state) => const RegisterScreen(),
    ),

    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const MainLayout(initialIndex: 0),
    ),

    GoRoute(
      path: '/clientes',
      name: 'clientes',
      builder: (context, state) => const MainLayout(initialIndex: 1),
    ),

    GoRoute(
      path: '/productos',
      name: 'productos',
      builder: (context, state) => const MainLayout(initialIndex: 2),
    ),

    GoRoute(
      path: '/settings',
      name: SettingsScreen.name,
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
