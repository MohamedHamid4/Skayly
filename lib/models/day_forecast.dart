import 'hour_forecast.dart';

class DayForecast {
  final DateTime date;
  final double minTempC;
  final double maxTempC;
  final double avgTempC;
  final int conditionCode;
  final String conditionText;
  final String iconUrl;
  final double chanceOfRain;
  final double maxWindKph;
  final double avgHumidity;
  final double uvIndex;
  final DateTime? sunrise;
  final DateTime? sunset;
  final List<HourForecast> hours;

  const DayForecast({
    required this.date,
    required this.minTempC,
    required this.maxTempC,
    required this.avgTempC,
    required this.conditionCode,
    required this.conditionText,
    required this.iconUrl,
    required this.chanceOfRain,
    required this.maxWindKph,
    required this.avgHumidity,
    required this.uvIndex,
    required this.sunrise,
    required this.sunset,
    required this.hours,
  });

  factory DayForecast.fromJson(Map<String, dynamic> json) {
    final day = json['day'] as Map<String, dynamic>? ?? const {};
    final astro = json['astro'] as Map<String, dynamic>? ?? const {};
    final condition = day['condition'] as Map<String, dynamic>? ?? const {};
    final iconRaw = (condition['icon'] as String?) ?? '';
    final hoursList = (json['hour'] as List<dynamic>? ?? const [])
        .map((e) => HourForecast.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);

    final dateStr = json['date'] as String? ?? '';
    final date = DateTime.tryParse(dateStr) ?? DateTime.now();

    return DayForecast(
      date: date,
      minTempC: (day['mintemp_c'] as num?)?.toDouble() ?? 0,
      maxTempC: (day['maxtemp_c'] as num?)?.toDouble() ?? 0,
      avgTempC: (day['avgtemp_c'] as num?)?.toDouble() ?? 0,
      conditionCode: (condition['code'] as num?)?.toInt() ?? 1000,
      conditionText: (condition['text'] as String?) ?? '',
      iconUrl: iconRaw.startsWith('//') ? 'https:$iconRaw' : iconRaw,
      chanceOfRain: (day['daily_chance_of_rain'] as num?)?.toDouble() ?? 0,
      maxWindKph: (day['maxwind_kph'] as num?)?.toDouble() ?? 0,
      avgHumidity: (day['avghumidity'] as num?)?.toDouble() ?? 0,
      uvIndex: (day['uv'] as num?)?.toDouble() ?? 0,
      sunrise: _parseAstroTime(date, astro['sunrise'] as String?),
      sunset: _parseAstroTime(date, astro['sunset'] as String?),
      hours: hoursList,
    );
  }

  static DateTime? _parseAstroTime(DateTime date, String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final parts = raw.trim().split(' ');
      final time = parts[0].split(':');
      var hour = int.parse(time[0]);
      final minute = int.parse(time[1]);
      if (parts.length == 2) {
        final period = parts[1].toUpperCase();
        if (period == 'PM' && hour != 12) hour += 12;
        if (period == 'AM' && hour == 12) hour = 0;
      }
      return DateTime(date.year, date.month, date.day, hour, minute);
    } catch (_) {
      return null;
    }
  }
}
