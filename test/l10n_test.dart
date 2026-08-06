import 'dart:convert';
import 'dart:io';

import 'package:blindly_dating_app/core/providers/locale_provider.dart';
import 'package:blindly_dating_app/core/utils/vocab.dart';
import 'package:blindly_dating_app/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Set<String> _keys(String locale) {
  final json =
      jsonDecode(File('lib/l10n/app_$locale.arb').readAsStringSync()) as Map;
  return json.keys.where((k) => !k.startsWith('@')).cast<String>().toSet();
}

void main() {
  test('every shipped language translates every key', () {
    final expected = _keys('en');
    for (final code in appLanguages.keys.where((c) => c != 'en')) {
      expect(_keys(code), expected, reason: 'app_$code.arb is out of sync');
    }
  });

  test('vocabLabel translates known values and passes through the rest',
      () async {
    final hi = await AppLocalizations.delegate.load(const Locale('hi'));
    final en = await AppLocalizations.delegate.load(const Locale('en'));

    // Stored values are canonical English; only the label changes.
    expect(vocabLabel(hi, 'Hindu'), isNot('Hindu'));
    expect(vocabLabel(hi, 'Non-smoker'), isNot('Non-smoker'));
    expect(vocabLabel(en, 'Hindu'), 'Hindu');

    // DB-driven interest chips and free text fall through untouched.
    expect(vocabLabel(hi, 'Rock climbing'), 'Rock climbing');
    expect(vocabLabel(hi, ''), '');
  });

  test('chosen locale persists and drives chat translation target', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    expect(container.read(localeProvider), isNull);

    await container.read(localeProvider.notifier).set(const Locale('ta'));
    expect(container.read(localeProvider), const Locale('ta'));

    // A fresh container (app restart) reads it back.
    final restarted = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(restarted.dispose);
    expect(restarted.read(localeProvider), const Locale('ta'));
  });
}
