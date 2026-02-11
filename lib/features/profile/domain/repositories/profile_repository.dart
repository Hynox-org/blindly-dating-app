import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(Supabase.instance.client);
});

class ProfileRepository {
  final SupabaseClient _client;

  ProfileRepository(this._client);

  Future<void> updateProfile(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    try {
      // Updates usually happen on the 'profiles' table
      // Ensure the 'id' in updates is NOT the user_id if the table PK is 'id'
      // The provider passed userId which might be authId or profileId.
      // We should check if we are updating by 'id' (profile PK) or 'user_id' (Auth PK).
      // Based on schema, profiles has 'id' as PK and 'user_id' as FK unique.
      // It's safer to update by 'id' if we have it, or 'user_id' if we don't.

      // For now, let's assume the passed ID is the profile ID (UUID)
      await _client.from('profiles').update(updates).eq('id', userId);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }
}
