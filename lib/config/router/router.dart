import 'package:bombotickets/features/auth/login/presentation/login_screen.dart';
import 'package:bombotickets/features/auth/register/presentation/register_screen.dart';
import 'package:bombotickets/features/auth/splash/presentation/splash_screen.dart';
import 'package:bombotickets/features/auth/otp_verification/presentation/otp_verification_screen.dart';
import 'package:bombotickets/config/layout/main_layout.dart';
import 'package:bombotickets/features/scanner/presentation/qr_scanner_screen.dart';
import 'package:go_router/go_router.dart';

// GoRouter configuration
final appRouter = GoRouter(
  initialLocation: '/splash',
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
      path: '/otp-verification',
      name: OtpVerificationScreen.name,
      builder: (context, state) {
        final email = state.uri.queryParameters['email'] ?? '';
        return OtpVerificationScreen(email: email);
      },
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
      path: '/perfil',
      name: 'perfil',
      builder: (context, state) => const MainLayout(initialIndex: 3),
    ),

    GoRoute(
      path: '/scanner',
      name: 'scanner',
      builder: (context, state) => const QrScannerScreen(),
    ),
  ],
);
