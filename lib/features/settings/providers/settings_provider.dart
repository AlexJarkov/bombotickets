import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  final bool reduceMotion;
  final ThemeMode themeMode;

  const SettingsState({this.reduceMotion = false, this.themeMode = ThemeMode.system});

  SettingsState copyWith({bool? reduceMotion, ThemeMode? themeMode}) =>
      SettingsState(
        reduceMotion: reduceMotion ?? this.reduceMotion,
        themeMode: themeMode ?? this.themeMode,
      );
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});

class SettingsNotifier extends StateNotifier<SettingsState> {
  static const _kReduceMotionKey = 'settings.reduceMotion';
  static const _kThemeModeKey = 'settings.themeMode';

  SettingsNotifier() : super(const SettingsState()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final reduceMotion = prefs.getBool(_kReduceMotionKey) ?? false;
    final themeModeIndex = prefs.getInt(_kThemeModeKey) ?? ThemeMode.system.index;
    final themeMode = ThemeMode.values[themeModeIndex];
    state = state.copyWith(reduceMotion: reduceMotion, themeMode: themeMode);
  }

  void setReduceMotion(bool value) {
    if (state.reduceMotion == value) return;
    state = state.copyWith(reduceMotion: value);
    _persistReduceMotion(value);
  }

  void toggleReduceMotion() {
    final newValue = !state.reduceMotion;
    state = state.copyWith(reduceMotion: newValue);
    _persistReduceMotion(newValue);
  }

  void setThemeMode(ThemeMode mode) {
    if (state.themeMode == mode) return;
    state = state.copyWith(themeMode: mode);
    _persistThemeMode(mode);
  }

  Future<void> _persistReduceMotion(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kReduceMotionKey, value);
  }

  Future<void> _persistThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kThemeModeKey, mode.index);
  }
}
