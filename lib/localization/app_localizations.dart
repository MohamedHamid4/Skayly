import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'strings_ar.dart';
import 'strings_en.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static const supportedLocales = [Locale('en'), Locale('ar')];

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('en'));
  }

  Map<String, String> get _strings {
    switch (locale.languageCode) {
      case 'ar':
        return arStrings;
      case 'en':
      default:
        return enStrings;
    }
  }

  /// Look up a localized string by [key], with optional `{name}` interpolation.
  /// Falls back to English, then to the key itself if missing.
  String t(String key, [Map<String, String> args = const {}]) {
    var value = _strings[key] ?? enStrings[key] ?? key;
    args.forEach((k, v) {
      value = value.replaceAll('{$k}', v);
    });
    return value;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      const ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) =>
      SynchronousFuture(AppLocalizations(locale));

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
