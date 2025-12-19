import 'package:flutter/foundation.dart';

class AppLogger {
  static void logScreenRender(String screenName) {
    if (kDebugMode) {
      print('📱 SCREEN RENDER: $screenName');
    }
  }

  static void info(String message) {
    if (kDebugMode) {
      print('ℹ️ INFO: $message');
    }
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('❌ ERROR: $message');
      if (error != null) print('   Detail: $error');
      if (stackTrace != null) print(stackTrace);
    }
  }
}
