import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bombotickets/features/shared/utils/responsive.dart';
import 'package:bombotickets/config/theme/app_theme_new.dart';
import 'package:bombotickets/features/auth/providers/auth_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends ConsumerWidget {
  static String name = 'profile';

  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final res = Responsive.of(context);
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(
          'Perfil',
          style: GoogleFonts.poppins(
            fontSize: AppTheme.fontSizeH2,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(AppTheme.spacingMedium),
            child: Column(
              children: [
                // Profile Info Simple
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(AppTheme.spacingMedium),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(
                      AppTheme.borderRadiusLarge,
                    ),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: res.wp(10),
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                        child: Icon(
                          Icons.person_rounded,
                          size: res.dp(5),
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      SizedBox(height: AppTheme.spacingMedium),
                      AutoSizeText(
                        authState.user?.username ?? 'Usuario',
                        style: GoogleFonts.poppins(
                          fontSize: AppTheme.fontSizeH3,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.bodyFontColor,
                        ),
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: AppTheme.spacingLarge),

                // Menu Simple
                _buildMenuItem(
                  context,
                  icon: Icons.settings_rounded,
                  title: 'Configuración',
                  onTap: () => context.push('/settings'),
                  res: res,
                ),

                SizedBox(height: AppTheme.spacingSmall),

                _buildMenuItem(
                  context,
                  icon: Icons.help_outline_rounded,
                  title: 'Ayuda',
                  onTap: () {},
                  res: res,
                ),

                SizedBox(height: AppTheme.spacingSmall),

                _buildMenuItem(
                  context,
                  icon: Icons.info_outline_rounded,
                  title: 'Acerca de',
                  onTap: () {},
                  res: res,
                ),

                SizedBox(height: AppTheme.spacingLarge),

                // Logout Button Simple
                _buildMenuItem(
                  context,
                  icon: Icons.logout_rounded,
                  title: 'Cerrar Sesión',
                  onTap: () async {
                    final shouldLogout = await _showLogoutDialog(context);
                    if (shouldLogout == true) {
                      ref.read(authProvider.notifier).logout();
                      if (context.mounted) {
                        context.go('/');
                      }
                    }
                  },
                  res: res,
                  isLogout: true,
                ),

                SizedBox(height: AppTheme.spacingLarge),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Responsive res,
    bool isLogout = false,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        border: Border.all(
          color: isLogout
              ? Colors.red.withOpacity(0.3)
              : Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
          child: Padding(
            padding: EdgeInsets.all(AppTheme.spacingNormal),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isLogout ? Colors.red : AppTheme.primaryColor,
                  size: res.dp(2.5),
                ),
                SizedBox(width: AppTheme.spacingMedium),
                Expanded(
                  child: AutoSizeText(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: AppTheme.fontSizeBodyLarge,
                      fontWeight: FontWeight.w600,
                      color: isLogout ? Colors.red : AppTheme.bodyFontColor,
                    ),
                    maxLines: 1,
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: isLogout
                      ? Colors.red.withOpacity(0.6)
                      : AppTheme.grey1,
                  size: res.dp(2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _showLogoutDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: AutoSizeText(
          'Cerrar Sesión',
          style: GoogleFonts.poppins(
            fontSize: AppTheme.fontSizeH3,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
        ),
        content: AutoSizeText(
          '¿Estás seguro de que quieres cerrar sesión?',
          style: GoogleFonts.inter(fontSize: AppTheme.fontSizeBodyNormal),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: AutoSizeText(
              'Cancelar',
              style: GoogleFonts.inter(
                fontSize: AppTheme.fontSizeBodyNormal,
                color: AppTheme.grey1,
              ),
              maxLines: 1,
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: AutoSizeText(
              'Cerrar sesión',
              style: GoogleFonts.inter(
                fontSize: AppTheme.fontSizeBodyNormal,
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
