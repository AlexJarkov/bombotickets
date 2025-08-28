import 'package:bombotickets/config/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:paybox_app/config/theme/theme_provider.dart';

class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //final isDarkMode = ref.watch(themeNotifierProvider).isDarkMode;
    return AppBar(
      backgroundColor: AppTheme.scaffoldBackground,
      automaticallyImplyLeading: false, // Esta línea quita la flecha
      //title: Text("PaxBox"),
      //elevation: 2,
      //centerTitle: true,
      // title: Row(
      //   children: [
      //     Image.asset(
      //       "assets/images/logo.jpg",  // Ruta del logo
      //       height: 40,
      //     ),
      //     const SizedBox(width: 10),
      //     const Text("PayBox"),
      //   ],
      // ),
      // actions: [
      //   IconButton(
      //     icon: Icon(isDarkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined),
      //     onPressed: () {
      //       ref.read(themeNotifierProvider.notifier).toggleDarkMode();
      //     },
      //   ),
      // ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
