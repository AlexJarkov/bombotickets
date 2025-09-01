import 'package:bombotickets/features/shared/utils/responsive.dart';
import 'package:bombotickets/config/theme/theme.dart';
import 'package:bombotickets/features/shared/widgets/home_content.dart';
import 'package:bombotickets/features/shared/widgets/profile_bottom_sheet.dart';
import 'package:bombotickets/features/tickets/presentation/tickets_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
    // Si tocan Escanear (índice 2), navegamos a la pantalla de scanner
    if (index == 2) {
      context.push('/scanner');
      return;
    }

    // Si tocan Perfil, no cambiamos el índice; sólo mostramos el sheet
    if (index == 3) {
      await _showProfileBottomSheet();
      return;
    }

    if (_selectedIndex == index) return; // No hacer nada si es la misma pestaña

    // Animar hacia la página seleccionada
    await _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
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

  Future<void> _showProfileBottomSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ProfileBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final res = Responsive.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const BouncingScrollPhysics(),
        children: [
          HomeContent(onItemTapped: _onItemTapped),
          const TicketsScreen(),
          HomeContent(onItemTapped: _onItemTapped), // Scanner placeholder
          HomeContent(onItemTapped: _onItemTapped), // Profile placeholder
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: res.wp(3),
              spreadRadius: res.wp(0.5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: AppTheme.primaryColor,
          unselectedItemColor: Colors.grey,
          selectedFontSize: res.dp(1.4),
          unselectedFontSize: res.dp(1.2),
          iconSize: res.dp(2.8),
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home, size: res.dp(2.8)),
              activeIcon: Icon(Icons.home, size: res.dp(3.2)),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.confirmation_number, size: res.dp(2.8)),
              activeIcon: Icon(Icons.confirmation_number, size: res.dp(3.2)),
              label: 'Tickets',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_scanner, size: res.dp(2.8)),
              activeIcon: Icon(Icons.qr_code_scanner, size: res.dp(3.2)),
              label: 'Escanear',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person, size: res.dp(2.8)),
              activeIcon: Icon(Icons.person, size: res.dp(3.2)),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}
