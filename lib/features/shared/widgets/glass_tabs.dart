import 'package:bombotickets/config/theme/app_theme_new.dart';
import 'package:bombotickets/features/shared/widgets/glass_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GlassTabs extends StatelessWidget {
  final TabController controller;
  final List<Widget> tabs;

  const GlassTabs({super.key, required this.controller, required this.tabs});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      child: GlassCard(
        padding: const EdgeInsets.all(2),
        borderRadius: 8, // Más rectangular
        child: TabBar(
          controller: controller,
          dividerColor: Colors.transparent,
          isScrollable: false,
          labelPadding:
              EdgeInsets.zero, // Sin padding para ocupar todo el ancho
          indicator: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(6), // Menos redondeado
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          labelColor: Colors.white,
          unselectedLabelColor: theme.colorScheme.onSurface.withValues(
            alpha: 0.7,
          ),
          labelStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          tabs: tabs,
        ),
      ),
    );
  }
}
