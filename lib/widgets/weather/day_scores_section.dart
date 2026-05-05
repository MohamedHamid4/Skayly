import 'package:flutter/material.dart';

import '../../localization/app_localizations.dart';
import '../../models/weather_data.dart';
import '../../services/day_scores.dart';
import '../common/glass_card.dart';

class DayScoresSection extends StatelessWidget {
  final WeatherData data;
  const DayScoresSection({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final scores = DayScores.compute(data);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            t.t('section_scores'),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        const SizedBox(height: 12),
        GlassCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _ScoreDial(label: t.t('score_outdoor'), value: scores.outdoor),
              _ScoreDial(label: t.t('score_walking'), value: scores.walking),
              _ScoreDial(label: t.t('score_exercise'), value: scores.exercise),
            ],
          ),
        ),
      ],
    );
  }
}

class _ScoreDial extends StatelessWidget {
  final String label;
  final double value;
  const _ScoreDial({required this.label, required this.value});

  Color get _color {
    if (value >= 7) return const Color(0xFF7ED957);
    if (value >= 4) return const Color(0xFFFFB347);
    return const Color(0xFFFF6B6B);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 64,
          height: 64,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox.expand(
                child: CircularProgressIndicator(
                  value: value / 10,
                  strokeWidth: 5,
                  backgroundColor: Colors.white.withValues(alpha: 0.18),
                  valueColor: AlwaysStoppedAnimation(_color),
                ),
              ),
              Text(
                value.toStringAsFixed(1),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.85),
              ),
        ),
      ],
    );
  }
}
