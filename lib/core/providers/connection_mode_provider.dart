import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/discovery/repository/discovery_repository.dart';

class ConnectionModeNotifier extends StateNotifier<String> {
  final DiscoveryRepository _repository;

  ConnectionModeNotifier(this._repository) : super('Date');

  void setMode(String mode) {
    state = mode;
  }

  Future<void> syncWithDb() async {
    // Ideally fetch from DB. For now, we trust the local default or last set
    // But if we wanted to support persistent "Events" mode, we'd fetch here.
  }
}

final connectionModeProvider =
    StateNotifierProvider<ConnectionModeNotifier, String>((ref) {
      final repository = ref.watch(discoveryRepositoryProvider);
      return ConnectionModeNotifier(repository);
    });
