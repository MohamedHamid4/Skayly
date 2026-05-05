import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/utils/weather_mood_mapper.dart';
import '../../theme/app_theme.dart';

class DynamicBackground extends StatelessWidget {
  /// Used during loading and error states — when no real weather data is
  /// available. Designed to feel welcoming, not overcast.
  static const welcomeGradient = [
    Color(0xFF6DD5FA), // bright sky blue
    Color(0xFF2980B9), // deeper blue
  ];

  final WeatherMood? mood;

  const DynamicBackground({super.key, required WeatherMood this.mood});

  /// Static, ambient-free gradient for loading/error states.
  const DynamicBackground.welcome({super.key}) : mood = null;

  String get _gradientKey {
    final m = mood;
    if (m == null) return 'welcome';
    return switch (m) {
      WeatherMood.sunny => 'sunny',
      WeatherMood.partlyCloudy => 'partlyCloudy',
      WeatherMood.cloudy => 'cloudy',
      WeatherMood.rainy => 'rainy',
      WeatherMood.thunderstorm => 'thunderstorm',
      WeatherMood.snowy => 'snowy',
      WeatherMood.foggy => 'foggy',
      WeatherMood.clearNight => 'clearNight',
      WeatherMood.cloudyNight => 'cloudyNight',
    };
  }

  @override
  Widget build(BuildContext context) {
    final m = mood;
    final colors = m == null
        ? welcomeGradient
        : (AppPalette.moodGradients[_gradientKey] ??
              AppPalette.moodGradients['cloudy']!);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      child: Container(
        key: ValueKey(_gradientKey),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: colors,
          ),
        ),
        // Welcome state stays clean — no rain streaks, no stars.
        child: m == null
            ? null
            : CustomPaint(
                painter: _AmbientPainter(mood: m),
                size: Size.infinite,
              ),
      ),
    );
  }
}

class _AmbientPainter extends CustomPainter {
  final WeatherMood mood;
  _AmbientPainter({required this.mood});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(42); // deterministic — no flicker on rebuild
    switch (mood) {
      case WeatherMood.clearNight:
        _paintStars(canvas, size, rng, 60);
        break;
      case WeatherMood.cloudyNight:
        _paintStars(canvas, size, rng, 25);
        _paintClouds(canvas, size, rng, 4, alpha: 0.10);
        break;
      case WeatherMood.sunny:
        _paintSunGlow(canvas, size);
        break;
      case WeatherMood.partlyCloudy:
        _paintClouds(canvas, size, rng, 3, alpha: 0.18);
        break;
      case WeatherMood.cloudy:
      case WeatherMood.foggy:
        _paintClouds(canvas, size, rng, 6, alpha: 0.20);
        break;
      case WeatherMood.rainy:
        _paintRain(canvas, size, rng, 80);
        break;
      case WeatherMood.thunderstorm:
        _paintRain(canvas, size, rng, 100);
        _paintLightning(canvas, size);
        break;
      case WeatherMood.snowy:
        _paintSnow(canvas, size, rng, 70);
        break;
    }
  }

  void _paintStars(Canvas canvas, Size size, math.Random rng, int count) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.85);
    for (var i = 0; i < count; i++) {
      final dx = rng.nextDouble() * size.width;
      final dy = rng.nextDouble() * size.height * 0.6;
      final r = rng.nextDouble() * 1.4 + 0.4;
      canvas.drawCircle(Offset(dx, dy), r, paint);
    }
  }

  void _paintSunGlow(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.78, size.height * 0.18);
    final radius = size.width * 0.5;
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.45),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
  }

  void _paintClouds(
    Canvas canvas,
    Size size,
    math.Random rng,
    int count, {
    double alpha = 0.18,
  }) {
    final paint = Paint()..color = Colors.white.withValues(alpha: alpha);
    for (var i = 0; i < count; i++) {
      final cx = rng.nextDouble() * size.width;
      final cy = rng.nextDouble() * size.height * 0.5;
      final w = 80 + rng.nextDouble() * 120;
      final h = 24 + rng.nextDouble() * 16;
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy), width: w, height: h),
        Radius.circular(h),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  void _paintRain(Canvas canvas, Size size, math.Random rng, int count) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < count; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      canvas.drawLine(Offset(x, y), Offset(x - 4, y + 12), paint);
    }
  }

  void _paintLightning(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;
    final startX = size.width * 0.4;
    final path = Path()
      ..moveTo(startX, 0)
      ..lineTo(startX - 12, size.height * 0.4)
      ..lineTo(startX + 4, size.height * 0.4)
      ..lineTo(startX - 18, size.height * 0.85)
      ..lineTo(startX + 8, size.height * 0.45)
      ..lineTo(startX - 4, size.height * 0.45)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _paintSnow(Canvas canvas, Size size, math.Random rng, int count) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.7);
    for (var i = 0; i < count; i++) {
      final dx = rng.nextDouble() * size.width;
      final dy = rng.nextDouble() * size.height;
      final r = rng.nextDouble() * 2 + 1;
      canvas.drawCircle(Offset(dx, dy), r, paint);
    }
  }

  @override
  bool shouldRepaint(_AmbientPainter old) => old.mood != mood;
}
