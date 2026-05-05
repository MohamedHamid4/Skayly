import 'package:flutter/material.dart';

import '../../core/utils/weather_mood_mapper.dart';

/// Renders the Sky cloud character matching the given weather mood.
/// All 9 moods have a dedicated PNG in assets/icons/moods/.
class SkyCharacter extends StatelessWidget {
  final WeatherMood mood;
  final double size;

  const SkyCharacter({
    super.key,
    required this.mood,
    this.size = 96,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _assetPath(mood),
      width: size,
      height: size,
      fit: BoxFit.contain,
      // Defensive fallback if an asset is somehow missing at runtime.
      errorBuilder: (_, __, ___) => Icon(
        Icons.cloud_outlined,
        size: size,
        color: Colors.white,
      ),
    );
  }

  static String _assetPath(WeatherMood mood) {
    final name = switch (mood) {
      WeatherMood.sunny => 'sunny',
      WeatherMood.partlyCloudy => 'partly_cloudy',
      WeatherMood.cloudy => 'cloudy',
      WeatherMood.rainy => 'rainy',
      WeatherMood.thunderstorm => 'thunderstorm',
      WeatherMood.snowy => 'snowy',
      WeatherMood.foggy => 'foggy',
      WeatherMood.clearNight => 'clear_night',
      WeatherMood.cloudyNight => 'cloudy_night',
    };
    return 'assets/icons/moods/sky_$name.png';
  }
}
