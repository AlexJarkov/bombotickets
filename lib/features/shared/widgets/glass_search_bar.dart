import 'package:bombotickets/config/theme/app_theme_new.dart';
import 'package:bombotickets/features/shared/widgets/glass_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GlassSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final IconData prefixIcon;
  final double? iconSize;
  final EdgeInsets? padding;
  final Widget? suffix;
  final VoidCallback? onSuffixTap;

  const GlassSearchBar({
    super.key,
    required this.controller,
    this.hintText = 'Buscar...',
    this.onChanged,
    this.prefixIcon = Icons.search_rounded,
    this.iconSize,
    this.padding,
    this.suffix,
    this.onSuffixTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassCard(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      borderRadius: AppTheme.borderRadiusNormal,
      child: TextField(
        controller: controller,
        style: GoogleFonts.inter(
          fontSize: AppTheme.fontSizeBodyNormal,
          color: theme.colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.inter(
            fontSize: AppTheme.fontSizeBodyNormal,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          prefixIcon: Icon(
            prefixIcon,
            color: AppTheme.primaryColor,
            size: iconSize ?? 22,
          ),
          suffixIcon: suffix != null
              ? GestureDetector(
                  onTap: onSuffixTap,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: suffix,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppTheme.spacingNormal,
            vertical: AppTheme.spacingNormal,
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
