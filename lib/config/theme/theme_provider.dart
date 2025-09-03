import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider simple para manejar el estado del tema oscuro
final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, bool>(
  (ref) => ThemeNotifier(),
);

class ThemeNotifier extends StateNotifier<bool> {
  ThemeNotifier() : super(false); // false = tema claro, true = tema oscuro

  void toggleDarkMode() {
    state = !state;
  }

  void setDarkMode(bool isDark) {
    state = isDark;
  }
}
