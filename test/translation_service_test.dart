import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:blindly_dating_app/core/services/translation_service.dart';

void main() {
  test('cache keys are per message AND per target language', () {
    final en = TranslationService.cacheKey('msg-1', TranslateLanguage.english);
    final es = TranslationService.cacheKey('msg-1', TranslateLanguage.spanish);
    final other =
        TranslationService.cacheKey('msg-2', TranslateLanguage.english);

    expect(en, isNot(es), reason: 'same message, different target must differ');
    expect(en, isNot(other), reason: 'different messages must differ');
    expect(en, TranslationService.cacheKey('msg-1', TranslateLanguage.english));
  });

  test('device locale codes map to ML Kit languages', () {
    expect(BCP47Code.fromRawValue('es'), TranslateLanguage.spanish);
    expect(BCP47Code.fromRawValue('zz'), isNull);
  });
}
