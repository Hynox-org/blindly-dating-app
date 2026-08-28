import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:blindly_dating_app/core/utils/nav_key.dart';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:blindly_dating_app/features/chat/presentation/screens/chat_conversation_screen.dart';
// import '../../profile/domain/models/profile_user_model.dart';

class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  final SupabaseClient _supabase = Supabase.instance.client;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _hasInitialized = false;

  /// Signals to other screens (like SplashScreen) that a notification is currently
  /// handling navigation, so they should skip or delay their own redirects.
  bool isHandlingRedirect = false;

  /// Stores data from a notification that launched the app from a terminated state
  Map<String, dynamic>? _pendingLaunchData;

  /// Notification for the UI to show the 'Sign Out Other Devices' card
  static final ValueNotifier<String?> multiDeviceConflictToken = ValueNotifier(null);

  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // name
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
  );

  /// GRABS the launch notification immediately upon app start.
  /// This MUST be called as early as possible in main.dart.
  Future<void> captureLaunchNotification() async {
    debugPrint('🔍 [PNService] Aggressively checking for launch intents...');

    try {
      // 1. Check FCM Initial Message
      final initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('🚀 [PNService] Captured FCM Launch Message: ${initialMessage.messageId}');
        debugPrint('📦 [PNService] Launch Data: ${initialMessage.data}');
        _pendingLaunchData = initialMessage.data;
        isHandlingRedirect = true;
        return;
      }

      // 2. Check Local Notification Launch
      final launchDetails = await _localNotificationsPlugin.getNotificationAppLaunchDetails();
      if (launchDetails != null && launchDetails.didNotificationLaunchApp) {
        final payload = launchDetails.notificationResponse?.payload;
        if (payload != null) {
          debugPrint('🚀 [PNService] Captured Local Launch Payload: $payload');
          _pendingLaunchData = json.decode(payload);
          isHandlingRedirect = true;
        }
      }
    } catch (e) {
      debugPrint('🔔 [PNService] Error during early capture: $e');
    }
  }

  /// Initializes push notifications, requests permissions, and saves the token to Supabase.
  Future<void> initPushNotifications() async {
    if (_hasInitialized) return;
    _hasInitialized = true;

    debugPrint('🔔 [PNService] Starting Full Initialization...');

    // If we have pending data, start the navigation process immediately
    if (_pendingLaunchData != null) {
      debugPrint('🔔 [PNService] Found pre-captured launch data. Initiating routing now.');
      _handleDataPayload(_pendingLaunchData!);
      _pendingLaunchData = null; // Consume it
    } else {
      // If we didn't pre-capture, do a regular check just in case
      _handleInteraction();
    }

    // 2. Request permissions from the user
    debugPrint('🔔 [PNService] Requesting permissions...');
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      debugPrint('🔔 [PNService] User declined or has not accepted permission');
    }

    // 3. Get the FCM Token
    String? token = await _fcm.getToken();
    if (token != null) {
      await _saveTokenToDatabase(token);
    }

    // 4. Listen to Token Refreshes
    _fcm.onTokenRefresh.listen(_saveTokenToDatabase);

    // Set Presentation Options for iOS in Foreground
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 5. Initialize Local Notifications
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
            debugPrint('🔔 [PNService] Local Notification Tapped: ${response.payload}');
            final Map<String, dynamic> data = json.decode(response.payload!);
            _handleDataPayload(data);
          } catch (e) {
            debugPrint('🔔 [PNService] Error parsing notification payload: $e');
          }
        }
      },
    );

    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    // 6. Handle Incoming Messages (Foreground)
    _setupMessageListeners();
  }

  void _setupMessageListeners() {
    // Foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('📩 [PNService] Received message in foreground: ${message.messageId}');

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
  }


  /// Saves the FCM token to the Supabase `user_push_tokens` table.
  Future<void> _saveTokenToDatabase(String token) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final response = await _supabase.rpc('register_fcm_token', params: {
        'p_token': token,
        'p_platform': _getPlatform(),
      });

      if (response != null && response['success'] == true) {
        if (response['conflict'] == true) {
          debugPrint('⚠️ [PNService] Multi-device detected for this user.');
          multiDeviceConflictToken.value = token;
        } else {
          multiDeviceConflictToken.value = null; // Clear if no conflict
        }
        debugPrint('FCM Token registered via RPC');
      } else {
        debugPrint('🔔 [PNService] Failed to register FCM Token: ${response?['error']}');
      }
    } catch (e) {
      debugPrint('🔔 [PNService] Error saving FCM Token via RPC: $e');
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
      debugPrint('🔔 [PNService] Error clearing other devices: $e');
      return false;
    }
  }

  /// Helper to get the current platform string for the database
  String _getPlatform() {
    return 'android'; // Defaulting to android for this implementation
  }

  Future<void> _handleInteraction() async {
    debugPrint('🔔 [PNService] Checking for initial messages...');
    
    // 1. Check if the app was opened via an FCM notification (Terminated State)
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('🚀 [PNService] App launched via FCM initial message: ${initialMessage.messageId}');
      _handleDeepLink(initialMessage);
    }

    // 2. Check if the app was opened via a LOCAL notification (Terminated State)
    final NotificationAppLaunchDetails? launchDetails = 
        await _localNotificationsPlugin.getNotificationAppLaunchDetails();
    if (launchDetails != null && launchDetails.didNotificationLaunchApp) {
      final payload = launchDetails.notificationResponse?.payload;
      if (payload != null) {
        debugPrint('🚀 [PNService] App launched via Local Notification payload: $payload');
        try {
          final Map<String, dynamic> data = json.decode(payload);
          _handleDataPayload(data);
        } catch (e) {
          debugPrint('🔔 [PNService] Error parsing launch payload: $e');
        }
      }
    }

    // 3. Listen for notification taps while the app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('📩 [PNService] Notification tapped in background: ${message.messageId}');
      _handleDeepLink(message);
    });
  }

  void _handleDeepLink(RemoteMessage message) {
    debugPrint('🔔 [PNService] Handling Deep Link with data: ${message.data}');
    _handleDataPayload(message.data);
  }

  void _handleDataPayload(Map<String, dynamic> data) async {
    debugPrint('🔔 [PNService] Processing Payload Data: $data');

    // Signal that a redirect is in progress to prevent SplashScreen from interfering
    isHandlingRedirect = true;

    // 1. Mark notification as read if we received its ID
    if (data.containsKey('notification_id')) {
      final notificationId = data['notification_id'] as String;
      final userId = _supabase.auth.currentUser?.id;

      if (userId != null && notificationId.isNotEmpty) {
        _markNotificationAsRead(notificationId, userId);
      }
    }

    // 2. Handle Chat Deep Link (Explicit match_id)
    if (data.containsKey('match_id')) {
      final matchId = data['match_id'] as String;
      debugPrint('🔔 [PNService] Routing to Chat with matchId: $matchId');
      _waitForNavigatorAndNavigate((navState) => _handleChatNavigation(navState, matchId));
      return; 
    }

    // 3. Handle routing navigate (Legacy or Generic)
    if (data.containsKey('route')) {
      final route = data['route'] as String;
      debugPrint('🔔 [PNService] Generic route detected: $route');
      _waitForNavigatorAndNavigate((navState) {
          navState.pushNamed(route);
          // Only reset after a small delay to ensure UI has transitioned
          Future.delayed(const Duration(seconds: 2), () => isHandlingRedirect = false);
      });
    } else {
      // If we reach here and nothing was handled, reset the flag after a short delay
      Future.delayed(const Duration(seconds: 1), () => isHandlingRedirect = false);
    }
  }

  /// Helper to ensure navigator is ready before navigating
  void _waitForNavigatorAndNavigate(Function(NavigatorState) navigateAction) {
    if (navigatorKey.currentState != null) {
      debugPrint('🔔 [PNService] Navigator is ready. Executing action.');
      navigateAction(navigatorKey.currentState!);
    } else {
      debugPrint('⌛ [PNService] Navigator not ready, retrying in 500ms...');
      Future.delayed(const Duration(milliseconds: 500), () {
        _waitForNavigatorAndNavigate(navigateAction);
      });
    }
  }

  Future<void> _markNotificationAsRead(String notificationId, String userId) async {
    try {
      debugPrint('🔔 [PNService] Marking notification $notificationId as read.');

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
      debugPrint('🔔 [PNService] Error marking push notification as read: $e');
    }
  }

  /// Fetches necessary data and routes to the chat conversation screen
  Future<void> _handleChatNavigation(NavigatorState navState, String matchId) async {
    try {
      debugPrint('🔔 [PNService] Starting Chat Navigation for $matchId');

      // 🔥 Wait for Supabase Session if it's currently null (Startup latency)
      int retryCount = 0;
      while (_supabase.auth.currentUser == null && retryCount < 10) {
        debugPrint('⌛ [PNService] Waiting for Supabase Session (Attempt ${retryCount + 1})...');
        await Future.delayed(const Duration(milliseconds: 500));
        retryCount++;
      }

      final myUserId = _supabase.auth.currentUser?.id;
      if (myUserId == null) {
        debugPrint('🔔 [PNService] CRITICAL: No user session found after waiting. Aborting navigation.');
        isHandlingRedirect = false;
        return;
      }


      // 1. Get my profile ID
      final myProfileResponse = await _supabase
          .from('profiles')
          .select('id')
          .eq('user_id', myUserId)
          .single();
      final myProfileId = myProfileResponse['id'] as String;

      // 2. Get match details with profile data
      final matchResponse = await _supabase
          .from('matches')
          .select('*, user_a:profiles!matches_user_a_id_fkey(*), user_b:profiles!matches_user_b_id_fkey(*)')
          .eq('id', matchId)
          .single();

      final profileA = matchResponse['user_a'] as Map<String, dynamic>;
      final profileB = matchResponse['user_b'] as Map<String, dynamic>;

      final isUserA = matchResponse['user_a_id'] == myProfileId;
      final otherProfile = isUserA ? profileB : profileA;
      final otherProfileId = otherProfile['id'] as String;
      final otherName = otherProfile['display_name'] ?? 'Blindly User';

      // 3. Get other user's primary image from STORAGE
      String otherImage = '';
      final otherUserId = otherProfile['user_id'];

      if (otherUserId != null) {
        try {
          final files = await _supabase.storage
              .from('user_photos')
              .list(path: otherUserId);

          if (files.isNotEmpty) {
            final firstFile = files.first;
            otherImage = await _supabase.storage
                .from('user_photos')
                .createSignedUrl('$otherUserId/${firstFile.name}', 3600);
          }
        } catch (e) {
          debugPrint('PushNotificationService Storage Error: $e');
        }
      }

      if (otherImage.isEmpty) {
        otherImage = "https://ui-avatars.com/api/?name=${Uri.encodeComponent(otherName)}"
            "&size=128&background=4F46E5&color=fff";
      }

      // 4. Navigate
      navState.push(
        MaterialPageRoute(
          builder: (_) => ChatConversationScreen(
            matchId: matchId,
            otherUserName: otherName,
            otherUserImage: otherImage,
            myProfileId: myProfileId,
            otherProfileId: otherProfileId,
            name: otherName,
            imageUrl: otherImage,
          ),
        ),
      );

      // ✅ Navigation done, keep flag true for a bit longer to ensure SplashScreen doesn't overwrite
      debugPrint('🔔 [PNService] Chat Navigation SUCCESS. Keeping redirect flag for 3s.');
      await Future.delayed(const Duration(seconds: 3));
      isHandlingRedirect = false;
    } catch (e) {
      debugPrint('🔔 [PNService] ChatNavigation Error: $e');
      isHandlingRedirect = false;
    }
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Empty handler. Notifications are now tracked via the 'notifications' table trigger.
  debugPrint("🌙 Handling a background message: ${message.messageId}");
}
