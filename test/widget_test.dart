import 'package:flutter_test/flutter_test.dart';

import 'package:skyly_app/core/utils/weather_mood_mapper.dart';

void main() {
  test('mood mapper picks night variants when not day', () {
    expect(
      WeatherMoodMapper.fromConditionCode(1000, isDay: true),
      WeatherMood.sunny,
    );
    expect(
      WeatherMoodMapper.fromConditionCode(1000, isDay: false),
      WeatherMood.clearNight,
    );
  });
}
