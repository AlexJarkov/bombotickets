import 'package:bombotickets/features/shared/utils/responsive.dart';
import 'package:bombotickets/config/theme/theme.dart';
import 'package:bombotickets/features/auth/providers/auth_provider.dart';
import 'package:bombotickets/features/settings/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileBottomSheet extends ConsumerWidget {
  const ProfileBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final res = Responsive.of(context);
    final authState = ref.watch(authProvider);
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(res.wp(6)),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(res.wp(6))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle indicator
          Container(
            width: res.wp(12),
            height: res.hp(0.6),
            decoration: BoxDecoration(
              color: cs.onSurface.withOpacity(0.3),
              borderRadius: BorderRadius.circular(res.wp(3)),
            ),
          ),

          SizedBox(height: res.hp(3)),

          // Profile Header
          Row(
            children: [
              CircleAvatar(
                radius: res.wp(8),
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                child: Icon(
                  Icons.person,
                  size: res.dp(4),
                  color: AppTheme.primaryColor,
                ),
              ),
              SizedBox(width: res.wp(4)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      authState.user?.email ?? 'Usuario',
                      style: TextStyle(
                        fontSize: res.dp(2.2),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: res.hp(0.5)),
                    Text(
                      'Bombotickets Member',
                      style: TextStyle(
                        fontSize: res.dp(1.6),
                        color: cs.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: res.hp(4)),

          // Menu Options
          _buildProfileOption(
            context,
            res,
            icon: Icons.settings,
            title: 'Configuración',
            onTap: () {
              context.pop();
              // TODO: Navigate to settings
            },
          ),

          _buildProfileOption(
            context,
            res,
            icon: Icons.dark_mode,
            title: 'Modo Oscuro',
            onTap: () {
              final settingsNotifier = ref.read(settingsProvider.notifier);
              final currentMode = ref.read(settingsProvider).themeMode;
              final newMode = currentMode == ThemeMode.dark
                  ? ThemeMode.light
                  : ThemeMode.dark;
              settingsNotifier.setThemeMode(newMode);
            },
            trailing: Switch(
              value: ref.watch(settingsProvider).themeMode == ThemeMode.dark,
              onChanged: (value) {
                final settingsNotifier = ref.read(settingsProvider.notifier);
                settingsNotifier.setThemeMode(
                  value ? ThemeMode.dark : ThemeMode.light,
                );
              },
              activeColor: AppTheme.primaryColor,
            ),
          ),

          _buildProfileOption(
            context,
            res,
            icon: Icons.help,
            title: 'Ayuda',
            onTap: () {
              context.pop();
              // TODO: Navigate to help
            },
          ),

          _buildProfileOption(
            context,
            res,
            icon: Icons.logout,
            title: 'Cerrar Sesión',
            onTap: () {
              final authNotifier = ref.read(authProvider.notifier);
              authNotifier.logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
            isDestructive: true,
          ),

          SizedBox(height: res.hp(2)),
        ],
      ),
    );
  }

  Widget _buildProfileOption(
    BuildContext context,
    Responsive res, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
    bool isDestructive = false,
  }) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(res.wp(3)),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: res.hp(1.5),
          horizontal: res.wp(2),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? Colors.red : cs.onSurface.withOpacity(0.6),
              size: res.dp(2.4),
            ),
            SizedBox(width: res.wp(4)),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: res.dp(1.8),
                  color: isDestructive ? Colors.red : cs.onSurface,
                ),
              ),
            ),
            if (trailing != null) trailing,
            if (trailing == null)
              Icon(
                Icons.chevron_right,
                color: cs.onSurface.withOpacity(0.6),
                size: res.dp(1.8),
              ),
          ],
        ),
      ),
    );
  }
}

// Widget reutilizable para el contenido del perfil
class ProfileContent extends ConsumerWidget {
  final bool showInPageView;

