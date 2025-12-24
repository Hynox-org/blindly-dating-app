import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../data/location_repository.dart';

enum LocationServiceStatus {
  unknown,
  ready,
  requesting,
  denied,
  disabled,
  error,
}

class LocationState {
  final LocationServiceStatus status;
  final Position? lastKnownPosition;
  final String? errorMessage;

  LocationState({
    required this.status,
    this.lastKnownPosition,
    this.errorMessage,
  });

  LocationState copyWith({
    LocationServiceStatus? status,
    Position? lastKnownPosition,
    String? errorMessage,
  }) {
    return LocationState(
      status: status ?? this.status,
      lastKnownPosition: lastKnownPosition ?? this.lastKnownPosition,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

final locationServiceProvider =
    StateNotifierProvider<LocationService, LocationState>((ref) {
      return LocationService(ref.watch(locationRepositoryProvider));
    });

class LocationService extends StateNotifier<LocationState> {
  final LocationRepository _repository;
  StreamSubscription<Position>? _positionStreamSubscription;
  DateTime? _lastApiUpdate;
  static const _minUpdateInterval = Duration(minutes: 5); // Time throttle
  static const _minDistanceChange =
      500; // Distance throttle (meters) in stream config

  LocationService(this._repository)
    : super(LocationState(status: LocationServiceStatus.unknown)) {
    _checkInitialStatus();
  }

  Future<void> _checkInitialStatus() async {
    final permission = await Permission.location.status;
    if (permission.isGranted) {
      _startTracking();
    } else if (permission.isDenied) {
      state = LocationState(status: LocationServiceStatus.denied);
    } else {
      state = LocationState(status: LocationServiceStatus.unknown);
    }
  }

  Future<void> requestPermission() async {
    state = state.copyWith(status: LocationServiceStatus.requesting);
    final status = await Permission.location.request();

    if (status.isGranted) {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = state.copyWith(
          status: LocationServiceStatus.disabled,
          errorMessage: 'Location services are disabled.',
        );
        return;
      }
      _startTracking();
    } else if (status.isPermanentlyDenied) {
      state = state.copyWith(
        status: LocationServiceStatus.denied,
        errorMessage:
            'Permission permanently denied. Please enable in settings.',
      );
    } else {
      state = state.copyWith(status: LocationServiceStatus.denied);
    }
  }

  void _startTracking() {
    state = state.copyWith(status: LocationServiceStatus.ready);

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: _minDistanceChange,
    );

    _positionStreamSubscription?.cancel();
    _positionStreamSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position position) {
            state = state.copyWith(lastKnownPosition: position);
            _attemptApiUpdate(position);
          },
          onError: (e) {
            debugPrint('❌ Stream error: $e');
            state = state.copyWith(
              status: LocationServiceStatus.error,
              errorMessage: e.toString(),
            );
          },
        );
  }

  Future<void> _attemptApiUpdate(Position position) async {
    final now = DateTime.now();
    if (_lastApiUpdate == null ||
        now.difference(_lastApiUpdate!) > _minUpdateInterval) {
      try {
        await _repository.updateLocation(position);
        _lastApiUpdate = now;
      } catch (e) {
        // Log error silently, don't disrupt user state for background sync fail
        debugPrint('❌ Location update failed: $e');
      }
    }
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }
}
