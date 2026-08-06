import 'package:flutter/widgets.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:hive/hive.dart';

/// On-device chat translation.
///
/// Messages are end-to-end encrypted, so translation has to happen on the
/// receiver's phone after decryption — plaintext must never reach a server.
/// ML Kit runs fully offline (one ~30MB model download per language) and is
/// free at any volume.
class TranslationService {
  static final TranslationService _instance = TranslationService._internal();
  factory TranslationService() => _instance;
  TranslationService._internal();

  static const String boxName = 'translation_cache';

  final LanguageIdentifier _identifier =
      LanguageIdentifier(confidenceThreshold: 0.5);
  final OnDeviceTranslatorModelManager _models =
      OnDeviceTranslatorModelManager();
  final Map<String, OnDeviceTranslator> _translators = {};

  Box get _box => Hive.box(boxName);

  /// The user's chosen app language, kept in sync by `LocaleNotifier`.
  /// Null means "follow the device".
  static String? appLanguageCode;

  /// The language we translate *into* — the app UI language, falling back to
  /// the device language when the user hasn't picked one.
  TranslateLanguage? get deviceLanguage => BCP47Code.fromRawValue(
        appLanguageCode ??
            WidgetsBinding.instance.platformDispatcher.locale.languageCode,
      );

  static String cacheKey(String messageId, TranslateLanguage target) =>
      '$messageId:${target.bcpCode}';

  String? cached(String messageId, TranslateLanguage target) =>
      _box.get(cacheKey(messageId, target)) as String?;

  /// Translates [text] into the device language.
  ///
  /// Returns null when the text is already in the device language, when the
  /// source language can't be identified, or when either language isn't
  /// supported by ML Kit. Throws if a model download fails.
  Future<String?> translate(String messageId, String text) async {
    final target = deviceLanguage;
    if (target == null || text.trim().isEmpty) return null;

    final hit = cached(messageId, target);
    if (hit != null) return hit;

    final rawSource = await _identifier.identifyLanguage(text);
    if (rawSource == 'und') return null;
    final source = BCP47Code.fromRawValue(rawSource);
    if (source == null || source == target) return null;

    for (final lang in [source, target]) {
      if (!await _models.isModelDownloaded(lang.bcpCode)) {
        // ponytail: blocks the tap on first use of a language. Add a progress
        // sheet if users start reporting the button feels dead.
        await _models.downloadModel(lang.bcpCode);
      }
    }

    final key = '${source.bcpCode}>${target.bcpCode}';
    final translator = _translators[key] ??= OnDeviceTranslator(
      sourceLanguage: source,
      targetLanguage: target,
    );

    final result = await translator.translateText(text);
    await _box.put(cacheKey(messageId, target), result);
    return result;
  }

  Future<void> dispose() async {
    await _identifier.close();
    for (final t in _translators.values) {
      await t.close();
    }
    _translators.clear();
  }
}
