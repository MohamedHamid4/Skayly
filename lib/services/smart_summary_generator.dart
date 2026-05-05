import '../core/utils/weather_mood_mapper.dart';
import '../models/weather_data.dart';

class SummaryResult {
  final String key;
  final Map<String, String> args;
  const SummaryResult(this.key, [this.args = const {}]);
}

class SmartSummaryGenerator {
  SmartSummaryGenerator._();

  static SummaryResult generate(WeatherData data) {
    final today = data.today;
    final mood = WeatherMoodMapper.fromConditionCode(
      data.conditionCode,
      isDay: data.isDay,
    );

    if (mood == WeatherMood.thunderstorm) {
      return const SummaryResult('summary_thunder');
    }
    if (today.chanceOfRain >= 70 || mood == WeatherMood.rainy) {
      return SummaryResult('summary_rain_likely', {
        'chance': today.chanceOfRain.toStringAsFixed(0),
      });
    }
    if (mood == WeatherMood.snowy) {
      return const SummaryResult('summary_snow');
    }
    if (today.maxTempC >= 35) {
      return SummaryResult('summary_very_hot', {
        'temp': today.maxTempC.toStringAsFixed(0),
      });
    }
    if (today.maxTempC >= 28) {
      return SummaryResult('summary_hot', {
        'temp': today.maxTempC.toStringAsFixed(0),
      });
    }
    if (today.minTempC <= 5) {
      return SummaryResult('summary_cold', {
        'temp': today.minTempC.toStringAsFixed(0),
      });
    }
    if (data.uvIndex >= 8) {
      return const SummaryResult('summary_high_uv');
    }
    if (mood == WeatherMood.foggy) {
      return const SummaryResult('summary_foggy');
    }
    if (!data.isDay) {
      return const SummaryResult('summary_pleasant_night');
    }
    return const SummaryResult('summary_pleasant_day');
  }
}
