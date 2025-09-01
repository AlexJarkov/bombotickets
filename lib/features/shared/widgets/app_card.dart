import 'package:bombotickets/features/shared/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double? elevation;
  final VoidCallback? onTap;
  final Duration? animationDelay;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.elevation,
    this.onTap,
    this.animationDelay,
  });

  @override
  Widget build(BuildContext context) {
    final res = Responsive.of(context);
    final theme = Theme.of(context);

    Widget cardContent = Container(
      padding: padding ?? EdgeInsets.all(res.wp(6)),
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(res.wp(4)),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.08),
            blurRadius: res.wp(3),
            spreadRadius: res.wp(0.5),
            offset: Offset(0, res.wp(1)),
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: child,
    );

    if (onTap != null) {
      cardContent = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(res.wp(4)),
          child: cardContent,
        ),
      );
    }

    return cardContent
        .animate(delay: animationDelay ?? 0.ms)
        .fadeIn(duration: 600.ms, curve: Curves.easeOutCubic)
        .slideY(begin: 0.1, duration: 600.ms, curve: Curves.easeOutCubic)
        .shimmer(
          delay: Duration(
            milliseconds: (animationDelay?.inMilliseconds ?? 0) + 800,
          ),
          duration: 1200.ms,
          color: theme.colorScheme.primary.withOpacity(0.1),
        );
  }
}

// Widget específico para Quick Actions con patrón unificado
class QuickActionAppCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final Duration? animationDelay;

  const QuickActionAppCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.animationDelay,
  });

  @override
  Widget build(BuildContext context) {
    final res = Responsive.of(context);
    final theme = Theme.of(context);

    return AppCard(
      onTap: onTap,
      animationDelay: animationDelay,
      padding: EdgeInsets.all(res.wp(4)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(res.wp(3)),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(res.wp(3)),
            ),
            child: Icon(icon, size: res.dp(3.5), color: color),
          ),
          SizedBox(height: res.hp(1.5)),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: res.dp(1.8),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: res.hp(0.5)),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: res.dp(1.3),
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
