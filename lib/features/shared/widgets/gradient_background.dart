import 'package:flutter/material.dart';
import 'package:bombotickets/config/theme/app_theme_new.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final bool hasAppBar;

  const GradientBackground({
    super.key,
    required this.child,
    this.hasAppBar = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? const [Color(0xFF0B1E3B), Color(0xFF091A32), Colors.transparent]
              : [
                  AppTheme.primaryColor,
                  AppTheme.primaryColor.withOpacity(0.7),
                  Theme.of(context).scaffoldBackgroundColor,
                ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: hasAppBar ? child : SafeArea(child: child),
    );
  }
}
