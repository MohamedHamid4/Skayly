import '../core/utils/weather_mood_mapper.dart';
import '../models/weather_data.dart';

class OutfitAdvisor {
  OutfitAdvisor._();

  static String suggest(WeatherData data) {
    final mood = WeatherMoodMapper.fromConditionCode(
      data.conditionCode,
      isDay: data.isDay,
    );
    final wet = mood == WeatherMood.rainy ||
        mood == WeatherMood.thunderstorm ||
        data.precipMm > 0.2;
    final feels = data.feelsLikeC;
    final windy = data.windKph >= 30;

    if (wet && feels < 10) return 'outfit_cold_wet';
    if (wet) return 'outfit_rainy';
    if (feels >= 32) return 'outfit_hot';
    if (feels >= 24) return 'outfit_warm';
    if (feels >= 16) return windy ? 'outfit_windy' : 'outfit_mild';
    if (feels >= 8) return 'outfit_cool';
    if (feels >= 0) return 'outfit_cold';
    return 'outfit_freezing';
  }
}
