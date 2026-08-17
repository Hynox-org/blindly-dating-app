import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/discovery/repository/discovery_repository.dart';
import 'auth_provider.dart';

class ConnectionModeNotifier extends StateNotifier<String> {
  final DiscoveryRepository _repository;
  final String? _userId;

  ConnectionModeNotifier(this._repository, this._userId) : super('Date') {
    if (_userId != null) {
      _loadModeFromDb();
    }
  }

  Future<void> _loadModeFromDb() async {
    try {
      final dbMode = await _repository.fetchCurrentMode();
      // Same mode in different casing would still count as a change and take
      // every dependent provider (the deck included) down with it.
      if (dbMode.toLowerCase() != state.toLowerCase()) state = dbMode;
    } catch (e) {
      debugPrint('⚠️ Failed to load connection mode from DB: $e');
    }
  }

  Future<void> setMode(String mode) async {
    state = mode;
    
    // 1. Ensure DB row exists (legacy check for profiles_modes table)
    _repository.ensureProfileMode(mode);

    // 2. Update Source of Truth in Profiles table
    if (_userId != null) {
      _repository.updateCurrentMode(mode);
    }
  }

  Future<void> syncWithDb() async {
    // Sync current state
    await _repository.ensureProfileMode(state);
    if (_userId != null) {
      await _repository.updateCurrentMode(state);
    }
  }
}

final connectionModeProvider =
    StateNotifierProvider<ConnectionModeNotifier, String>((ref) {
      final repository = ref.watch(discoveryRepositoryProvider);
      final userId = ref.watch(currentUserIdProvider);
      return ConnectionModeNotifier(repository, userId);
    });
