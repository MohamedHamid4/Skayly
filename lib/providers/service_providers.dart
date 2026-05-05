import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/location_service.dart';
import '../services/preferences_service.dart';
import '../services/weather_cache.dart';
import '../services/weather_service.dart';

final preferencesProvider = FutureProvider<PreferencesService>((ref) {
  return PreferencesService.create();
});

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final weatherCacheProvider = FutureProvider<WeatherCache>((ref) async {
  final prefs = await ref.watch(preferencesProvider.future);
  return WeatherCache(prefs);
});

final weatherServiceProvider = FutureProvider<WeatherService>((ref) async {
  final cache = await ref.watch(weatherCacheProvider.future);
  return WeatherService(cache: cache);
});
