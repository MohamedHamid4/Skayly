// Round 4: strengthened to also verify MaterialApp.themeMode reflects the
// provider, and that the theme cycles system → light → dark → system.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:skyly_app/core/errors/failures.dart';
import 'package:skyly_app/main.dart';
import 'package:skyly_app/providers/locale_provider.dart';
import 'package:skyly_app/providers/theme_provider.dart';
import 'package:skyly_app/providers/weather_provider.dart';

class _StubWeatherNotifier extends WeatherNotifier {
  @override
  Future<WeatherState> build() async {
    // Force home into the error branch — _TopBar still renders above it.
    throw const NetworkFailure();
  }
}

Widget _harness() {
  return ProviderScope(
    overrides: [
      weatherProvider.overrideWith(_StubWeatherNotifier.new),
    ],
    // SkylyApp wires themeMode + locale into MaterialApp end-to-end, which
    // is what we need to verify the rebuild path — not just provider state.
    child: const SkylyApp(),
  );
}

const _themeIcons = [
  Icons.brightness_auto_outlined,
  Icons.light_mode_outlined,
  Icons.dark_mode_outlined,
];

Finder _findThemeIcon() {
  for (final icon in _themeIcons) {
    final f = find.byIcon(icon);
    if (f.evaluate().isNotEmpty) return f;
  }
  throw StateError('No theme icon found in top bar');
}

Future<void> _tapThemeIcon(WidgetTester tester) async {
  await tester.tap(_findThemeIcon());
  await tester.pumpAndSettle();
}

ProviderContainer _container(WidgetTester tester) {
  return ProviderScope.containerOf(
    tester.element(find.byType(MaterialApp)),
  );
}

MaterialApp _materialApp(WidgetTester tester) {
  return tester.widget<MaterialApp>(find.byType(MaterialApp));
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Icons.translate → only locale changes', (tester) async {
    await tester.pumpWidget(_harness());
    await tester.pumpAndSettle();

    final translate = find.byIcon(Icons.translate);
    expect(translate, findsOneWidget);

    final container = _container(tester);
    final localeBefore = container.read(localeProvider);
    final themeBefore = container.read(themeModeProvider);

    await tester.tap(translate);
    await tester.pumpAndSettle();

    expect(
      container.read(localeProvider),
      isNot(equals(localeBefore)),
      reason: 'Tapping Icons.translate must change the locale',
    );
    expect(
      container.read(themeModeProvider),
      equals(themeBefore),
      reason: 'Tapping Icons.translate must NOT change the theme',
    );
  });

  testWidgets(
    'theme glyph → theme changes AND MaterialApp.themeMode reflects it',
    (tester) async {
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      final container = _container(tester);
      final themeBefore = container.read(themeModeProvider);
      final localeBefore = container.read(localeProvider);

      // Sanity: MaterialApp already mirrors provider state pre-tap.
      expect(_materialApp(tester).themeMode, themeBefore);

      await _tapThemeIcon(tester);

      final themeAfter = container.read(themeModeProvider);
      expect(themeAfter, isNot(equals(themeBefore)));
      expect(container.read(localeProvider), equals(localeBefore));

      // The actual rebuild path: provider → MaterialApp.themeMode.
      expect(
        _materialApp(tester).themeMode,
        themeAfter,
        reason: 'MaterialApp.themeMode must reflect the new provider state',
      );
    },
  );

  testWidgets(
    'theme cycles: system → light → dark → system',
    (tester) async {
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      final container = _container(tester);
      expect(container.read(themeModeProvider), ThemeMode.system);

      await _tapThemeIcon(tester);
      expect(container.read(themeModeProvider), ThemeMode.light);
      expect(_materialApp(tester).themeMode, ThemeMode.light);

      await _tapThemeIcon(tester);
      expect(container.read(themeModeProvider), ThemeMode.dark);
      expect(_materialApp(tester).themeMode, ThemeMode.dark);

      await _tapThemeIcon(tester);
      expect(container.read(themeModeProvider), ThemeMode.system);
      expect(_materialApp(tester).themeMode, ThemeMode.system);
    },
  );
}
