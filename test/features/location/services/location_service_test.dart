import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
// ensure imports point correctly
import 'package:blindly_dating_app/features/location/services/location_service.dart';
import 'package:blindly_dating_app/features/location/data/location_repository.dart';

import 'package:flutter/services.dart';

class MockLocationRepository extends Mock implements LocationRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockLocationRepository mockRepo;

  setUpAll(() {
    const MethodChannel(
      'flutter.baseflow.com/permissions/methods',
    ).setMockMethodCallHandler((MethodCall methodCall) async {
      // Return integer for PermissionStatus.denied (1) or granted?
      // checkPermissionStatus: return int.
      // requestPermissions: return Map<int, int>.
      switch (methodCall.method) {
        case 'checkPermissionStatus':
          return 0; // denied
        case 'requestPermissions':
          return {1: 1}; // location: granted (if needed)
        default:
          return null;
      }
    });

    const MethodChannel(
      'flutter.baseflow.com/geolocator/methods',
    ).setMockMethodCallHandler((MethodCall methodCall) async {
      return null;
    });
  });

  setUp(() {
    mockRepo = MockLocationRepository();
  });

  test('Initial state should be unknown', () {
    final container = ProviderContainer(
      overrides: [locationRepositoryProvider.overrideWithValue(mockRepo)],
    );
    addTearDown(container.dispose);

    // Initial read should trigger the service creation and initial check
    final state = container.read(locationServiceProvider);

    expect(state.status, LocationServiceStatus.unknown);
  });

  // Additional tests can be added here using container.read/listen
}
