import 'package:flutter/material.dart';
import 'package:bombotickets/features/shared/utils/responsive.dart';
import 'package:bombotickets/config/theme/app_theme_new.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomInputField extends StatelessWidget {
  final String label;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final String? errorMessage;
  final bool isFormPosted;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool focusedBorder;
  final TextEditingController? controller;

  const CustomInputField({
    super.key,
    required this.label,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
    this.errorMessage,
    this.isFormPosted = false,
    this.prefixIcon,
    this.suffixIcon,
    this.focusedBorder = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
      borderSide: const BorderSide(color: Colors.transparent),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          obscureText: obscureText,
          keyboardType: keyboardType,
          onChanged: onChanged,
          controller: controller,
          style: GoogleFonts.inter(
            fontSize: AppTheme.fontSizeBodyNormal,
            color: AppTheme.bodyFontColor,
          ),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: GoogleFonts.inter(
              fontSize: AppTheme.fontSizeBodyNormal,
              color: AppTheme.grey1,
            ),
            filled: true,
            fillColor: AppTheme.greyInputBg,
            border: border,
            enabledBorder: border,
            focusedBorder: focusedBorder
                ? border.copyWith(
                    borderSide: const BorderSide(
                      color: AppTheme.primaryColor,
                      width: 2,
                    ),
                  )
                : border,
            contentPadding: EdgeInsets.symmetric(
              vertical: AppTheme.spacingNormal,
              horizontal: AppTheme.spacingNormal,
            ),
            prefixIcon: prefixIcon != null
                ? Icon(
                    prefixIcon,
                    color: AppTheme.grey1,
                    size: responsive.dp(3),
                  )
                : null,
            suffixIcon: suffixIcon,
          ),
        ),
        if (errorMessage != null && isFormPosted)
          Padding(
            padding: EdgeInsets.only(
              top: AppTheme.spacingSmall / 2,
              left: AppTheme.spacingSmall,
            ),
            child: Text(
              errorMessage!,
              style: GoogleFonts.inter(
                color: Colors.red[700],
                fontSize: AppTheme.fontSizeBodyNormal,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}
