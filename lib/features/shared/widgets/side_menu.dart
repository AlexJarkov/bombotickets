// lib/widgets/side_menu.dart
import 'package:bombotickets/features/auth/providers/auth_provider.dart';
import 'package:bombotickets/features/shared/utils/responsive.dart';
import 'package:bombotickets/config/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

class SideMenu extends ConsumerWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  const SideMenu({super.key, required this.scaffoldKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final res = Responsive.of(context);

    return Drawer(
      child: Column(
        children: [
          Container(
            height: res.hp(25),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.primaryColor.withOpacity(0.8),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(res.wp(4)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: res.wp(8),
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    child: Icon(
                      Icons.person,
                      size: res.dp(4),
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  SizedBox(height: res.hp(2)),
                  Text(
                    authState.status == AuthStatus.authenticated
                        ? 'Bienvenido'
                        : 'Invitado',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: res.dp(2.2),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Bombotickets',
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onPrimary
                          .withOpacity(0.85),
                      fontSize: res.dp(1.6),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: res.hp(2)),
              children: [
                _MenuTile(
                  icon: Icons.home,
                  title: 'Inicio',
                  onTap: () {
                    scaffoldKey.currentState?.closeDrawer();
                    context.goNamed('home');
                  },
                ),
                _MenuTile(
                  icon: Icons.person,
                  title: 'Clientes',
                  onTap: () {
                    scaffoldKey.currentState?.closeDrawer();
                    context.goNamed('clientes');
                  },
                ),
                _MenuTile(
                  icon: Icons.shopping_cart,
                  title: 'Productos',
                  onTap: () {
                    scaffoldKey.currentState?.closeDrawer();
                    context.goNamed('productos');
                  },
                ),

                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: res.wp(4),
                    vertical: res.hp(1),
                  ),
                  child: Divider(color: AppTheme.lineColor, thickness: 1),
                ),

                _MenuTile(
                  icon: Icons.logout,
                  title: 'Cerrar sesión',
                  isLogout: true,
                  onTap: () {
                    ref.read(authProvider.notifier).logout();
                    context.goNamed('login');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isLogout;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isLogout = false,
  });

  @override
  Widget build(BuildContext context) {
    final res = Responsive.of(context);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: res.wp(2),
        vertical: res.hp(0.5),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isLogout ? Colors.red : AppTheme.primaryColor,
          size: res.dp(2.5),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isLogout ? Colors.red : AppTheme.bodyFontColor,
            fontSize: res.dp(1.8),
            fontWeight: FontWeight.w500,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(res.wp(2)),
        ),
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(
          horizontal: res.wp(4),
          vertical: res.hp(0.5),
        ),
      ),
    );
  }
}
