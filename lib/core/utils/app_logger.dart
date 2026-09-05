import 'package:flutter/foundation.dart';

class AppLogger {
  /// Release builds are silent unless built with --dart-define=VERBOSE=true,
  /// which is how you get logs out of a tester APK.
  static const _on = kDebugMode || bool.fromEnvironment('VERBOSE');

  static void logScreenRender(String screenName) {
    if (_on) {
      print('📱 SCREEN RENDER: $screenName');
    }
  }

  static void info(String message) {
    if (_on) {
      print('ℹ️ INFO: $message');
    }
  }

  static void warning(String message) {
    if (_on) {
      print('⚠️ WARNING: $message');
    }
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (_on) {
      print('❌ ERROR: $message');
      if (error != null) print('   Detail: $error');
      if (stackTrace != null) print(stackTrace);
    }
  }
}
