import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  const SettingsState({
    this.darkMode = false,
    this.notificationsEnabled = true,
    this.locationEnabled = true,
    this.language = 'ckb',
  });

  final bool darkMode;
  final bool notificationsEnabled;
  final bool locationEnabled;
  final String language; // ckb | ar | en

  SettingsState copyWith({
    bool? darkMode,
    bool? notificationsEnabled,
    bool? locationEnabled,
    String? language,
  }) =>
      SettingsState(
        darkMode: darkMode ?? this.darkMode,
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
        locationEnabled: locationEnabled ?? this.locationEnabled,
        language: language ?? this.language,
      );
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState()) {
    _load();
  }

  static const _kDark = 'settings_dark_mode';
  static const _kNotif = 'settings_notifications';
  static const _kLoc = 'settings_location';
  static const _kLang = 'settings_language';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = SettingsState(
      darkMode: prefs.getBool(_kDark) ?? false,
      notificationsEnabled: prefs.getBool(_kNotif) ?? true,
      locationEnabled: prefs.getBool(_kLoc) ?? true,
      language: prefs.getString(_kLang) ?? 'ckb',
    );
  }

  Future<void> setDarkMode(bool value) async {
    state = state.copyWith(darkMode: value);
    (await SharedPreferences.getInstance()).setBool(_kDark, value);
  }

  Future<void> setNotifications(bool value) async {
    state = state.copyWith(notificationsEnabled: value);
    (await SharedPreferences.getInstance()).setBool(_kNotif, value);
  }

  Future<void> setLocation(bool value) async {
    state = state.copyWith(locationEnabled: value);
    (await SharedPreferences.getInstance()).setBool(_kLoc, value);
  }

  Future<void> setLanguage(String value) async {
    state = state.copyWith(language: value);
    (await SharedPreferences.getInstance()).setString(_kLang, value);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) => SettingsNotifier(),
);

/// Derives Flutter's ThemeMode from the persisted preference, for
/// `MaterialApp(themeMode: ...)`.
final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(settingsProvider).darkMode ? ThemeMode.dark : ThemeMode.light;
});
