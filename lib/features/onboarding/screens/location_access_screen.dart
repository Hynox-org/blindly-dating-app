import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../auth/providers/auth_providers.dart';
import '../data/repositories/onboarding_repository.dart';
import '../presentation/screens/onboarding_shell.dart';

class LocationAccessScreen extends ConsumerStatefulWidget {
  const LocationAccessScreen({super.key});

  @override
  ConsumerState<LocationAccessScreen> createState() =>
      _LocationAccessScreenState();
}

class _LocationAccessScreenState extends ConsumerState<LocationAccessScreen> {
  bool _isLoading = false;

  Future<void> _requestLocationPermission() async {
    setState(() => _isLoading = true);

    final status = await Permission.locationWhenInUse.request();

    if (status.isGranted) {
      await _proceedToNextScreen();
    } else if (status.isPermanentlyDenied) {
      setState(() => _isLoading = false);
      await openAppSettings();
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _proceedToNextScreen() async {
    final user = ref.read(authRepositoryProvider).currentUser;

    if (user != null) {
      await _checkOnboardingAndNavigate(user.id);
    } else {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/welcome');
      }
    }
  }

  Future<void> _checkOnboardingAndNavigate(String userId) async {
    try {
      final isComplete = await ref
          .read(onboardingRepositoryProvider)
          .validateAndFixOnboardingStatus(userId);

      if (!mounted) return;

      if (isComplete) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OnboardingShell()),
        );
      }
    } catch (_) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/welcome');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Location Access',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.location_on_outlined,
                    size: 80,
                    color: colorScheme.onPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              const Text(
                'Find People Near You',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "To show you potential matches in your area. We need to\nknow your location. This also help us verify your\ngeneral location for authenticity and safety. Don't\nworry, your exact location is never shared",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.5),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _requestLocationPermission,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: colorScheme.onPrimary,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Allow location access',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
