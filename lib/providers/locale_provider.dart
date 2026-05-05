import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/preferences_service.dart';
import 'service_providers.dart';

class LocaleNotifier extends Notifier<Locale?> {
  bool _hydrated = false;

  @override
  Locale? build() {
    // Same hydrate-once contract as ThemeModeNotifier.
    ref.listen<AsyncValue<PreferencesService>>(preferencesProvider, (
      prev,
      next,
    ) {
      next.whenData((prefs) {
        if (_hydrated) return;
        _hydrated = true;
        final saved = prefs.getLocale();
        if (saved != state) state = saved;
      });
    });

    final prefs = ref.read(preferencesProvider).valueOrNull;
    if (prefs != null) {
      _hydrated = true;
      return prefs.getLocale();
    }
    return null;
  }

  Future<void> setLocale(Locale? locale) async {
    state = locale;
    final prefs = await ref.read(preferencesProvider.future);
    await prefs.setLocale(locale);
  }

  Future<void> toggleEnglishArabic() async {
    final next = state?.languageCode == 'ar'
        ? const Locale('en')
        : const Locale('ar');
    await setLocale(next);
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale?>(
  LocaleNotifier.new,
);
