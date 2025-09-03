import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui' as ui;
import '../../../config/theme/app_theme_new.dart';

enum GradientButtonStyle {
  primary,
  secondary,
  energy,
  success,
  warning,
  danger,
}

class GradientButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final GradientButtonStyle style;
  final Widget? icon;
  final double? width;
  final double height;
  final double borderRadius;
  final bool loading;
  final bool disabled;
  final TextStyle? textStyle;
  final EdgeInsets padding;

  const GradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.style = GradientButtonStyle.primary,
    this.icon,
    this.width,
    this.height = 52,
    this.borderRadius = 12,
    this.loading = false,
    this.disabled = false,
    this.textStyle,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  Gradient get _gradient {
    switch (widget.style) {
      case GradientButtonStyle.primary:
        return AppTheme.primaryGradient;
      case GradientButtonStyle.secondary:
        return const LinearGradient(
          colors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case GradientButtonStyle.energy:
        return AppTheme.energyGradient;
      case GradientButtonStyle.success:
        return AppTheme.successGradient;
      case GradientButtonStyle.warning:
        return const LinearGradient(
          colors: [Color(0xFFF59E0B), Color(0xFFEAB308)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case GradientButtonStyle.danger:
        return const LinearGradient(
          colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  bool get _isInteractable =>
      !widget.disabled && !widget.loading && widget.onPressed != null;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
          onTapDown: _isInteractable
              ? (_) => setState(() => _isPressed = true)
              : null,
          onTapUp: _isInteractable
              ? (_) => setState(() => _isPressed = false)
              : null,
          onTapCancel: _isInteractable
              ? () => setState(() => _isPressed = false)
              : null,
          onTap: _isInteractable ? widget.onPressed : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: widget.width,
            height: widget.height,
            padding: widget.padding,
            decoration: BoxDecoration(
              gradient: widget.disabled
                  ? LinearGradient(
                      colors: [Colors.grey.shade300, Colors.grey.shade400],
                    )
                  : _gradient,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: _isInteractable && !_isPressed
                  ? [
                      BoxShadow(
                        color: _gradient.colors.first.withOpacity(0.3),
                        offset: const Offset(0, 8),
                        blurRadius: 20,
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: _gradient.colors.last.withOpacity(0.2),
                        offset: const Offset(0, 4),
                        blurRadius: 12,
                        spreadRadius: 0,
                      ),
                    ]
                  : [],
            ),
            transform: Matrix4.identity()..scale(_isPressed ? 0.96 : 1.0),
            child: Material(
              color: Colors.transparent,
              child: Container(
                alignment: Alignment.center,
                child: widget.loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.icon != null) ...[
                            widget.icon!,
                            const SizedBox(width: 8),
                          ],
                          Text(
                            widget.text,
                            style:
                                widget.textStyle ??
                                Theme.of(
                                  context,
                                ).textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        )
        .animate(target: _isPressed ? 1 : 0)
        .scale(
          duration: 150.ms,
          curve: Curves.easeInOut,
          begin: const Offset(1, 1),
          end: const Offset(0.96, 0.96),
        )
        .shimmer(
          duration: widget.loading ? 1500.ms : 0.ms,
          colors: [
            Colors.white.withOpacity(0.3),
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.3),
          ],
        );
  }
}

// Botón de estilo glass/glassmorphism
class GlassButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Widget? icon;
  final double? width;
  final double height;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;
  final bool loading;

  const GlassButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.width,
    this.height = 52,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = 12,
    this.loading = false,
  });

  @override
  State<GlassButton> createState() => _GlassButtonState();
}

class _GlassButtonState extends State<GlassButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: widget.onPressed != null
          ? (_) => setState(() => _isPressed = true)
          : null,
      onTapUp: widget.onPressed != null
          ? (_) => setState(() => _isPressed = false)
          : null,
      onTapCancel: widget.onPressed != null
          ? () => setState(() => _isPressed = false)
          : null,
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: widget.width,
        height: widget.height,
        transform: Matrix4.identity()..scale(_isPressed ? 0.96 : 1.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color:
                    widget.backgroundColor ??
                    (isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.white.withOpacity(0.2)),
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: Border.all(
                  color:
                      widget.borderColor ??
                      (isDark
                          ? Colors.white.withOpacity(0.2)
                          : Colors.white.withOpacity(0.3)),
                  width: 1,
                ),
              ),
              alignment: Alignment.center,
              child: widget.loading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.icon != null) ...[
                          widget.icon!,
                          const SizedBox(width: 8),
                        ],
                        Text(
                          widget.text,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
