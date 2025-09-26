import 'package:bombotickets/config/theme/app_theme_new.dart';
import 'package:bombotickets/features/shared/utils/responsive.dart';
import 'package:bombotickets/features/shared/widgets/animated_background.dart';
import 'package:bombotickets/features/auth/splash/providers/splash_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _navigated = false;
  Alignment _logoAlignment = Alignment.center;

  @override
  void initState() {
    super.initState();

    // Configurar animaciones sutiles
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    // Overshoot sutil al entrar
    _scaleAnimation = TweenSequence<double>(
      [
        TweenSequenceItem(tween: Tween(begin: 0.94, end: 1.02), weight: 60),
        TweenSequenceItem(tween: Tween(begin: 1.02, end: 1.0), weight: 40),
      ],
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    // Iniciar animación
    _controller.forward();

    // Iniciar verificación después de que el widget esté completamente construido
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initSplash();
    });
  }

  void _initSplash() async {
    // Usar el splash provider para verificar autenticación
    await ref.read(splashProvider.notifier).checkAuthentication();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final res = Responsive.of(context);
    final splashState = ref.watch(splashProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final logoColor = isDark ? Colors.white : Colors.black;

    // Escuchar cambios en el splash provider para navegación
    ref.listen(splashProvider, (previous, next) async {
      if (_navigated) return;

      if (next.status == SplashStatus.navigateToHome) {
        // Mostrar el spinner un breve instante antes de ir al home
        _navigated = true;
        await Future.delayed(const Duration(milliseconds: 650));
        if (!context.mounted) return;
        context.go('/home');
      } else if (next.status == SplashStatus.navigateToLogin) {
        // Elevar el logo suavemente y luego navegar para que parezca que el logo sube a su posición final
        _navigated = true;
        setState(() {
          _logoAlignment = const Alignment(0, -0.82);
        });
        await Future.delayed(const Duration(milliseconds: 420));
        if (!context.mounted) return;
        context.pushReplacement('/login');
      }
    });

    return AnimatedBackground(
      style: BackgroundStyle.surface,
      animated: true,
      intensity: 0.3, // Más sutil en splash
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo principal con Hero y AnimatedAlign para simular ascenso previo al login
                      AnimatedAlign(
                        alignment: _logoAlignment,
                        duration: const Duration(milliseconds: 480),
                        curve: Curves.easeOutCubic,
                        child: Hero(
                          tag: 'app_logo',
                          flightShuttleBuilder:
                              (
                                flightContext,
                                animation,
                                flightDirection,
                                fromHeroContext,
                                toHeroContext,
                              ) {
                                final curved = CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeOutCubic,
                                );
                                // Scale + slight fade for a premium feel
                                return FadeTransition(
                                  opacity: Tween(
                                    begin: 0.95,
                                    end: 1.0,
                                  ).animate(curved),
                                  child: ScaleTransition(
                                    scale: Tween(begin: 0.98, end: 1.04)
                                        .chain(
                                          CurveTween(
                                            curve: Curves.easeOutCubic,
                                          ),
                                        )
                                        .animate(curved),
                                    child: toHeroContext.widget,
                                  ),
                                );
                              },
                          child: ColorFiltered(
                            colorFilter: ColorFilter.mode(
                              logoColor,
                              BlendMode.srcIn,
                            ),
                            child: Image.asset(
                              'assets/images/logo_masterpass.png',
                              width: res.wp(48),
                              height: res.wp(48),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: res.hp(6)),

                      // Mostrar spinner solo cuando va al home (usuario autenticado)
                      if (splashState.status == SplashStatus.navigateToHome)
                        SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.primaryColor.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
