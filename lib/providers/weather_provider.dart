import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/errors/failures.dart';
import '../models/weather_data.dart';
import 'locale_provider.dart';
import 'service_providers.dart';

class WeatherState {
  final WeatherData data;
  final bool fromCache;
  final DateTime? cachedAt;
  const WeatherState({
    required this.data,
    required this.fromCache,
    this.cachedAt,
  });
}

class WeatherNotifier extends AsyncNotifier<WeatherState> {
  @override
  Future<WeatherState> build() async {
    // Re-fetch on locale change so condition.text is localized.
    final locale = ref.watch(localeProvider);
    return _load(locale);
  }

  String _langCode(Locale? locale) {
    final code = locale?.languageCode ?? 'en';
    return code == 'ar' ? 'ar' : 'en';
  }

  Future<WeatherState> _load(Locale? locale) async {
    final prefs = await ref.read(preferencesProvider.future);
    final service = await ref.read(weatherServiceProvider.future);
    final lang = _langCode(locale);

    // Cache-first for fast warm starts: if we have a fresh cached entry for
    // the last known city, serve it instantly. The user can pull-to-refresh
    // for fresh data; the _StaleHint widget shows the cache age.
    // Note: skipped on locale change because cached condition.text is in the
    // previous locale.
    final lastCity = prefs.getLastCity();
    if (lastCity != null && lastCity.isNotEmpty) {
      final cache = await ref.read(weatherCacheProvider.future);
      final cached = cache.read(lastCity);
      if (cached != null && !cached.isStale) {
        // Only serve when the cached condition.text matches the current
        // language. WeatherAPI returns localized text; mismatched locales
        // would show the wrong language until the next refresh.
        final cachedIsCurrentLang = lang == 'en'
            ? !_looksArabic(cached.data.conditionText)
            : _looksArabic(cached.data.conditionText);
        if (cachedIsCurrentLang) {
          return WeatherState(
            data: cached.data,
            fromCache: true,
            cachedAt: cached.cachedAt,
          );
        }
      }
    }

    try {
      final loc = ref.read(locationServiceProvider);
      final pos = await loc.getCurrentPosition();
      final result = await service.fetchByCoords(
        lat: pos.latitude,
        lon: pos.longitude,
        langCode: lang,
      );
      await prefs.setLastCity(result.data.cityName);
      return WeatherState(
        data: result.data,
        fromCache: result.fromCache,
        cachedAt: result.cachedAt,
      );
    } on AppFailure {
      if (lastCity == null || lastCity.isEmpty) rethrow;
      final result = await service.fetchByCity(
        city: lastCity,
        langCode: lang,
      );
      await prefs.setLastCity(result.data.cityName);
      return WeatherState(
        data: result.data,
        fromCache: result.fromCache,
        cachedAt: result.cachedAt,
      );
    }
  }

  // Cheap heuristic — Arabic Unicode block U+0600–U+06FF.
  static bool _looksArabic(String s) {
    for (final code in s.codeUnits) {
      if (code >= 0x0600 && code <= 0x06FF) return true;
    }
    return false;
  }

  Future<void> refresh() async {
    final locale = ref.read(localeProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _load(locale));
  }

  Future<void> searchCity(String city) async {
    final trimmed = city.trim();
    if (trimmed.isEmpty) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final prefs = await ref.read(preferencesProvider.future);
      final service = await ref.read(weatherServiceProvider.future);
      final lang = _langCode(ref.read(localeProvider));
      final result = await service.fetchByCity(
        city: trimmed,
        langCode: lang,
      );
      await prefs.setLastCity(result.data.cityName);
      return WeatherState(
        data: result.data,
        fromCache: result.fromCache,
        cachedAt: result.cachedAt,
      );
    });
  }
}

final weatherProvider =
    AsyncNotifierProvider<WeatherNotifier, WeatherState>(WeatherNotifier.new);
