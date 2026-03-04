import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';

class NotificationDbService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Helper to get profileId from userId
  Future<String> _getProfileId(String userId) async {
    final profileResponse = await _supabase
        .from('profiles')
        .select('id')
        .eq('user_id', userId)
        .single();
    return profileResponse['id'] as String;
  }

  /// Fetches a user's notifications, ordered by creation date
  Future<List<AppNotification>> fetchNotifications(String userId) async {
    final profileId = await _getProfileId(userId);
    final response = await _supabase
        .from('notifications')
        .select()
        .eq('profile_id', profileId)
        .order('created_at', ascending: false);

    return (response as List<dynamic>)
        .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Streams a user's notifications for real-time updates
  Stream<List<AppNotification>> streamNotifications(String userId) async* {
    final profileId = await _getProfileId(userId);
    yield* _supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('profile_id', profileId)
        .order('created_at', ascending: false)
        .map((event) => event.map((e) => AppNotification.fromJson(e)).toList());
  }

  /// Marks a specific notification as read
  Future<void> markAsRead(String notificationId, String userId) async {
    final profileId = await _getProfileId(userId);
    await _supabase
        .from('notifications')
        .update({
          'is_read': true,
          'read_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', notificationId)
        .eq('profile_id', profileId);
  }

  /// Checks if there are any unread notifications
  Future<bool> hasUnread(String userId) async {
    final profileId = await _getProfileId(userId);
    final response = await _supabase
        .from('notifications')
        .select('id')
        .eq('profile_id', profileId)
        .eq('is_read', false)
        .limit(1);

    return (response as List).isNotEmpty;
  }
}
