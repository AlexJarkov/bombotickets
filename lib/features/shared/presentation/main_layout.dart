import 'package:bombotickets/features/shared/utils/responsive.dart';
import 'package:bombotickets/config/theme/theme.dart';
import 'package:bombotickets/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class MainLayout extends ConsumerStatefulWidget {
  final int initialIndex;

  const MainLayout({super.key, this.initialIndex = 0});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return; // No hacer nada si es la misma pestaña

    setState(() {
      _selectedIndex = index;
    });

    // Solo mostrar profile bottom sheet para el índice 3
    if (index == 3) {
      _showProfileBottomSheet();
      // Volver al índice anterior después del bottom sheet
      setState(() {
        _selectedIndex = 0; // Volver a Inicio
      });
    }
  }

  void _showProfileBottomSheet() {
    final res = Responsive.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(res.wp(6)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(res.wp(6)),
            topRight: Radius.circular(res.wp(6)),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: res.wp(12),
              height: res.hp(0.5),
              decoration: BoxDecoration(
                color: Colors.grey[300],
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
                          color: AppTheme.bodyFontColor,
                        ),
                      ),
                      Text(
                        'Bombotickets',
                        style: TextStyle(
                          fontSize: res.dp(1.6),
                          color: AppTheme.grey1,
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
                Navigator.pop(context);
                // TODO: Navigate to settings
              },
            ),

            _ProfileOption(
              icon: Icons.help_outline,
              title: 'Ayuda',
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to help
              },
            ),

            _ProfileOption(
              icon: Icons.logout,
              title: 'Cerrar sesión',
              isDestructive: true,
              onTap: () {
                Navigator.pop(context);
                ref.read(authProvider.notifier).logout();
                context.go('/login');
              },
            ),

            SizedBox(height: res.hp(2)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final res = Responsive.of(context);

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
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
          color: Colors.white,
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
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
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
        return const _ProductosContent();
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
              color: isDestructive ? Colors.red : AppTheme.primaryColor,
              size: res.dp(2.5),
            ),
            SizedBox(width: res.wp(4)),
            Text(
              title,
              style: TextStyle(
                fontSize: res.dp(1.8),
                color: isDestructive ? Colors.red : AppTheme.bodyFontColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              color: AppTheme.grey1,
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

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.7),
            Colors.white,
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
                ),
              ),

              SizedBox(height: res.hp(4)),

              // Welcome Card
              Container(
                padding: EdgeInsets.all(res.wp(6)),
                decoration: BoxDecoration(
                  color: Colors.white,
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
                        color: AppTheme.bodyFontColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: res.hp(2)),
                    Text(
                      'Gestiona tus tickets de manera fácil y eficiente',
                      style: TextStyle(
                        fontSize: res.dp(1.8),
                        color: AppTheme.grey1,
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

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.7),
            Colors.white,
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
                  color: Colors.white,
                ),
              ),
              SizedBox(height: res.hp(4)),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(res.wp(6)),
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                        color: AppTheme.grey1,
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

class _ProductosContent extends StatelessWidget {
  const _ProductosContent();

  @override
  Widget build(BuildContext context) {
    final res = Responsive.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.7),
            Colors.white,
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
                'Productos',
                style: TextStyle(
                  fontSize: res.dp(2.5),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: res.hp(4)),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(res.wp(6)),
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                      'Pantalla de Productos\n(En construcción)',
                      style: TextStyle(
                        fontSize: res.dp(2),
                        color: AppTheme.grey1,
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
