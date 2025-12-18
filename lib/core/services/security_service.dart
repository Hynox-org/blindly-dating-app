import 'dart:io';
import 'package:safe_device/safe_device.dart';

class SecurityService {
  
  /// Checks if the device is safe to run the app.
  /// Returns [true] if the device is SAFE.
  /// Returns [false] if the device is ROOTED, JAILBROKEN, or an EMULATOR.
  Future<bool> isDeviceSafe() async {
    try {
      // 1. Check if Jailbroken (iOS) or Rooted (Android)
      bool isJailbroken = await SafeDevice.isJailBroken;
      
      // 2. Check if it's a Real Device (Optional: Block Emulators)
      // We usually allow emulators during dev, but block in production.
      bool isRealDevice = await SafeDevice.isRealDevice;

      // Development Mode Override:
      // If you are testing on an Emulator, you might want to return 'true' here temporarily.
      // return true; 

      if (isJailbroken) {
        print("🚨 SECURITY ALERT: Device is Rooted/Jailbroken!");
        return false;
      }

      // Optional: Strict mode (Block Emulators too)
      // if (!isRealDevice) {
      //   print("🚨 SECURITY ALERT: App running on Emulator!");
      //   return false;
      // }

      return true;
    } catch (e) {
      print("Error checking device security: $e");
      // Default to safe if check fails to avoid blocking legitimate users on errors
      return true; 
    }
  }
}