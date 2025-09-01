import 'package:bombotickets/features/shared/utils/responsive.dart';
import 'package:bombotickets/config/theme/theme.dart';
import 'package:bombotickets/features/shared/widgets/home_content.dart';
import 'package:bombotickets/features/shared/widgets/profile_bottom_sheet.dart';
import 'package:bombotickets/features/tickets/presentation/tickets_screen.dart';
import 'package:bombotickets/features/scanner/presentation/qr_scanner_screen.dart';
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
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const BouncingScrollPhysics(),
        children: [
          HomeContent(onItemTapped: _onItemTapped),
          const TicketsScreen(),
          // Escáner QR integrado en el PageView
          const QRScannerContent(
            showAppBar:
                false, // No mostrar AppBar porque ya está en el MainLayout
          ),
          const ProfileContent(
            showInPageView: true,
          ), // Perfil integrado en el PageView
        ],
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.all(res.wp(4)),
        decoration: BoxDecoration(
          color: isDark ? theme.colorScheme.surface : Colors.white,
          borderRadius: BorderRadius.circular(res.wp(6)),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.3)
                  : AppTheme.primaryColor.withOpacity(0.15),
              blurRadius: res.wp(6),
              spreadRadius: res.wp(1),
              offset: Offset(0, res.hp(0.5)),
            ),
          ],
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(res.wp(6)),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            backgroundColor: Colors.transparent,
            selectedItemColor: AppTheme.primaryColor,
            unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.4),
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
          vertical: res.hp(0.8),
          horizontal: res.wp(3),
        ),
        decoration: isSpecial
            ? BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(res.wp(3)),
              )
            : null,
        child: Icon(icon, size: isSpecial ? res.dp(2.8) : res.dp(2.4)),
      ),
      activeIcon: Container(
        padding: EdgeInsets.symmetric(
          vertical: res.hp(0.8),
          horizontal: res.wp(3),
        ),
        decoration: BoxDecoration(
          color: isSpecial
              ? AppTheme.primaryColor
              : AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(res.wp(3)),
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
