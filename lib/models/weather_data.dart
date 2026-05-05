import 'day_forecast.dart';
import 'hour_forecast.dart';

class WeatherData {
  final String cityName;
  final String region;
  final String country;
  final double latitude;
  final double longitude;
  final DateTime localTime;

  // Current conditions
  final double tempC;
  final double feelsLikeC;
  final int conditionCode;
  final String conditionText;
  final String iconUrl;
  final bool isDay;
  final double humidity;
  final double windKph;
  final double uvIndex;
  final double pressureMb;
  final double precipMm;

  final List<DayForecast> daily;

  const WeatherData({
    required this.cityName,
    required this.region,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.localTime,
    required this.tempC,
    required this.feelsLikeC,
    required this.conditionCode,
    required this.conditionText,
    required this.iconUrl,
    required this.isDay,
    required this.humidity,
    required this.windKph,
    required this.uvIndex,
    required this.pressureMb,
    required this.precipMm,
    required this.daily,
  });

  DayForecast get today {
    if (daily.isEmpty) {
      throw StateError('WeatherData has no daily forecast entries');
    }
    return daily.first;
  }

  List<HourForecast> get next24Hours {
    final all = daily.expand((d) => d.hours).toList()
      ..sort((a, b) => a.time.compareTo(b.time));
    final cutoff = localTime.subtract(const Duration(hours: 1));
    return all.where((h) => h.time.isAfter(cutoff)).take(24).toList();
  }

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final loc = json['location'] as Map<String, dynamic>? ?? const {};
    final current = json['current'] as Map<String, dynamic>? ?? const {};
    final condition = current['condition'] as Map<String, dynamic>? ?? const {};
    final iconRaw = (condition['icon'] as String?) ?? '';
    final forecast = json['forecast'] as Map<String, dynamic>? ?? const {};
    final forecastDays = (forecast['forecastday'] as List<dynamic>? ?? const [])
        .map((e) => DayForecast.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);

    final localTimeEpoch = (loc['localtime_epoch'] as num?)?.toInt();
    final localTime = localTimeEpoch != null
        ? DateTime.fromMillisecondsSinceEpoch(localTimeEpoch * 1000)
        : DateTime.now();

    return WeatherData(
      cityName: (loc['name'] as String?) ?? '',
      region: (loc['region'] as String?) ?? '',
      country: (loc['country'] as String?) ?? '',
      latitude: (loc['lat'] as num?)?.toDouble() ?? 0,
      longitude: (loc['lon'] as num?)?.toDouble() ?? 0,
      localTime: localTime,
      tempC: (current['temp_c'] as num?)?.toDouble() ?? 0,
      feelsLikeC: (current['feelslike_c'] as num?)?.toDouble() ?? 0,
      conditionCode: (condition['code'] as num?)?.toInt() ?? 1000,
      conditionText: (condition['text'] as String?) ?? '',
      iconUrl: iconRaw.startsWith('//') ? 'https:$iconRaw' : iconRaw,
      isDay: ((current['is_day'] as num?)?.toInt() ?? 1) == 1,
      humidity: (current['humidity'] as num?)?.toDouble() ?? 0,
      windKph: (current['wind_kph'] as num?)?.toDouble() ?? 0,
      uvIndex: (current['uv'] as num?)?.toDouble() ?? 0,
      pressureMb: (current['pressure_mb'] as num?)?.toDouble() ?? 0,
      precipMm: (current['precip_mm'] as num?)?.toDouble() ?? 0,
      daily: forecastDays,
    );
  }
}
