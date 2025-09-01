import 'package:flutter/material.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:bombotickets/config/theme/theme.dart';

class AppToast {
  static void showSuccess(
    BuildContext context, {
    required String title,
    required String description,
    Duration duration = const Duration(seconds: 3),
  }) {
    final theme = Theme.of(context);

    MotionToast(
      icon: Icons.check_circle_outline,
      primaryColor: const Color(0xFF10B981), // Verde elegante
      secondaryColor: const Color(0xFFECFDF5), // Fondo verde suave
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
      ),
      description: Text(
        description,
        style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.8)),
      ),
      toastDuration: duration,
      borderRadius: 16.0,
      enableAnimation: true,
      dismissable: true,
    ).show(context);
  }

  static void showError(
    BuildContext context, {
    required String title,
    required String description,
    Duration duration = const Duration(seconds: 4),
  }) {
    final theme = Theme.of(context);

    MotionToast(
      icon: Icons.error_outline,
      primaryColor: const Color(0xFFEF4444), // Rojo elegante
      secondaryColor: const Color(0xFFFEF2F2), // Fondo rojo suave
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
      ),
      description: Text(
        description,
        style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.8)),
      ),
      toastDuration: duration,
      borderRadius: 16.0,
      enableAnimation: true,
      dismissable: true,
    ).show(context);
  }

  static void showWarning(
    BuildContext context, {
    required String title,
    required String description,
    Duration duration = const Duration(seconds: 3),
  }) {
    final theme = Theme.of(context);

    MotionToast(
      icon: Icons.warning_amber_outlined,
      primaryColor: const Color(0xFFF59E0B), // Amarillo elegante
      secondaryColor: const Color(0xFFFFFBEB), // Fondo amarillo suave
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
      ),
      description: Text(
        description,
        style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.8)),
      ),
      toastDuration: duration,
      borderRadius: 16.0,
      enableAnimation: true,
      dismissable: true,
    ).show(context);
  }

  static void showInfo(
    BuildContext context, {
    required String title,
    required String description,
    Duration duration = const Duration(seconds: 3),
  }) {
    final theme = Theme.of(context);

    MotionToast(
      icon: Icons.info_outline,
      primaryColor: AppTheme.primaryColor, // Usa nuestro color principal
      secondaryColor: AppTheme.primaryColor.withOpacity(0.1),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
      ),
      description: Text(
        description,
        style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.8)),
      ),
      toastDuration: duration,
      borderRadius: 16.0,
      enableAnimation: true,
      dismissable: true,
    ).show(context);
  }

  static void showCustom(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color primaryColor,
    Duration duration = const Duration(seconds: 3),
  }) {
    final theme = Theme.of(context);

    MotionToast(
      icon: icon,
      primaryColor: primaryColor,
      secondaryColor: primaryColor.withOpacity(0.1),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
      ),
      description: Text(
        description,
        style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.8)),
      ),
      toastDuration: duration,
      borderRadius: 16.0,
      enableAnimation: true,
      dismissable: true,
    ).show(context);
  }
}
