import 'package:safe_device/safe_device.dart';
import 'package:flutter/services.dart';
import '../utils/app_logger.dart';

class DeviceSecurity {
  /// Checks if the device is rooted or jailbroken.
  static Future<bool> isDeviceCompromised() async {
    try {
      bool jailbroken = await SafeDevice.isJailBroken;

      if (jailbroken) {
        AppLogger.warning('SECURITY ALERT: Device is rooted/jailbroken.');
        return true;
      }
      return false;
    } on PlatformException catch (e) {
      AppLogger.error(
        'SECURITY ERROR: Failed to check device security status',
        e,
      );
      // Fail open (allow access) or closed (deny access)?
      // Usually fail open to prevent blocking users due to platform bugs,
      // but log it.
      return false;
    }
  }
}
