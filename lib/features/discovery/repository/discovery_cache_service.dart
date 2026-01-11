import 'package:hive_flutter/hive_flutter.dart';
import '../domain/models/discovery_user_model.dart'; // Ensure this path is correct

class DiscoveryCacheService {
  static const String _boxName = 'discovery_cache';
  static const String _usersKey = 'cached_users';
  static const String _verificationKey = 'is_verified_status';
  static const String _myProfileKey = 'my_own_profile_data';

  // 1. Initialize the Database
  Future<void> init() async {
    await Hive.initFlutter();

    // Register the Adapter (Generated code)
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(DiscoveryUserAdapter());
    }

    // Open the box
    await Hive.openBox(_boxName);
  }

  // Helper to get the open box
  Box get _box => Hive.box(_boxName);

  // ---------------------------------------------------
  // 📦 1. DISCOVERY USERS (Feed)
  // ---------------------------------------------------

  // ✅ Method 1: saveUsers
  Future<void> saveUsers(List<DiscoveryUser> users) async {
    await _box.put(_usersKey, users);
    // print('📦 CACHE: Saved ${users.length} profiles.');
  }

  // ✅ Method 2: getUsers
  List<DiscoveryUser> getUsers() {
    final dynamic data = _box.get(_usersKey);
    if (data != null && data is List) {
      // Cast the dynamic list back to strict DiscoveryUser list
      return data.cast<DiscoveryUser>();
    }
    return [];
  }

  // ---------------------------------------------------
  // 🔒 2. VERIFICATION STATUS
  // ---------------------------------------------------

  // ✅ Method 3: saveVerificationStatus
  Future<void> saveVerificationStatus(bool isVerified) async {
    await _box.put(_verificationKey, isVerified);
  }

  // ✅ Method 4: getVerificationStatus
  bool getVerificationStatus() {
    return _box.get(_verificationKey, defaultValue: false);
  }

  // ---------------------------------------------------
  // 👤 3. MY PROFILE (For Offline Checks)
  // ---------------------------------------------------

  // ✅ Method 5: saveMyProfile
  Future<void> saveMyProfile(Map<String, dynamic> profileData) async {
    await _box.put(_myProfileKey, profileData);
  }

  // ✅ Method 6: getMyProfile
  Map<String, dynamic>? getMyProfile() {
    final data = _box.get(_myProfileKey);
    if (data != null) {
      return Map<String, dynamic>.from(data);
    }
    return null;
  }
}
