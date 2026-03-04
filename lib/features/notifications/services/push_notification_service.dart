import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

class PushNotificationService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  /// Initializes push notifications, requests permissions, and saves the token to Supabase.
  Future<void> initPushNotifications(BuildContext context) async {
    // 1. Request permissions from the user
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      debugPrint('User declined or has not accepted permission');
      return;
    }

    // 2. Get the FCM Token
    String? token = await _fcm.getToken();
    if (token != null) {
      await _saveTokenToDatabase(token);
    }

    // 3. Listen to Token Refreshes
    _fcm.onTokenRefresh.listen(_saveTokenToDatabase);

    // 4. Handle Foreground Messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint(
        'Received a message while in foreground: ${message.messageId}',
      );
      // Optionally show a local notification / snackbar here
    });

    // 5. Handle Background/Terminated Notification Taps (Deep Linking)
    _handleInteraction(context);
  }

  /// Saves the FCM token to the Supabase `user_push_tokens` table.
  Future<void> _saveTokenToDatabase(String token) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      // 1. Get the profile_id for this authenticated user
      final profileResponse = await _supabase
          .from('profiles')
          .select('id')
          .eq('user_id', userId)
          .single();

      final profileId = profileResponse['id'] as String;

      // 2. Upsert the device token associated with their profile
      await _supabase.from('user_push_tokens').upsert({
        'profile_id': profileId,
        'token': token,
        'platform': _getPlatform(), // 'ios' or 'android'
        'last_used_at': DateTime.now().toUtc().toIso8601String(),
      });
      debugPrint('FCM Token saved to Supabase');
    } catch (e) {
      debugPrint('Error saving FCM Token: $e');
    }
  }

  /// Helper to get the current platform string for the database
  String _getPlatform() {
    // For simplicity, imported dart:io can provide Platform.isIOS / Platform.isAndroid
    return 'android'; // Defaulting to android for this implementation
  }

  Future<void> _handleInteraction(BuildContext context) async {
    // When the app opens from a terminated state
    RemoteMessage? initialMessage = await FirebaseMessaging.instance
        .getInitialMessage();
    if (initialMessage != null) {
      _handleDeepLink(context, initialMessage);
    }

    // When the app is backgrounded and the user taps the notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleDeepLink(context, message);
    });
  }

  void _handleDeepLink(BuildContext context, RemoteMessage message) {
    if (message.data.containsKey('route')) {
      final route = message.data['route'];
      Navigator.pushNamed(context, route);
    }
  }
}

/// A top-level function required by Firebase to handle background messages
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Handling a background message: ${message.messageId}");
}
