import 'package:bombotickets/features/shared/utils/responsive.dart';
import 'package:bombotickets/config/theme/theme.dart';
import 'package:bombotickets/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bombotickets/features/tickets/presentation/tickets_screen.dart';
import 'package:bombotickets/features/settings/providers/settings_provider.dart';

class MainLayout extends ConsumerStatefulWidget {
  final int initialIndex;

  const MainLayout({super.key, this.initialIndex = 0});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout>
    with SingleTickerProviderStateMixin {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  Future<void> _onItemTapped(int index) async {
    // Si tocan Perfil, no cambiamos el índice; sólo mostramos el sheet
    if (index == 3) {
      await _showProfileBottomSheet();
      return;
    }

    if (_selectedIndex == index) return; // No hacer nada si es la misma pestaña

    if (mounted) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Future<void> _showProfileBottomSheet() async {
    final res = Responsive.of(context);
    final reduceMotion = ref.read(settingsProvider).reduceMotion;

    AnimationController? controller;
    if (reduceMotion) {
      // Minimal duration to avoid frame-time clamp and effectively disable slide
      controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1),
        reverseDuration: const Duration(milliseconds: 1),
      );
    }

    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      transitionAnimationController: controller,
      builder: (context) => SafeArea(
        child: Material(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(res.wp(6)),
            topRight: Radius.circular(res.wp(6)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: EdgeInsets.all(res.wp(6)),
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: res.wp(12),
              height: res.hp(0.5),
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor.withOpacity(0.6),
                borderRadius: BorderRadius.circular(res.wp(2)),
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
                        'Bienvenido',
                        style: TextStyle(
                          fontSize: res.dp(2.2),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Bombotickets',
                        style: TextStyle(
                          fontSize: res.dp(1.6),
                          color:
                              Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: res.hp(3)),

            // Profile Options
            _ProfileOption(
              icon: Icons.settings,
              title: 'Configuración',
              onTap: () {
                Navigator.of(context, rootNavigator: true).pop('settings');
              },
            ),

            _ProfileOption(
              icon: Icons.help_outline,
              title: 'Ayuda',
              onTap: () {
                Navigator.of(context, rootNavigator: true).pop('help');
              },
            ),

            _ProfileOption(
              icon: Icons.logout,
              title: 'Cerrar sesión',
              isDestructive: true,
              onTap: () {
                Navigator.of(context, rootNavigator: true).pop('logout');
              },
            ),

            SizedBox(height: res.hp(2)),
          ],
        ),
          ),
        ),
      ),
    );

    controller?.dispose();

    // Handle actions after sheet is fully dismissed
    if (!mounted) return;
    switch (result) {
      case 'settings':
        context.push('/settings');
        break;
      case 'logout':
        ref.read(authProvider.notifier).logout();
        context.go('/login');
        break;
      case 'help':
        // TODO: implement help route if needed
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final res = Responsive.of(context);
    final reduceMotion = ref.watch(settingsProvider).reduceMotion;
    
    return Scaffold(
      body: AnimatedSwitcher(
        duration: reduceMotion
            ? const Duration(milliseconds: 0)
            : const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          if (reduceMotion) return child;
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0.0, 0.03),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            ),
          );
        },
        child: Container(
          key: ValueKey<int>(_selectedIndex),
          child: _getBodyForIndex(_selectedIndex),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: res.wp(3),
              offset: Offset(0, -res.hp(0.3)),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (i) => _onItemTapped(i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).colorScheme.surface,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: AppTheme.grey1,
          selectedFontSize: res.dp(1.4),
          unselectedFontSize: res.dp(1.2),
          iconSize: res.dp(2.8),
          elevation: 0,
          enableFeedback: true,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              activeIcon: Icon(Icons.people),
              label: 'Clientes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined),
              activeIcon: Icon(Icons.shopping_cart),
              label: 'Productos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }

  Widget _getBodyForIndex(int index) {
    switch (index) {
      case 0:
        return const _HomeContent();
      case 1:
        return const _ClientesContent();
      case 2:
        return const TicketsScreen();
      case 3:
        return const _HomeContent(); // Profile se maneja con bottom sheet
      default:
        return const _HomeContent();
    }
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ProfileOption({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final res = Responsive.of(context);
    final cs = Theme.of(context).colorScheme;
    final textColor = isDestructive ? cs.error : Theme.of(context).textTheme.bodyMedium?.color;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(res.wp(2)),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: res.hp(1.5),
          horizontal: res.wp(2),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? cs.error : cs.primary,
              size: res.dp(2.5),
            ),
            SizedBox(width: res.wp(4)),
            Text(
              title,
              style: TextStyle(
                fontSize: res.dp(1.8),
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              color: (Theme.of(context).textTheme.bodyMedium?.color ?? cs.onSurface).withOpacity(0.6),
              size: res.dp(1.8),
            ),
          ],
        ),
      ),
    );
  }
}

// Contenido temporal para las pantallas
class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    final res = Responsive.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? const [
                  Color(0xFF0B1E3B), // deep navy
                  Color(0xFF091A32),
                  Colors.transparent,
                ]
              : [
                  AppTheme.primaryColor,
                  AppTheme.primaryColor.withOpacity(0.7),
                  Theme.of(context).scaffoldBackgroundColor,
                ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(res.wp(6)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: res.hp(2)),

              // Logo
              Center(
                child: Image.asset(
                  'assets/images/logo_masterpass.png',
                  width: res.wp(50),
                  fit: BoxFit.contain,
                  color: isDark ? Colors.white : Colors.black,
                  colorBlendMode: BlendMode.srcIn,
                ),
              ),

              SizedBox(height: res.hp(4)),

              // Welcome Card
              Container(
                padding: EdgeInsets.all(res.wp(6)),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(res.wp(5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: res.wp(2.5),
                      spreadRadius: res.wp(0.5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.home,
                      size: res.dp(6),
                      color: AppTheme.primaryColor,
                    ),
                    SizedBox(height: res.hp(2)),
                    Text(
                      'Bienvenido a Bombotickets',
                      style: TextStyle(
                        fontSize: res.dp(2.5),
                        fontWeight: FontWeight.bold,
                        // Use theme default color
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: res.hp(2)),
                    Text(
                      'Gestiona tus tickets de manera fácil y eficiente',
                      style: TextStyle(
                        fontSize: res.dp(1.8),
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClientesContent extends StatelessWidget {
  const _ClientesContent();

  @override
  Widget build(BuildContext context) {
    final res = Responsive.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? const [
                  Color(0xFF0B1E3B),
                  Color(0xFF091A32),
                  Colors.transparent,
                ]
              : [
                  AppTheme.primaryColor,
                  AppTheme.primaryColor.withOpacity(0.7),
                  Theme.of(context).scaffoldBackgroundColor,
                ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(res.wp(6)),
          child: Column(
            children: [
              Text(
                'Clientes',
                style: TextStyle(
                  fontSize: res.dp(2.5),
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              SizedBox(height: res.hp(4)),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(res.wp(6)),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(res.wp(5)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: res.wp(2.5),
                        spreadRadius: res.wp(0.5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'Pantalla de Clientes\n(En construcción)',
                      style: TextStyle(
                        fontSize: res.dp(2),
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Reemplazado por TicketsScreen
