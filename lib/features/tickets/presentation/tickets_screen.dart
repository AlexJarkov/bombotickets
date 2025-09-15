import 'package:bombotickets/config/theme/app_theme_new.dart';
import 'package:bombotickets/features/shared/utils/responsive.dart';
import 'package:bombotickets/features/shared/widgets/animated_background.dart';
import 'package:bombotickets/features/shared/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'buy_tickets_screen.dart';
import 'my_sales_screen.dart';

class TicketsScreen extends ConsumerStatefulWidget {
  const TicketsScreen({super.key});

  @override
  ConsumerState<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends ConsumerState<TicketsScreen> {
  @override
  Widget build(BuildContext context) {
    final res = Responsive.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Fondo animado
          const AnimatedBackground(child: SizedBox.expand()),

          // Contenido principal
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.all(res.wp(4)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header con título
                  _buildHeader(res, theme),

                  SizedBox(height: AppTheme.spacingLarge),

                  // Opciones principales
                  _buildMainOptions(res, theme),

                  SizedBox(height: AppTheme.spacingLarge),

                  // Estadísticas rápidas
                  _buildQuickStats(res, theme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Responsive res, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
              'Tickets',
              style: GoogleFonts.poppins(
                fontSize: AppTheme.fontSizeH1,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            )
            .animate()
            .fadeIn(duration: 600.ms)
            .slideY(begin: -0.3, duration: 600.ms, curve: Curves.easeOutBack),

        SizedBox(height: AppTheme.spacingSmall),

        Text(
              'Compra y vende tickets de forma segura',
              style: GoogleFonts.inter(
                fontSize: AppTheme.fontSizeBodyLarge,
                color: AppTheme.grey1,
              ),
            )
            .animate(delay: 200.ms)
            .fadeIn(duration: 600.ms)
            .slideY(begin: -0.3, duration: 600.ms),
      ],
    );
  }

  Widget _buildMainOptions(Responsive res, ThemeData theme) {
    return Column(
      children: [
        // Comprar tickets
        _buildOptionCard(
          res: res,
          theme: theme,
          title: 'Comprar Tickets',
          subtitle: 'Encuentra eventos y compra tickets al mejor precio',
          icon: Icons.shopping_cart_outlined,
          iconColor: Colors.blue,
          onTap: () => _navigateToBuyTickets(),
          delay: 0,
        ),

        SizedBox(height: AppTheme.spacingMedium),

        // Vender tickets
        _buildOptionCard(
          res: res,
          theme: theme,
          title: 'Vender Tickets',
          subtitle: 'Publica tus tickets y genera ingresos extras',
          icon: Icons.sell_outlined,
          iconColor: Colors.green,
          onTap: () => _navigateToMySales(),
          delay: 200,
        ),
      ],
    );
  }

  Widget _buildOptionCard({
    required Responsive res,
    required ThemeData theme,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
    required int delay,
  }) {
    return GestureDetector(
          onTap: onTap,
          child: AppCard(
            padding: EdgeInsets.all(res.wp(4)),
            child: Row(
              children: [
                // Icono
                Container(
                  padding: EdgeInsets.all(res.wp(3)),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                      AppTheme.borderRadiusNormal,
                    ),
                  ),
                  child: Icon(icon, size: res.dp(3.5), color: iconColor),
                ),

                SizedBox(width: res.wp(4)),

                // Texto
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: AppTheme.fontSizeBodyLarge,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: AppTheme.spacingSmall),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          fontSize: AppTheme.fontSizeBodyNormal,
                          color: AppTheme.grey1,
                        ),
                      ),
                    ],
                  ),
                ),

                // Flecha
                Icon(
                  Icons.arrow_forward_ios,
                  size: res.dp(2),
                  color: AppTheme.grey1,
                ),
              ],
            ),
          ),
        )
        .animate(delay: Duration(milliseconds: delay))
        .fadeIn(duration: 600.ms)
        .slideX(begin: 0.3, duration: 600.ms, curve: Curves.easeOutBack);
  }

  Widget _buildQuickStats(Responsive res, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
              'Resumen Rápido',
              style: GoogleFonts.poppins(
                fontSize: AppTheme.fontSizeBodyLarge,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            )
            .animate(delay: 400.ms)
            .fadeIn(duration: 600.ms)
            .slideY(begin: 0.3, duration: 600.ms),

        SizedBox(height: AppTheme.spacingMedium),

        Row(
          children: [
            // Eventos disponibles
            Expanded(
              child: _buildStatCard(
                res: res,
                theme: theme,
                title: 'Eventos',
                value: '50+',
                subtitle: 'Disponibles',
                icon: Icons.event,
                color: AppTheme.primaryColor,
                delay: 500,
              ),
            ),

            SizedBox(width: res.wp(3)),

            // Mis ventas activas
            Expanded(
              child: _buildStatCard(
                res: res,
                theme: theme,
                title: 'Mis Ventas',
                value: '0',
                subtitle: 'Activas',
                icon: Icons.monetization_on,
                color: Colors.green,
                delay: 600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required Responsive res,
    required ThemeData theme,
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required int delay,
  }) {
    return AppCard(
          padding: EdgeInsets.all(res.wp(3)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, size: res.dp(2.5), color: color),
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: AppTheme.fontSizeBodyNormal,
                      color: AppTheme.grey1,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              SizedBox(height: AppTheme.spacingSmall),

              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: AppTheme.fontSizeH3,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),

              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: AppTheme.fontSizeBodyNormal,
                  color: AppTheme.grey1,
                ),
              ),
            ],
          ),
        )
        .animate(delay: Duration(milliseconds: delay))
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.5, duration: 600.ms, curve: Curves.easeOutBack);
  }

  void _navigateToBuyTickets() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BuyTicketsScreen()),
    );
  }

  void _navigateToMySales() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MySalesScreen()),
    );
  }
}
