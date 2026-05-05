import '../core/utils/weather_mood_mapper.dart';
import '../models/weather_data.dart';

class FriendlyMessageBuilder {
  FriendlyMessageBuilder._();

  static String build(WeatherData data) {
    final today = data.today;
    final mood = WeatherMoodMapper.fromConditionCode(
      data.conditionCode,
      isDay: data.isDay,
    );

    if (mood == WeatherMood.thunderstorm) return 'msg_thunder';
    if (today.chanceOfRain >= 60 || mood == WeatherMood.rainy) return 'msg_rain';
    if (data.uvIndex >= 8) return 'msg_high_uv';
    if (mood == WeatherMood.snowy) return 'msg_snow';
    if (data.windKph >= 35) return 'msg_windy';
    if (mood == WeatherMood.foggy) return 'msg_fog';
    if (!data.isDay) return 'msg_night';
    if (data.tempC >= 18 && data.tempC <= 26) return 'msg_pleasant';
    if (data.tempC >= 28) return 'msg_hot';
    return 'msg_default';
  }
}
