import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../localization/app_localizations.dart';
import '../../models/hour_forecast.dart';
import '../../models/weather_data.dart';
import '../common/glass_card.dart';

class TimelineSection extends StatelessWidget {
  final WeatherData data;
  const TimelineSection({super.key, required this.data});

  List<HourForecast> _pickMoments() {
    final today = data.today.hours;
    if (today.isEmpty) return const [];
    const targets = [8, 13, 18, 22];
    final picked = <HourForecast>[];
    for (final hour in targets) {
      HourForecast? match;
      for (final h in today) {
        if (h.time.hour == hour) {
          match = h;
          break;
        }
      }
      if (match != null && !picked.contains(match)) picked.add(match);
    }
    return picked;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final moments = _pickMoments();
    if (moments.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            t.t('section_timeline'),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        const SizedBox(height: 12),
        GlassCard(
          child: Column(
            children: [
              for (var i = 0; i < moments.length; i++)
                _TimelineRow(
                  hour: moments[i],
                  locale: locale,
                  isLast: i == moments.length - 1,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final HourForecast hour;
  final String locale;
  final bool isLast;
  const _TimelineRow({
    required this.hour,
    required this.locale,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final time = DateFormat.j(locale).format(hour.time);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.85),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.4),
                    width: 2,
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Row(
                children: [
                  SizedBox(
                    width: 60,
                    child: Text(
                      time,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                  if (hour.iconUrl.isNotEmpty)
                    Image.network(
                      hour.iconUrl,
                      width: 28,
                      height: 28,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.cloud,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      hour.conditionText,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${hour.tempC.round()}°',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
