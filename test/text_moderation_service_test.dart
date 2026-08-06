import 'package:flutter_test/flutter_test.dart';
import 'package:blindly_dating_app/core/services/text_moderation_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final service = TextModerationService();

  setUpAll(() async {
    await service.load();
  });

  test('normalizer folds the common evasion tricks', () {
    const n = TextModerationService.normalize;
    expect(n('F.U.C.K'), 'fuck', reason: 'letter separators');
    expect(n('fuuuuck'), 'fuck', reason: 'stretched letters');
    expect(n('f4ck'), 'fack', reason: 'leetspeak digits');
    expect(n('CAFÉ'), 'cafe', reason: 'diacritics');
    expect(n('  hey   there '), 'hey there', reason: 'whitespace');
    expect(n('ass'), 'ass', reason: 'real doubles survive, not folded to "as"');
  });

  test('blocks obvious profanity, including evaded spellings', () {
    expect(service.check('you are a fucking idiot'), isNotNull);
    expect(service.check('f.u.c.k you'), isNotNull);
    expect(service.check('fuuuuuck this'), isNotNull);
    expect(service.check('FUCK'), isNotNull);
    expect(service.check('youarebeingabastard'), isNotNull,
        reason: 'run-together evasion, term >= 6 chars');
  });

  test('known gap: run-together evasion with short terms', () {
    // "fuck" is 4 chars, below the substring threshold, so "fuckyou" slips by.
    // Lowering the threshold would block "analysis" (anal) and "Scunthorpe"
    // (cunt). Falsely accusing users is worse than missing this; the report
    // flow is the backstop.
    expect(service.check('fuckyou'), isNull);
  });

  test('does not trip on innocent words containing bad substrings', () {
    // The Scunthorpe problem — the reason token matching exists.
    for (final clean in [
      'I grew up in Scunthorpe',
      'that is a classic film',
      'the assassin in that book',
      'lets meet at the bar tonight',
      'I love cooking pasta',
      'analysis of the data',
    ]) {
      expect(service.check(clean), isNull, reason: clean);
    }
  });

  test('clean and empty messages pass', () {
    expect(service.check('hey, how was your day?'), isNull);
    expect(service.check(''), isNull);
    expect(service.check('   '), isNull);
  });
}
