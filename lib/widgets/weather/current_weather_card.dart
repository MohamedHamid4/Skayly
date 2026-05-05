import 'package:flutter/material.dart';

import '../../core/utils/weather_mood_mapper.dart';
import '../../localization/app_localizations.dart';
import '../../models/weather_data.dart';
import '../common/glass_card.dart';
import 'sky_character.dart';

class CurrentWeatherCard extends StatelessWidget {
  final WeatherData data;
  const CurrentWeatherCard({super.key, required this.data});

  static WeatherMood _mood(WeatherData data) =>
      WeatherMoodMapper.fromConditionCode(
        data.conditionCode,
        isDay: data.isDay,
      );

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final locationLabel = data.cityName.isEmpty
        ? data.country
        : data.country.isEmpty
            ? data.cityName
            : '${data.cityName}, ${data.country}';

    return GlassCard(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  locationLabel,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.conditionText,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${data.tempC.round()}°',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 92,
                        fontWeight: FontWeight.w300,
                        height: 1,
                        letterSpacing: -2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${t.t('feels_like')} ${data.feelsLikeC.round()}°',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.75),
                          ),
                    ),
                  ],
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: animation,
                  child: FadeTransition(opacity: animation, child: child),
                ),
                child: SkyCharacter(
                  key: ValueKey(_mood(data)),
                  mood: _mood(data),
                  size: 96,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.white.withValues(alpha: 0.2), height: 1),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Metric(
                icon: Icons.water_drop,
                label: t.t('humidity'),
                value: '${data.humidity.round()}%',
              ),
              _Metric(
                icon: Icons.air,
                label: t.t('wind'),
                value: '${data.windKph.round()} km/h',
              ),
              _Metric(
                icon: Icons.wb_sunny,
                label: t.t('uv'),
                value: data.uvIndex.toStringAsFixed(1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _Metric({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.85), size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
              ),
        ),
      ],
    );
  }
}
