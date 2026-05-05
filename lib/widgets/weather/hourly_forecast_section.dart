import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../localization/app_localizations.dart';
import '../../models/hour_forecast.dart';
import '../../models/weather_data.dart';
import '../common/glass_card.dart';

class HourlyForecastSection extends StatelessWidget {
  final WeatherData data;
  const HourlyForecastSection({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final hours = data.next24Hours;
    if (hours.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            t.t('section_hourly'),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        const SizedBox(height: 12),
        GlassCard(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: SizedBox(
            height: 130,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: hours.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (_, i) => _HourTile(
                hour: hours[i],
                locale: locale,
                isFirst: i == 0,
                nowLabel: t.t('now'),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HourTile extends StatelessWidget {
  final HourForecast hour;
  final String locale;
  final bool isFirst;
  final String nowLabel;
  const _HourTile({
    required this.hour,
    required this.locale,
    required this.isFirst,
    required this.nowLabel,
  });

  @override
  Widget build(BuildContext context) {
    final timeLabel =
        isFirst ? nowLabel : DateFormat.j(locale).format(hour.time);
    return SizedBox(
      width: 64,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            timeLabel,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                ),
          ),
          if (hour.iconUrl.isNotEmpty)
            Image.network(
              hour.iconUrl,
              width: 36,
              height: 36,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.cloud, color: Colors.white, size: 28),
            )
          else
            const Icon(Icons.cloud, color: Colors.white, size: 28),
          if (hour.chanceOfRain > 0)
            Text(
              '${hour.chanceOfRain.round()}%',
              style: TextStyle(
                color: Colors.lightBlueAccent.shade100,
                fontSize: 11,
              ),
            )
          else
            const SizedBox(height: 14),
          Text(
            '${hour.tempC.round()}°',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
