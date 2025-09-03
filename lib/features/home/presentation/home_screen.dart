import 'package:bombotickets/features/shared/utils/responsive.dart';
import 'package:bombotickets/config/theme/app_theme_new.dart';
import 'package:bombotickets/features/shared/widgets/animated_background.dart';
import 'package:bombotickets/features/shared/widgets/glass_card.dart';
import 'package:bombotickets/features/tickets/presentation/tickets_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';

class HomeScreen extends ConsumerStatefulWidget {
  static String name = 'home';

  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.all(AppTheme.spacingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: AppTheme.spacingLarge),

                  // Logo con animación
                  Center(
                    child: Image.asset(
                      'assets/images/logo_masterpass.png',
                      width: res.wp(50),
                      fit: BoxFit.contain,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                      colorBlendMode: BlendMode.srcIn,
                    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.3),
                  ),

                  SizedBox(height: AppTheme.spacingLarge),

                  // (Search removed from Home per design)
                  SizedBox(height: AppTheme.spacingLarge),

                  // Accesos Directos / Acciones Rápidas
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingSmall,
                        ),
                        child:
                            AutoSizeText(
                                  'Accesos Rápidos',
                                  style: GoogleFonts.poppins(
                                    fontSize: AppTheme.fontSizeH3,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                                  maxLines: 1,
                                )
                                .animate()
                                .slideX(duration: 600.ms, begin: -0.3, end: 0)
                                .fadeIn(),
                      ),
                      SizedBox(height: AppTheme.spacingNormal),

                      // Grid de acciones principales 2x2
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: AppTheme.spacingNormal,
                        mainAxisSpacing: AppTheme.spacingNormal,
                        childAspectRatio: 1.0,
                        children: [
                          _QuickAccessCard(
                                icon: Icons.qr_code_scanner_rounded,
                                title: 'Validar Ticket',
                                subtitle: 'Escanear QR',
                                color: AppTheme.primaryColor,
                                onTap: () {
                                  // Ir al tab de Escanear (índice 2)
                                  context.go('/productos');
                                },
                              )
                              .animate()
                              .slideY(
                                duration: 500.ms,
                                delay: 200.ms,
                                begin: 0.3,
                                end: 0,
                              )
                              .fadeIn(),

                          _QuickAccessCard(
                                icon: Icons.shopping_cart_rounded,
                                title: 'Comprar',
                                subtitle: 'Eventos disponibles',
                                color: AppTheme.successColor,
                                onTap: () {
                                  // Ir al tab de Tickets (índice 1) -> Comprar por defecto
                                  ref.read(ticketsTabProvider.notifier).state =
                                      0;
                                  context.go('/clientes');
                                },
                              )
                              .animate()
                              .slideY(
                                duration: 500.ms,
                                delay: 300.ms,
                                begin: 0.3,
                                end: 0,
                              )
                              .fadeIn(),

                          _QuickAccessCard(
                                icon: Icons.sell_rounded,
                                title: 'Vender',
                                subtitle: 'Reventa de tickets',
                                color: AppTheme.warningColor,
                                onTap: () {
                                  // Pre-seleccionar tab Vender (1) y navegar a Tickets (índice 1)
                                  ref.read(ticketsTabProvider.notifier).state =
                                      1;
                                  context.go('/clientes');
                                },
                              )
                              .animate()
                              .slideY(
                                duration: 500.ms,
                                delay: 400.ms,
                                begin: 0.3,
                                end: 0,
                              )
                              .fadeIn(),

                          _QuickAccessCard(
                                icon: Icons.person_rounded,
                                title: 'Perfil',
                                subtitle: 'Mi cuenta',
                                color: AppTheme.secondaryColor,
                                onTap: () {
                                  // Ir al tab de Perfil (índice 3)
                                  context.go('/perfil');
                                },
                              )
                              .animate()
                              .slideY(
                                duration: 500.ms,
                                delay: 500.ms,
                                begin: 0.3,
                                end: 0,
                              )
                              .fadeIn(),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickAccessCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return HoverGlassCard(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? color.withValues(alpha: 0.2)
                  : color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 32,
              color: isDark ? color.withValues(alpha: 0.9) : color,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
