import 'package:flutter/foundation.dart';

class AppConstants {
  AppConstants._();

  static const String appName = 'Skyly';

  // ============================================================
  // WeatherAPI.com
  // ============================================================
  // Dev key embedded as defaultValue so the app runs out of the box.
  // For production, override via:
  //   flutter run --dart-define=WEATHER_API_KEY=your_prod_key
  static const String weatherApiKey = String.fromEnvironment(
    'WEATHER_API_KEY',
    defaultValue: '6b214b498c3946cca0a83501260505',
  );
  static const String weatherApiBaseUrl = 'https://api.weatherapi.com/v1';

  // ============================================================
  // AdMob — Banner Ad Unit IDs
  // ============================================================
  // The App ID lives in AndroidManifest.xml, NOT here.
  //
  // The Google Mobile Ads SDK auto-detects emulators and test devices
  // and serves test ads even when a real Ad Unit ID is configured —
  // so using the real ID during development will not get the account
  // flagged for invalid traffic.
  static const String admobBannerAndroid = String.fromEnvironment(
    'ADMOB_BANNER_ANDROID',
    defaultValue: 'ca-app-pub-3962967753864866/4243258688',
  );

  static const String admobBanneriOS = String.fromEnvironment(
    'ADMOB_BANNER_IOS',
    // iOS test ID until the iOS app is registered with AdMob.
    defaultValue: 'ca-app-pub-3940256099942544/2934735716',
  );

  // Debug builds always serve Google's test banner (no risk of "no fill" or
  // policy flags); release builds use the real unit IDs above.
  static const String _admobAndroidTestBanner =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _admobIosTestBanner =
      'ca-app-pub-3940256099942544/2934735716';

  static String get effectiveAdmobBannerAndroid =>
      kDebugMode ? _admobAndroidTestBanner : admobBannerAndroid;

  static String get effectiveAdmobBanneriOS =>
      kDebugMode ? _admobIosTestBanner : admobBanneriOS;

  // ============================================================
  // Storage keys
  // ============================================================
  static const String prefsThemeMode = 'skyly.theme_mode';
  static const String prefsLocale = 'skyly.locale';
  static const String prefsLastCity = 'skyly.last_city';
  static const String prefsWeatherCachePrefix = 'skyly.weather_cache.';

  // ============================================================
  // Forecast & cache config
  // ============================================================
  static const int forecastDays = 7;
  static const Duration weatherCacheTtl = Duration(minutes: 15);
  static const Duration networkTimeout = Duration(seconds: 15);
}
