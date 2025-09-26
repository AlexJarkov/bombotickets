import 'package:bombotickets/config/theme/app_theme_new.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final Color? enabledColor;
  final Color? disabledColor;
  final double height;
  final double? width;
  final TextStyle? textStyle;
  final Widget? icon;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry? borderRadius;
  final Color? textColor;
  final Color? loadingColor;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.enabledColor,
    this.disabledColor,
    this.height = 48,
    this.width,
    this.textStyle,
    this.icon,
    this.padding,
    this.borderRadius,
    this.textColor = Colors.white,
    this.loadingColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = isEnabled
        ? (enabledColor ?? AppTheme.highlightBlue)
        : (disabledColor ?? AppTheme.greyBtnColor);

    final effectiveTextStyle =
        textStyle ??
        TextStyle(
          color: textColor,
          fontSize: AppTheme.fontSizeH2,
          fontWeight: FontWeight.w600,
        );

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius:
                borderRadius ??
                BorderRadius.circular(AppTheme.borderRadiusSmall),
          ),
        ),
        onPressed: isEnabled && !isLoading ? onPressed : null,
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: loadingColor,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[icon!, const SizedBox(width: 8)],
                  Text(text, style: effectiveTextStyle),
                ],
              ),
      ),
    );
  }
}
