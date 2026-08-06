import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

/// On-device profanity/slur gate for outgoing chat messages.
///
/// Messages are end-to-end encrypted, so the server never sees plaintext and
/// cannot enforce anything. This runs on the sender's device before encryption.
/// It is a deterrent, not a wall — a patched client bypasses it. Contextual
/// abuse with no listed word also sails through; the receiver's report flow is
/// the answer to both, not a longer list.
///
/// Word list: LDNOOBW (CC-BY-4.0), 11 languages.
class TextModerationService {
  static final TextModerationService _instance =
      TextModerationService._internal();
  factory TextModerationService() => _instance;
  TextModerationService._internal();

  static const String assetPath = 'assets/moderation/bad_words.json';

  /// Single-word terms — matched against whole tokens only, so "classic" and
  /// "Scunthorpe" don't trip the "ass"/"cunt" entries.
  final Set<String> _tokens = {};

  /// Terms long enough that a substring match can't plausibly be innocent.
  /// Catches run-together evasion. Shorter terms are deliberately excluded:
  /// substring-matching them blocks "analysis" (anal) and "Scunthorpe" (cunt),
  /// and a false accusation costs more than a missed "fuckyou".
  final List<String> _longTerms = [];

  /// Multi-word entries ("son of a bitch"), matched as padded phrases.
  final List<String> _phrases = [];

  bool get isLoaded => _tokens.isNotEmpty;

  Future<void> load() async {
    if (isLoaded) return;
    final raw = json.decode(await rootBundle.loadString(assetPath)) as List;
    for (final entry in raw) {
      final term = normalize(entry as String);
      if (term.isEmpty) continue;
      if (term.contains(' ')) {
        _phrases.add(term);
      } else {
        _tokens.add(term);
        if (term.length >= 6) _longTerms.add(term);
      }
    }
  }

  static const Map<String, String> _substitutions = {
    '4': 'a', '@': 'a', '3': 'e', '1': 'i', '!': 'i', '|': 'i',
    '0': 'o', '5': 's', '\$': 's', '7': 't', '+': 't', '8': 'b',
  };

  static const Map<String, String> _diacritics = {
    'á': 'a', 'à': 'a', 'â': 'a', 'ä': 'a', 'ã': 'a', 'å': 'a',
    'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
    'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i',
    'ó': 'o', 'ò': 'o', 'ô': 'o', 'ö': 'o', 'õ': 'o',
    'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u',
    'ñ': 'n', 'ç': 'c', 'ý': 'y', 'ÿ': 'y', 'ß': 'ss',
  };

  /// Folds the evasion tricks that a plain `contains()` misses: casing,
  /// accents, leetspeak, letter-spacing ("f.u.c.k") and stretched letters
  /// ("fuuuuck"). Applied identically to the word list and the message so both
  /// sides land in the same space.
  static String normalize(String input) {
    final buffer = StringBuffer();
    for (final char in input.toLowerCase().split('')) {
      final folded = _diacritics[char] ?? _substitutions[char] ?? char;
      // Keep letters/digits from any script (Devanagari, Arabic, Cyrillic) and
      // spaces; drop the punctuation used to break words up.
      if (folded == ' ' || RegExp(r'[\p{L}\p{N}]', unicode: true).hasMatch(folded)) {
        buffer.write(folded);
      }
    }

    // Collapse runs of 3+ identical characters to one. Stops at 3 so real
    // double letters ("ass", "pussy") survive and stay distinct from "as".
    final collapsed = buffer.toString().replaceAllMapped(
          RegExp(r'(.)\1{2,}'),
          (m) => m.group(1)!,
        );

    return collapsed.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Returns the offending term, or null if the message is clean.
  /// Call [load] first; an unloaded service allows everything through.
  String? check(String text) {
    final normalized = normalize(text);
    if (normalized.isEmpty) return null;

    for (final token in normalized.split(' ')) {
      if (_tokens.contains(token)) return token;
    }

    // ponytail: linear scan over ~800 long terms per send. Fine at message
    // length; swap for a trie if it ever shows up in a frame budget.
    for (final term in _longTerms) {
      if (normalized.contains(term)) return term;
    }

    final padded = ' $normalized ';
    for (final phrase in _phrases) {
      if (padded.contains(' $phrase ')) return phrase;
    }

    return null;
  }
}
