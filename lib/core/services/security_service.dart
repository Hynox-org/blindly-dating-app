import 'package:safe_device/safe_device.dart';

class SecurityService {
  /// Returns [true] if the device is SAFE (Not Rooted).
  /// Returns [false] if the device is Rooted/Jailbroken.
  Future<bool> get isDeviceSafe async {
    try {
      // 1. Check if device is Jailbroken/Rooted
      bool isJailBroken = await SafeDevice.isJailBroken;
      
      // 2. Check if running on a real device (optional, but good for security)
      // bool isRealDevice = await SafeDevice.isRealDevice;

      // If Jailbroken -> Device is NOT Safe
      if (isJailBroken) {
        print("🚨 SECURITY ALERT: Rooted Device Detected!");
        return false; 
      }
      
      return true; // Safe
    } catch (e) {
      // If the check fails (e.g., weird Android version), 
      // we usually "Fail Open" (Allow access) to prevent blocking innocent users.
      print("⚠️ Security Check Failed: $e");
      return true; 
    }
  }
}