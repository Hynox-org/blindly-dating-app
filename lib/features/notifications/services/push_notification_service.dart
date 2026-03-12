import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:blindly_dating_app/core/utils/nav_key.dart';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PushNotificationService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Notification for the UI to show the 'Sign Out Other Devices' card
  static final ValueNotifier<String?> multiDeviceConflictToken = ValueNotifier(null);

  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // name
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
  );

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

    // Set Presentation Options for iOS in Foreground
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Initialize Local Notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _localNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          try {
            final Map<String, dynamic> data = json.decode(response.payload!);
            final context = navigatorKey.currentContext;
            if (context != null) {
              _handleDataPayload(context, data);
            }
          } catch (e) {
            debugPrint('Error parsing notification payload: $e');
          }
        }
      },
    );

    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    // 4. Handle Foreground Messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint(
        'Received a message while in foreground: ${message.messageId}',
      );
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      // Show local notification
      if (notification != null && android != null) {
        _localNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: '@mipmap/launcher_icon',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
          payload: json.encode(message.data),
        );
      }
    });

    // 5. Handle Background/Terminated Notification Taps (Deep Linking)
    _handleInteraction(context);
  }

  /// Saves the FCM token to the Supabase `user_push_tokens` table.
  Future<void> _saveTokenToDatabase(String token) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      // Use the RPC to handle RLS and shared device conflicts
      final response = await _supabase.rpc('register_fcm_token', params: {
        'p_token': token,
        'p_platform': _getPlatform(),
      });

      if (response != null && response['success'] == true) {
        if (response['conflict'] == true) {
          debugPrint('⚠️ Multi-device detected for this user.');
          multiDeviceConflictToken.value = token;
        } else {
          multiDeviceConflictToken.value = null; // Clear if no conflict
        }
        debugPrint('FCM Token registered via RPC');
      } else {
        debugPrint('Failed to register FCM Token: ${response?['error']}');
      }
    } catch (e) {
      debugPrint('Error saving FCM Token via RPC: $e');
    }
  }

  /// Clears other tokens for this profile, enforcing single-device login
  Future<bool> clearOtherDevices(String keepToken) async {
    try {
      final response = await _supabase.rpc('clear_other_fcm_tokens', params: {
        'p_keep_token': keepToken,
      });

      if (response != null && response['success'] == true) {
        multiDeviceConflictToken.value = null; // Clear conflict state
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error clearing other devices: $e');
      return false;
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

  void _handleDeepLink(BuildContext context, RemoteMessage message) async {
    _handleDataPayload(context, message.data);
  }

  void _handleDataPayload(
    BuildContext context,
    Map<String, dynamic> data,
  ) async {
    // 1. Mark notification as read if we received its ID
    if (data.containsKey('notification_id')) {
      final notificationId = data['notification_id'] as String;
      final userId = _supabase.auth.currentUser?.id;

      if (userId != null && notificationId.isNotEmpty) {
        try {
          // Dynamic import or provide access if needed,
          // but we can just use Supabase direct or NotificationDbService
          // We will use direct update since NotificationDbService fetches profileId first usually.
          // To keep it clean, let's use the same method. We need to import NotificationDbService.

          // Actually, since NotificationDbService requires a quick profile lookup, doing it here is fine:
          print('Push clicked: Marking notification $notificationId as read.');

          final profileResponse = await _supabase
              .from('profiles')
              .select('id')
              .eq('user_id', userId)
              .single();

          final profileId = profileResponse['id'] as String;

          await _supabase
              .from('notifications')
              .update({
                'is_read': true,
                'read_at': DateTime.now().toUtc().toIso8601String(),
              })
              .eq('id', notificationId)
              .eq('profile_id', profileId);
        } catch (e) {
          debugPrint('Error marking push notification as read: $e');
        }
      }
    }

    // 2. Handle routing navigate
    if (data.containsKey('route')) {
      final route = data['route'];
      if (context.mounted) {
        Navigator.pushNamed(context, route);
      }
    }
  }
}

/// A top-level function required by Firebase to handle background messages
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Handling a background message: ${message.messageId}");
}
