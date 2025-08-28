// lib/widgets/side_menu.dart
import 'package:bombotickets/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

class SideMenu extends ConsumerWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  const SideMenu({super.key, required this.scaffoldKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              authState.status == AuthStatus.authenticated
                  ? 'Bienvenido'
                  : 'Invitado',
            ),
            accountEmail: null,
            currentAccountPicture: const CircleAvatar(
              child: Icon(Icons.person),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Inicio'),
            onTap: () {
              scaffoldKey.currentState?.closeDrawer();
              context.goNamed('home');
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Clientes'),
            onTap: () {
              scaffoldKey.currentState?.closeDrawer();
              context.goNamed('clientes');
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart),
            title: const Text('Productos'),
            onTap: () {
              scaffoldKey.currentState?.closeDrawer();
              context.goNamed('productos');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Cerrar sesión'),
            onTap: () {
              ref.read(authProvider.notifier).logout();
              context.goNamed('login');
            },
          ),
        ],
      ),
    );
  }
}
