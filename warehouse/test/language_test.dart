import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warehouse/data/local_store.dart';
import 'package:warehouse/state/language_config.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('LanguageConfig', () {
    test('opens in Khmer, not the phone locale', () {
      // The people using this are on a warehouse floor in Cambodia, and a
      // shared handset that happens to be in English must still be readable.
      expect(LanguageConfig().locale, LanguageConfig.khmer);
      expect(LanguageConfig().isKhmer, isTrue);
    });

    test('an explicit locale wins over the saved one', () async {
      await LanguageConfig(store: LocalStore()).setLocale(LanguageConfig.khmer);

      // What the tests rely on: passing English must not be overridden by
      // whatever the last run left on disk.
      final forced = LanguageConfig(
          store: LocalStore(), initial: LanguageConfig.english);

      expect(forced.locale, LanguageConfig.english);
    });

    test('the choice survives a restart', () async {
      await LanguageConfig(store: LocalStore())
          .setLocale(LanguageConfig.english);

      final restored = LanguageConfig(store: LocalStore());
      await Future<void>.delayed(Duration.zero);

      expect(restored.locale, LanguageConfig.english);
    });

    test('toggling goes both ways', () async {
      final config = LanguageConfig();

      await config.toggle();
      expect(config.locale, LanguageConfig.english);

      await config.toggle();
      expect(config.locale, LanguageConfig.khmer);
    });

    test('a language this build no longer ships falls back to Khmer', () async {
      SharedPreferences.setMockInitialValues({'flutter.wh_language_v1': 'fr'});

      final config = LanguageConfig(store: LocalStore());
      await Future<void>.delayed(Duration.zero);

      expect(config.locale, LanguageConfig.khmer,
          reason: 'better the default than a half-translated screen');
    });

    test('setting the same locale twice notifies once', () async {
      final config = LanguageConfig();
      var notifications = 0;
      config.addListener(() => notifications++);

      await config.setLocale(LanguageConfig.english);
      await config.setLocale(LanguageConfig.english);

      expect(notifications, 1);
    });

    test('ships exactly the two locales the ARB files cover', () {
      expect(LanguageConfig.supported,
          [const Locale('km'), const Locale('en')]);
    });
  });
}
