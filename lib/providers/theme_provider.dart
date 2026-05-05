import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/preferences_service.dart';
import 'service_providers.dart';

class ThemeModeNotifier extends Notifier<ThemeMode> {
  bool _hydrated = false;

  @override
  ThemeMode build() {
    // Hydrate from prefs exactly once. Any subsequent emissions must not
    // clobber a user-driven state change (e.g. just-toggled mode).
    ref.listen<AsyncValue<PreferencesService>>(preferencesProvider, (
      prev,
      next,
    ) {
      next.whenData((prefs) {
        if (_hydrated) return;
        _hydrated = true;
        final saved = prefs.getThemeMode();
        if (saved != state) state = saved;
      });
    });

    // Sync read in case prefs already resolved (warm reload). Setting
    // _hydrated here prevents the listener from re-applying on first emit.
    final prefs = ref.read(preferencesProvider).valueOrNull;
    if (prefs != null) {
      _hydrated = true;
      return prefs.getThemeMode();
    }
    return ThemeMode.system;
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    final prefs = await ref.read(preferencesProvider.future);
    await prefs.setThemeMode(mode);
  }

  Future<void> toggle() async {
    final next = switch (state) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    };
    await setMode(next);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);
