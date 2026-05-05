import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../localization/app_localizations.dart';
import '../../models/day_forecast.dart';
import '../../models/weather_data.dart';
import '../common/glass_card.dart';

class DailyForecastSection extends StatelessWidget {
  final WeatherData data;
  const DailyForecastSection({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final days = data.daily;
    if (days.isEmpty) return const SizedBox.shrink();

    final globalMin =
        days.map((d) => d.minTempC).reduce((a, b) => a < b ? a : b);
    final globalMax =
        days.map((d) => d.maxTempC).reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            t.t('section_daily'),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        const SizedBox(height: 12),
        GlassCard(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              for (var i = 0; i < days.length; i++)
                _DayRow(
                  day: days[i],
                  locale: locale,
                  globalMin: globalMin,
                  globalMax: globalMax,
                  todayLabel: t.t('today'),
                  tomorrowLabel: t.t('tomorrow'),
                  isFirst: i == 0,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DayRow extends StatelessWidget {
  final DayForecast day;
  final String locale;
  final double globalMin;
  final double globalMax;
  final String todayLabel;
  final String tomorrowLabel;
  final bool isFirst;

  const _DayRow({
    required this.day,
    required this.locale,
    required this.globalMin,
    required this.globalMax,
    required this.todayLabel,
    required this.tomorrowLabel,
    required this.isFirst,
  });

  String _label() {
    if (isFirst) return todayLabel;
    final today = DateTime.now();
    final daysFromNow = day.date
        .difference(DateTime(today.year, today.month, today.day))
        .inDays;
    if (daysFromNow == 1) return tomorrowLabel;
    return DateFormat.EEEE(locale).format(day.date);
  }

  @override
  Widget build(BuildContext context) {
    final span = math.max(1.0, globalMax - globalMin);
    final start = ((day.minTempC - globalMin) / span).clamp(0.0, 1.0);
    final end = ((day.maxTempC - globalMin) / span).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 84,
            child: Text(
              _label(),
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          if (day.iconUrl.isNotEmpty)
            Image.network(
              day.iconUrl,
              width: 32,
              height: 32,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.cloud, color: Colors.white, size: 28),
            )
          else
            const Icon(Icons.cloud, color: Colors.white, size: 28),
          const SizedBox(width: 10),
          SizedBox(
            width: 36,
            child: Text(
              '${day.minTempC.round()}°',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, c) {
                return SizedBox(
                  height: 6,
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      Positioned(
                        left: c.maxWidth * start,
                        width: c.maxWidth * (end - start),
                        top: 0,
                        bottom: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF66A6FF),
                                Color(0xFFFFB75E),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 36,
            child: Text(
              '${day.maxTempC.round()}°',
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

