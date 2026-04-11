import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';

class ChatCacheService {
  static final ChatCacheService _instance = ChatCacheService._internal();
  factory ChatCacheService() => _instance;
  ChatCacheService._internal();

  final String _boxName = 'chat_cache';

  Box get _box => Hive.box(_boxName);

  /// Retrieves cached messages for a specific match.
  /// Returns a list of raw message maps.
  List<Map<String, dynamic>> getMessages(String matchId) {
    try {
      final List? data = _box.get(matchId);
      if (data == null) return [];
      
      // Ensure we return a growable list of maps
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      debugPrint('Error getting cached messages: $e');
      return [];
    }
  }

  /// Saves or updates the message list for a match.
  /// Implements the 5-day eviction logic.
  Future<void> saveMessages(String matchId, List<Map<String, dynamic>> messageMaps) async {
    try {
      final now = DateTime.now();
      final fiveDaysAgo = now.subtract(const Duration(days: 5));

      // Filter messages to keep only the last 5 days
      final filteredMessages = messageMaps.where((msg) {
        final createdAtStr = msg['created_at'];
        if (createdAtStr == null) return false;
        try {
          final createdAt = DateTime.parse(createdAtStr);
          return createdAt.isAfter(fiveDaysAgo);
        } catch (_) {
          return true; // Keep if date is unparseable to be safe
        }
      }).toList();

      // Limit count if necessary (optional, but good for performance)
      // If we have thousands of messages in 5 days, maybe cap it? 
      // For now, 5 days is the strict rule.

      await _box.put(matchId, filteredMessages);
    } catch (e) {
      debugPrint('Error saving cached messages: $e');
    }
  }

  /// Updates or adds a single message to the cache.
  /// Useful for realtime updates.
  Future<void> updateSingleMessage(String matchId, Map<String, dynamic> messageMap) async {
    try {
      final messages = getMessages(matchId);
      
      final index = messages.indexWhere((m) => m['id'] == messageMap['id']);
      
      if (index != -1) {
        messages[index] = messageMap;
      } else {
        messages.add(messageMap);
      }
      
      // Sort by creation time to maintain order
      messages.sort((a, b) {
        final dateA = DateTime.parse(a['created_at'] ?? '');
        final dateB = DateTime.parse(b['created_at'] ?? '');
        return dateA.compareTo(dateB);
      });

      await saveMessages(matchId, messages);
    } catch (e) {
      debugPrint('Error updating single cached message: $e');
    }
  }

  /// Clears cache for a specific match
  Future<void> clearCache(String matchId) async {
    await _box.delete(matchId);
  }

  // ==============================
  // KEY CACHING
  // ==============================

  Box get _keyBox => Hive.box('match_keys');

  /// Saves the decrypted symmetric key for a match.
  Future<void> saveMatchKey(String matchId, String decryptedKey) async {
    try {
      await _keyBox.put(matchId, decryptedKey);
    } catch (e) {
      debugPrint('Error saving match key: $e');
    }
  }

  /// Retrieves the decrypted symmetric key for a match.
  String? getMatchKey(String matchId) {
    try {
      return _keyBox.get(matchId);
    } catch (e) {
      debugPrint('Error getting match key: $e');
      return null;
    }
  }

  /// Clears all cached symmetric keys.
  Future<void> clearAllMatchKeys() async {
    await _keyBox.clear();
  }

  /// Clears cache for all matches.
  Future<void> clearAllMessages() async {
    await _box.clear();
  }
}
