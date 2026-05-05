import 'package:flutter/material.dart';

import '../../localization/app_localizations.dart';
import '../../models/weather_data.dart';
import '../../services/friendly_message_builder.dart';
import '../common/glass_card.dart';

class FriendlyMessageCard extends StatelessWidget {
  final WeatherData data;
  const FriendlyMessageCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final key = FriendlyMessageBuilder.build(data);
    return GlassCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.tips_and_updates,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              t.t(key),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
