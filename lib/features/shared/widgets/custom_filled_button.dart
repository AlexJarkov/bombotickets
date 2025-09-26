import 'package:flutter/material.dart';
import 'package:bombotickets/features/shared/utils/responsive.dart';
import 'package:bombotickets/config/theme/app_theme_new.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomFilledButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final Color? buttonColor;
  final double height;

  const CustomFilledButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.buttonColor,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
    final backgroundColor = buttonColor ?? AppTheme.primaryColor;

    return SizedBox(
      width: double.infinity,
      height: responsive.hp(7),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          disabledBackgroundColor: backgroundColor.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
          ),
          elevation: 0,
        ),
        onPressed: isEnabled && !isLoading ? onPressed : null,
        child: isLoading
            ? SizedBox(
                width: responsive.wp(6),
                height: responsive.wp(6),
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                text,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: AppTheme.fontSizeBodyMedium,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
