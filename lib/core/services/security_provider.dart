import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/security_service.dart';

// 1. The Provider that holds the Service logic
final securityServiceProvider = Provider<SecurityService>((ref) {
  return SecurityService();
});

// 2. The FutureProvider that actually runs the check asynchronously
// UI will listen to THIS provider.
final deviceSafetyProvider = FutureProvider<bool>((ref) async {
  final securityService = ref.watch(securityServiceProvider);
  return await securityService.isDeviceSafe;
});