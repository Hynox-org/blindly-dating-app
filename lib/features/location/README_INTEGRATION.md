# Location Feature Integration Guide

This feature is fully implemented but currently disabled in the UI. Follow these steps to re-enable it.

## 1. Backend Prerequisites (Supabase)

Ensure your **Edge Function** `update-location` is deployed and has the necessary secrets:

-   `SUPABASE_URL`
-   `SUPABASE_ANON_KEY`
-   `SUPABASE_SERVICE_ROLE_KEY` (Critical for location updates)

## 2. Request Permissions on Startup

Add the permission request logic to `lib/features/splash/screens/splash_screen.dart` (or your initial onboarding screen).

**Import:**
```dart
import '../../location/services/location_service.dart';
```

**Logic (inside `initState`):**
```dart
@override
void initState() {
  super.initState();
  // ... controller init ...

  // TRIGGER PERMISSION REQUEST
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ref.read(locationServiceProvider.notifier).requestPermission();
  });

  // ... rest of init ...
}
```

## 3. Display Nearby Users (Home Screen)

Add the discovery UI to `lib/features/home/screens/home_screen.dart`.

**Import:**
```dart
import '../../location/data/location_repository.dart';
```

**Widget Class (Append to file):**
```dart
class _NearbyUsersSection extends ConsumerWidget {
  const _NearbyUsersSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nearby Users',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: ref.read(locationRepositoryProvider).getDiscoveryFeed(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red));
            }
            final users = snapshot.data ?? [];
            if (users.isEmpty) {
              return const Text('No users found nearby.');
            }
            return SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return Card(
                    child: Container(
                      width: 120,
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.person, size: 40),
                          const SizedBox(height: 5),
                          Text(user['display_name'] ?? 'User', maxLines: 1, overflow: TextOverflow.ellipsis),
                          Text('${user['city'] ?? 'Unknown'}'),
                          Text('${(user['distance_km'] as num).toStringAsFixed(1)} km'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
```

**Usage (inside `build` method column):**
```dart
// ... existing cards ...
const SizedBox(height: 20),
const _NearbyUsersSection(),
```
