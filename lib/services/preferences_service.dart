import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';

class PreferencesService {
  final SharedPreferences _prefs;
  PreferencesService(this._prefs);

  static Future<PreferencesService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return PreferencesService(prefs);
  }

  ThemeMode getThemeMode() {
    final raw = _prefs.getString(AppConstants.prefsThemeMode);
    return switch (raw) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final raw = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await _prefs.setString(AppConstants.prefsThemeMode, raw);
  }

  Locale? getLocale() {
    final raw = _prefs.getString(AppConstants.prefsLocale);
    if (raw == null || raw.isEmpty) return null;
    return Locale(raw);
  }

  Future<void> setLocale(Locale? locale) async {
    if (locale == null) {
      await _prefs.remove(AppConstants.prefsLocale);
    } else {
      await _prefs.setString(AppConstants.prefsLocale, locale.languageCode);
    }
  }

  String? getLastCity() => _prefs.getString(AppConstants.prefsLastCity);
  Future<void> setLastCity(String city) =>
      _prefs.setString(AppConstants.prefsLastCity, city);

  String? getCachedRaw(String key) => _prefs.getString(key);
  Future<void> setCachedRaw(String key, String value) =>
      _prefs.setString(key, value);
  Future<void> clearCachedRaw(String key) => _prefs.remove(key);
}
