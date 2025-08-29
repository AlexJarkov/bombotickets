import 'package:flutter/material.dart';
import 'package:bombotickets/features/shared/utils/responsive.dart';

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
      borderRadius: BorderRadius.circular(responsive.wp(2.5)),
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
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontSize: responsive.dp(2)),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontSize: responsive.dp(1.8)),
            filled: true,
            fillColor: Colors.grey[200],
            border: border,
            enabledBorder: border,
            focusedBorder: focusedBorder
                ? border.copyWith(
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  )
                : border,
            contentPadding: EdgeInsets.symmetric(
              vertical: responsive.hp(1.5),
              horizontal: responsive.wp(4),
            ),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: Colors.grey, size: responsive.dp(3))
                : null,
            suffixIcon: suffixIcon,
          ),
        ),
        if (errorMessage != null && isFormPosted)
          Padding(
            padding: EdgeInsets.only(
              top: responsive.hp(0.5),
              left: responsive.wp(3),
            ),
            child: Text(
              errorMessage!,
              style: TextStyle(
                color: Colors.red[700],
                fontSize: responsive.dp(1.5),
              ),
            ),
          ),
      ],
    );
  }
}
