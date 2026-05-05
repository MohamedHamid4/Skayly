import 'dart:convert';

import '../core/constants/app_constants.dart';
import '../models/weather_data.dart';
import 'preferences_service.dart';

class CachedWeather {
  final WeatherData data;
  final DateTime cachedAt;
  final bool isStale;
  const CachedWeather({
    required this.data,
    required this.cachedAt,
    required this.isStale,
  });
}

class WeatherCache {
  final PreferencesService _prefs;
  WeatherCache(this._prefs);

  String _key(String query) =>
      '${AppConstants.prefsWeatherCachePrefix}${query.toLowerCase()}';

  Future<void> write(String query, Map<String, dynamic> rawJson) async {
    final wrapper = {
      'cachedAt': DateTime.now().millisecondsSinceEpoch,
      'data': rawJson,
    };
    await _prefs.setCachedRaw(_key(query), jsonEncode(wrapper));
  }

  CachedWeather? read(String query) {
    final raw = _prefs.getCachedRaw(_key(query));
    if (raw == null) return null;
    try {
      final wrapper = jsonDecode(raw) as Map<String, dynamic>;
      final cachedAt = DateTime.fromMillisecondsSinceEpoch(
        (wrapper['cachedAt'] as num).toInt(),
      );
      final data = WeatherData.fromJson(
        wrapper['data'] as Map<String, dynamic>,
      );
      final age = DateTime.now().difference(cachedAt);
      return CachedWeather(
        data: data,
        cachedAt: cachedAt,
        isStale: age > AppConstants.weatherCacheTtl,
      );
    } catch (_) {
      return null;
    }
  }
}
