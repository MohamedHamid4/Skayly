import 'package:flutter/material.dart';

import '../../localization/app_localizations.dart';
import '../../models/weather_data.dart';
import '../../services/outfit_advisor.dart';
import '../common/glass_card.dart';

class OutfitCard extends StatelessWidget {
  final WeatherData data;
  const OutfitCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final key = OutfitAdvisor.suggest(data);
    return GlassCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.checkroom,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.t('section_outfit'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                        letterSpacing: 0.4,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  t.t(key),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
