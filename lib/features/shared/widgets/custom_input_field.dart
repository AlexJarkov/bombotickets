import 'package:flutter/material.dart';

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
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
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
          style: Theme.of(context).textTheme.bodyMedium,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: Theme.of(context).textTheme.bodyMedium,
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
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 16,
            ),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: Colors.grey)
                : null,
            suffixIcon: suffixIcon,
          ),
        ),
        if (errorMessage != null && isFormPosted)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 12),
            child: Text(
              errorMessage!,
              style: TextStyle(color: Colors.red[700], fontSize: 12),
            ),
          ),
      ],
    );
  }
}
