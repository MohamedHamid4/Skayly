import 'dart:math' as math;

import '../models/weather_data.dart';

class DayScores {
  final double outdoor;
  final double walking;
  final double exercise;
  const DayScores({
    required this.outdoor,
    required this.walking,
    required this.exercise,
  });

  static DayScores compute(WeatherData data) {
    final today = data.today;
    final temp = today.avgTempC;
    final rain = today.chanceOfRain;
    final wind = today.maxWindKph;
    final uv = today.uvIndex;
    final humidity = today.avgHumidity;

    double tempPenalty(double low, double high, double weight) {
      if (temp >= low && temp <= high) return 0;
      final distance = temp < low ? low - temp : temp - high;
      return math.min(weight, distance * weight / 15);
    }

    double windPenalty(double threshold) =>
        wind > threshold ? math.min(2.5, (wind - threshold) / 10) : 0;

    double uvPenalty(double threshold, double weight) =>
        uv > threshold ? math.min(weight * 4, (uv - threshold) * weight) : 0;

    double humidityPenalty(double threshold) =>
        humidity > threshold ? math.min(2.0, (humidity - threshold) / 10) : 0;

    final outdoor = (10 -
            tempPenalty(15, 28, 4) -
            rain / 25 -
            windPenalty(25) -
            uvPenalty(7, 0.6))
        .clamp(0.0, 10.0)
        .toDouble();

    final walking = (10 -
            tempPenalty(12, 26, 3.5) -
            rain / 20 -
            windPenalty(20) -
            humidityPenalty(80))
        .clamp(0.0, 10.0)
        .toDouble();

    final exercise = (10 -
            tempPenalty(10, 24, 4) -
            rain / 30 -
            uvPenalty(6, 0.5) -
            humidityPenalty(75))
        .clamp(0.0, 10.0)
        .toDouble();

    return DayScores(
      outdoor: outdoor,
      walking: walking,
      exercise: exercise,
    );
  }
}