  const ProfileContent({super.key, this.showInPageView = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final res = Responsive.of(context);
    final authState = ref.watch(authProvider);
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(res.wp(6)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showInPageView) ...[
              SizedBox(height: res.hp(2)),
              Text(
                'Perfil',
                style: TextStyle(
                  fontSize: res.dp(3),
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              SizedBox(height: res.hp(3)),
            ],

            // Profile Header Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(res.wp(6)),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(res.wp(4)),
                boxShadow: [
                  BoxShadow(
                    color: cs.shadow.withOpacity(0.1),
                    blurRadius: res.wp(2),
                    offset: Offset(0, res.hp(0.5)),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: res.wp(10),
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    child: Icon(
                      Icons.person,
                      size: res.dp(5),
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  SizedBox(width: res.wp(4)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authState.user?.email ?? 'Usuario',
                          style: TextStyle(
                            fontSize: res.dp(2.2),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: res.hp(0.5)),
                        Text(
                          'Bombotickets Member',
                          style: TextStyle(
                            fontSize: res.dp(1.6),
                            color: cs.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: res.hp(4)),

            // Menu Options Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(res.wp(4)),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(res.wp(4)),
                boxShadow: [
                  BoxShadow(
                    color: cs.shadow.withOpacity(0.1),
                    blurRadius: res.wp(2),
                    offset: Offset(0, res.hp(0.5)),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildProfileOption(
                    context,
                    res,
                    icon: Icons.settings,
                    title: 'Configuración',
                    onTap: () {
                      // TODO: Navigate to settings
                    },
                  ),

                  Divider(
                    height: res.hp(1),
                    color: cs.outline.withOpacity(0.2),
                  ),

                  _buildProfileOption(
                    context,
                    res,
                    icon: Icons.dark_mode,
                    title: 'Modo Oscuro',
                    onTap: () {
                      final settingsNotifier = ref.read(
                        settingsProvider.notifier,
                      );
                      final currentMode = ref.read(settingsProvider).themeMode;
                      final newMode = currentMode == ThemeMode.dark
                          ? ThemeMode.light
                          : ThemeMode.dark;
                      settingsNotifier.setThemeMode(newMode);
                    },
                    trailing: Switch(
                      value:
                          ref.watch(settingsProvider).themeMode ==
                          ThemeMode.dark,
                      onChanged: (value) {
                        final settingsNotifier = ref.read(
                          settingsProvider.notifier,
                        );
                        settingsNotifier.setThemeMode(
                          value ? ThemeMode.dark : ThemeMode.light,
                        );
                      },
                      activeColor: AppTheme.primaryColor,
                    ),
                  ),

                  Divider(
                    height: res.hp(1),
                    color: cs.outline.withOpacity(0.2),
                  ),

                  _buildProfileOption(
                    context,
                    res,
                    icon: Icons.help,
                    title: 'Ayuda',
                    onTap: () {
                      // TODO: Navigate to help
                    },
                  ),

                  Divider(
                    height: res.hp(1),
                    color: cs.outline.withOpacity(0.2),
                  ),

                  _buildProfileOption(
                    context,
                    res,
                    icon: Icons.logout,
                    title: 'Cerrar Sesión',
                    onTap: () {
                      final authNotifier = ref.read(authProvider.notifier);
                      authNotifier.logout();
                      if (context.mounted) {
                        context.go('/login');
                      }
                    },
                    isDestructive: true,
                  ),
                ],
              ),
            ),

            SizedBox(height: res.hp(4)),

            // Additional Info Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(res.wp(4)),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(res.wp(4)),
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppTheme.primaryColor,
                    size: res.dp(2.5),
                  ),
                  SizedBox(width: res.wp(3)),
                  Expanded(
                    child: Text(
                      'Bombotickets - Tu plataforma de confianza para compra y venta de tickets',
                      style: TextStyle(
                        fontSize: res.dp(1.5),
                        color: cs.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: res.hp(2)),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(
    BuildContext context,
    Responsive res, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
    bool isDestructive = false,
  }) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(res.wp(3)),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: res.hp(1.5),
          horizontal: res.wp(2),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? Colors.red : cs.onSurface.withOpacity(0.6),
              size: res.dp(2.4),
            ),
            SizedBox(width: res.wp(4)),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: res.dp(1.8),
                  color: isDestructive ? Colors.red : cs.onSurface,
                ),
              ),
            ),
            if (trailing != null) trailing,
            if (trailing == null)
              Icon(
                Icons.chevron_right,
                color: cs.onSurface.withOpacity(0.6),
                size: res.dp(1.8),
              ),
          ],
        ),
      ),
    );
  }
}
