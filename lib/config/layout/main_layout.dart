import 'package:bombotickets/features/shared/utils/responsive.dart';
import 'package:bombotickets/config/theme/app_theme_new.dart';
import 'package:bombotickets/features/home/presentation/home_screen.dart';
import 'package:bombotickets/features/tickets/presentation/tickets_screen.dart';
import 'package:bombotickets/features/scanner/presentation/qr_scanner_screen.dart';
import 'package:bombotickets/features/profile/presentation/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainLayout extends ConsumerStatefulWidget {
  final int initialIndex;

  const MainLayout({super.key, this.initialIndex = 0});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout>
    with SingleTickerProviderStateMixin {
  late int _selectedIndex;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _onItemTapped(int index) async {
    // Si tocan Escanear (índice 2)
    if (index == 2) {
      // Vibración háptica ligera para el escáner
      HapticFeedback.lightImpact();

      // Si ya estamos en la página del escáner, no hacer nada
      if (_selectedIndex == 2) return;

      // Si no estamos en la página del escáner, navegar a ella
      setState(() {
        _selectedIndex = index;
      });

      await _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
      return;
    }

    // Si tocan Perfil (índice 3)
    if (index == 3) {
      // Vibración háptica ligera para el perfil
      HapticFeedback.lightImpact();

      // Si ya estamos en la página del perfil, no hacer nada
      if (_selectedIndex == 3) return;

      // Si no estamos en la página del perfil, navegar a ella
      setState(() {
        _selectedIndex = index;
      });

      await _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
      return;
    }

    if (_selectedIndex == index) return; // No hacer nada si es la misma pestaña

    // Vibración háptica para navegación normal
    HapticFeedback.selectionClick();

    // Animar hacia la página seleccionada
    await _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  void _onPageChanged(int index) {
    if (mounted) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final res = Responsive.of(context);
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final bool isWide = width >= 1000;

    if (isWide) {
      // Wide layout: NavigationRail on the left, content centered with max width
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                selectedIndex: _selectedIndex,
                onDestinationSelected: (index) => _onItemTapped(index),
                labelType: NavigationRailLabelType.all,
                minWidth: 72,
                groupAlignment: -0.9,
                leading: const SizedBox(height: 8),
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home),
                    label: Text('Inicio'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.confirmation_number_outlined),
                    selectedIcon: Icon(Icons.confirmation_number),
                    label: Text('Tickets'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.qr_code_scanner_outlined),
                    selectedIcon: Icon(Icons.qr_code_scanner),
                    label: Text('Escanear'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.person_outline),
                    selectedIcon: Icon(Icons.person),
                    label: Text('Perfil'),
                  ),
                ],
              ),
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    physics: const BouncingScrollPhysics(),
                    children: const [
                      HomeScreen(),
                      TicketsScreen(),
                      QRScannerContent(showAppBar: false),
                      ProfileScreen(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Default layout (phones/tablets): BottomNavigationBar
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const BouncingScrollPhysics(),
        children: const [
          HomeScreen(),
          TicketsScreen(),
          QRScannerContent(showAppBar: false),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          margin: EdgeInsets.zero,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppTheme.borderRadiusLarge),
              topRight: Radius.circular(AppTheme.borderRadiusLarge),
            ),
            border: Border(
              top: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.08),
                width: 1,
              ),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppTheme.borderRadiusLarge),
              topRight: Radius.circular(AppTheme.borderRadiusLarge),
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              backgroundColor: Colors.transparent,
              selectedItemColor: AppTheme.primaryColor,
              unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.6),
              selectedFontSize: res.dp(1.3),
              unselectedFontSize: res.dp(1.1),
              iconSize: res.dp(2.4),
              elevation: 0,
              items: [
                _buildBottomNavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'Inicio',
                  res: res,
                ),
                _buildBottomNavItem(
                  icon: Icons.confirmation_number_outlined,
                  activeIcon: Icons.confirmation_number,
                  label: 'Tickets',
                  res: res,
                ),
                _buildBottomNavItem(
                  icon: Icons.qr_code_scanner_outlined,
                  activeIcon: Icons.qr_code_scanner,
                  label: 'Escanear',
                  res: res,
                  isSpecial: true,
                ),
                _buildBottomNavItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'Perfil',
                  res: res,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildBottomNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required Responsive res,
    bool isSpecial = false,
  }) {
    return BottomNavigationBarItem(
      icon: Container(
        padding: EdgeInsets.symmetric(
          vertical: res.hp(0.6),
          horizontal: res.wp(2.5),
        ),
        decoration: isSpecial
            ? BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(
                  AppTheme.borderRadiusNormal,
                ),
              )
            : null,
        child: Icon(icon, size: isSpecial ? res.dp(2.8) : res.dp(2.4)),
      ),
      activeIcon: Container(
        padding: EdgeInsets.symmetric(
          vertical: res.hp(0.6),
          horizontal: res.wp(2.5),
        ),
        decoration: BoxDecoration(
          color: isSpecial
              ? AppTheme.primaryColor
              : AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusNormal),
        ),
        child: Icon(
          activeIcon,
          size: isSpecial ? res.dp(2.8) : res.dp(2.4),
          color: isSpecial ? Colors.white : AppTheme.primaryColor,
        ),
      ),
      label: label,
    );
  }
}
