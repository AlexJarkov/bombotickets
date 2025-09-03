import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter_animate/flutter_animate.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsets? margin;
  final EdgeInsets padding;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final double blurStrength;
  final List<BoxShadow>? shadows;
  final bool animated;
  final Duration animationDuration;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.margin,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 16,
    this.backgroundColor,
    this.borderColor,
    this.blurStrength = 10,
    this.shadows,
    this.animated = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Patrón profesional de sombras y bordes
    final modernShadows =
        shadows ??
        [
          if (isDark)
            // Dark mode: sombras muy sutiles
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            )
          else
            // Light mode: sombras más prominentes
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
              spreadRadius: 1,
            ),
        ];

    final modernBorder = Border.all(
      color: isDark
          ? Colors.white.withOpacity(0.08)
          : Colors.black.withOpacity(0.06),
      width: 1,
    );

    Widget card = Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: modernShadows,
        border: modernBorder,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(
            sigmaX: blurStrength,
            sigmaY: blurStrength,
          ),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color:
                  backgroundColor ??
                  (isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.white.withOpacity(0.8)),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: child,
          ),
        ),
      ),
    );

    // Micro-interacciones profesionales
    if (onTap != null) {
      card = GestureDetector(
        onTap: onTap,
        child: card
            .animate(target: 1)
            .scale(
              duration: 120.ms,
              curve: Curves.easeOut,
              begin: const Offset(1.0, 1.0),
              end: const Offset(0.98, 0.98),
            ),
      );
    }

    // Animaciones de entrada profesionales (más rápidas)
    if (animated) {
      return card
          .animate()
          .fadeIn(duration: 240.ms, curve: Curves.fastOutSlowIn)
          .slideY(
            duration: 240.ms,
            begin: 0.08, // Movimiento más sutil
            end: 0,
            curve: Curves.fastOutSlowIn,
          );
    }

    return card;
  }
}

// Variante específica para cards de información
class InfoGlassCard extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? accentColor;

  const InfoGlassCard({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassCard(
      onTap: onTap,
      child: Row(
        children: [
          if (leading != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (accentColor ?? theme.colorScheme.primary).withOpacity(
                  0.1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: leading!,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    );
  }
}

// Card con efecto de hover para escritorio
class HoverGlassCard extends StatefulWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsets? margin;
  final EdgeInsets padding;
  final double borderRadius;
  final VoidCallback? onTap;
  final double hoverScale;
  final Color? hoverBorderColor;

  const HoverGlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.margin,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 16,
    this.onTap,
    this.hoverScale = 1.02,
    this.hoverBorderColor,
  });

  @override
  State<HoverGlassCard> createState() => _HoverGlassCardState();
}

class _HoverGlassCardState extends State<HoverGlassCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()
          ..scale(_isHovered ? widget.hoverScale : 1.0),
        child: GlassCard(
          width: widget.width,
          height: widget.height,
          margin: widget.margin,
          padding: widget.padding,
          borderRadius: widget.borderRadius,
          onTap: widget.onTap,
          borderColor: _isHovered
              ? (widget.hoverBorderColor ??
                    theme.colorScheme.primary.withOpacity(0.5))
              : null,
          shadows: _isHovered
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                    offset: const Offset(0, 12),
                    blurRadius: 40,
                    spreadRadius: 0,
                  ),
                ]
              : null,
          child: widget.child,
        ),
      ),
    );
  }
}
