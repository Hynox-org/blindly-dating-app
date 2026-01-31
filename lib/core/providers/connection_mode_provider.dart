import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/discovery/repository/discovery_repository.dart';

class ConnectionModeNotifier extends StateNotifier<String> {
  final DiscoveryRepository _repository;

  ConnectionModeNotifier(this._repository) : super('Date');

  void setMode(String mode) {
    state = mode;
    // Fire and forget
    _repository.ensureProfileMode(mode);
  }

  Future<void> syncWithDb() async {
    // Sync current state
    await _repository.ensureProfileMode(state);
  }
}

final connectionModeProvider =
    StateNotifierProvider<ConnectionModeNotifier, String>((ref) {
      final repository = ref.watch(discoveryRepositoryProvider);
      return ConnectionModeNotifier(repository);
    });
