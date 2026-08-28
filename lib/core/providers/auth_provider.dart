import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provides the current authenticated user, updating automatically on auth changes.
final currentUserProvider = StreamProvider<User?>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange.map((event) {
    return event.session?.user;
  });
});

/// Provides the current user ID, or null if not logged in.
final currentUserIdProvider = Provider<String?>((ref) {
  final userAsync = ref.watch(currentUserProvider);
  return userAsync.when(
    data: (user) => user?.id,
    loading: () => Supabase.instance.client.auth.currentUser?.id, // Optimistic
    error: (_, _) => null,
  );
});
