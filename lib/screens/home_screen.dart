import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/errors/failures.dart';
import '../core/utils/weather_mood_mapper.dart';
import '../localization/app_localizations.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/weather_provider.dart';
import '../widgets/backgrounds/dynamic_background.dart';
import '../widgets/common/banner_ad_widget.dart';
import '../widgets/common/error_view.dart';
import '../widgets/common/loading_view.dart';
import '../widgets/common/search_city_sheet.dart';
import '../widgets/weather/current_weather_card.dart';
import '../widgets/weather/daily_forecast_section.dart';
import '../widgets/weather/day_scores_section.dart';
import '../widgets/weather/friendly_message_card.dart';
import '../widgets/weather/hourly_forecast_section.dart';
import '../widgets/weather/outfit_card.dart';
import '../widgets/weather/smart_summary_card.dart';
import '../widgets/weather/timeline_section.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // When the user returns from system Settings (e.g. just enabled
      // location), re-attempt the fetch if we're currently in an error state.
      final current = ref.read(weatherProvider);
      if (current is AsyncError) {
        ref.read(weatherProvider.notifier).refresh();
      }
    }
  }

  void _openSearch() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const SearchCitySheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final weather = ref.watch(weatherProvider);
    // Background: real mood when data is loaded; welcome gradient otherwise.
    final background = weather.maybeWhen(
      data: (state) {
        final mood = WeatherMoodMapper.fromConditionCode(
          state.data.conditionCode,
          isDay: state.data.isDay,
        );
        return DynamicBackground(mood: mood);
      },
      orElse: () => const DynamicBackground.welcome(),
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(child: background),
          SafeArea(
            child: Column(
              children: [
                _TopBar(onSearch: _openSearch),
                Expanded(
                  child: weather.when(
                    loading: () => const LoadingView(),
                    error: (e, _) => ErrorView(
                      failure: e is AppFailure ? e : const UnknownFailure(),
                      onRetry: () =>
                          ref.read(weatherProvider.notifier).refresh(),
                      onSearchCity: _openSearch,
                    ),
                    data: (state) => RefreshIndicator(
                      onRefresh: () =>
                          ref.read(weatherProvider.notifier).refresh(),
                      child: _HomeContent(state: state),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          color: Colors.black.withValues(alpha: 0.15),
          child: const BannerAdWidget(),
        ),
      ),
    );
  }
}

class _TopBar extends ConsumerWidget {
  final VoidCallback onSearch;
  const _TopBar({required this.onSearch});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final themeMode = ref.watch(themeModeProvider);

    // Icon reflects current state so the affordance is unambiguous.
    final themeIcon = switch (themeMode) {
      ThemeMode.light => Icons.light_mode_outlined,
      ThemeMode.dark => Icons.dark_mode_outlined,
      ThemeMode.system => Icons.brightness_auto_outlined,
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              t.t('app_name'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w500,
                letterSpacing: 1,
              ),
            ),
          ),
          IconButton(
            onPressed: onSearch,
            icon: const Icon(Icons.search, color: Colors.white),
            tooltip: t.t('search_city_hint'),
          ),
          IconButton(
            onPressed: () =>
                ref.read(localeProvider.notifier).toggleEnglishArabic(),
            icon: const Icon(Icons.translate, color: Colors.white),
            tooltip: t.t('language'),
          ),
          IconButton(
            onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
            icon: Icon(themeIcon, color: Colors.white),
            tooltip: t.t('theme'),
          ),
        ],
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final WeatherState state;
  const _HomeContent({required this.state});

  @override
  Widget build(BuildContext context) {
    final data = state.data;
    final locale = Localizations.localeOf(context);
    // Cross-fade content when locale toggles so the language switch doesn't
    // feel like a hard cut. ListView identity is keyed by locale.
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: ListView(
        key: ValueKey(locale.languageCode),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          if (state.fromCache && state.cachedAt != null)
            _StaleHint(cachedAt: state.cachedAt!),
          CurrentWeatherCard(data: data),
          const SizedBox(height: 16),
          SmartSummaryCard(data: data),
          const SizedBox(height: 16),
          FriendlyMessageCard(data: data),
          const SizedBox(height: 20),
          HourlyForecastSection(data: data),
          const SizedBox(height: 20),
          TimelineSection(data: data),
          const SizedBox(height: 20),
          OutfitCard(data: data),
          const SizedBox(height: 20),
          DayScoresSection(data: data),
          const SizedBox(height: 20),
          DailyForecastSection(data: data),
        ],
      ),
    );
  }
}

class _StaleHint extends StatelessWidget {
  final DateTime cachedAt;
  const _StaleHint({required this.cachedAt});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final minutes = DateTime.now().difference(cachedAt).inMinutes;
    final label = minutes <= 0
        ? t.t('updated_just_now')
        : t.t('updated_minutes_ago', {'minutes': '$minutes'});
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
