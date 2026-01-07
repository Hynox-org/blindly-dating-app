import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../onboarding/presentation/providers/onboarding_provider.dart';
import '../../../../onboarding/presentation/screens/steps/base_onboarding_step_screen.dart';

class PermissionsScreen extends ConsumerStatefulWidget {
  const PermissionsScreen({super.key});

  @override
  ConsumerState<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends ConsumerState<PermissionsScreen>
    with WidgetsBindingObserver {
  Map<Permission, PermissionStatus> _statuses = {};
  bool _isLoading = true;

  final List<Permission> _requiredPermissions = [
    Permission.camera,
    Permission
        .photos, // On Android < 13 this maps to storage slightly differently, plugin handles it
    Permission.locationWhenInUse,
    Permission.notification,
    Permission.microphone,
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    setState(() => _isLoading = true);
    Map<Permission, PermissionStatus> newStatuses = {};
    for (var perm in _requiredPermissions) {
      newStatuses[perm] = await perm.status;
    }
    if (mounted) {
      setState(() {
        _statuses = newStatuses;
        _isLoading = false;
      });
    }
  }

  Future<void> _requestPermission(Permission permission) async {
    final status = await permission.request();
    if (mounted) {
      setState(() {
        _statuses[permission] = status;
      });
    }

    if (status.isPermanentlyDenied) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Permission Required'),
            content: const Text(
              'This permission is required for the app to function correctly. Please enable it in settings.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  openAppSettings();
                },
                child: const Text('Settings'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _requestAll() async {
    Map<Permission, PermissionStatus> statuses = await _requiredPermissions
        .request();
    if (mounted) {
      setState(() {
        _statuses.addAll(statuses);
      });
    }
  }

  IconData _getIconForPermission(Permission perm) {
    if (perm == Permission.camera) return Icons.camera_alt_outlined;
    if (perm == Permission.photos) return Icons.photo_library_outlined;
    if (perm == Permission.locationWhenInUse) return Icons.location_on_outlined;
    if (perm == Permission.notification) return Icons.notifications_outlined;
    if (perm == Permission.microphone) return Icons.mic_none_outlined;
    return Icons.settings_outlined;
  }

  String _getTitleForPermission(Permission perm) {
    if (perm == Permission.camera) return 'Camera Access';
    if (perm == Permission.photos) return 'Photo Library';
    if (perm == Permission.locationWhenInUse) return 'Location Access';
    if (perm == Permission.notification) return 'Notification Access';
    if (perm == Permission.microphone) return 'Microphone Access';
    return 'Unknown Access';
  }

  String _getDescriptionForPermission(Permission perm) {
    if (perm == Permission.camera) {
      return 'To take profile photos and verify identity.';
    }
    if (perm == Permission.photos) return 'To upload photos from your gallery.';
    if (perm == Permission.locationWhenInUse) {
      return 'To show you matches nearby.';
    }
    if (perm == Permission.notification) {
      return 'To alert you of new matches and messages.';
    }
    if (perm == Permission.microphone) {
      return 'For voice and video interactions.';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return BaseOnboardingStepScreen(
      title: 'App Permissions',
      showBackButton: true,
      nextLabel: 'Continue',
      onNext: () {
        ref.read(onboardingProvider.notifier).completeStep('permissions');
      },
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      children: List.generate(_requiredPermissions.length, (
                        index,
                      ) {
                        final perm = _requiredPermissions[index];
                        final status =
                            _statuses[perm] ?? PermissionStatus.denied;
                        final isGranted = status.isGranted || status.isLimited;
                        final isLast = index == _requiredPermissions.length - 1;

                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary, // Dark Olive Green
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      _getIconForPermission(perm),
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimary, // Goldish color
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _getTitleForPermission(perm),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _getDescriptionForPermission(perm),
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[600],
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Transform.scale(
                                    scale: 0.8,
                                    child: Switch(
                                      value: isGranted,
                                      activeThumbColor: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      activeTrackColor: Theme.of(
                                        context,
                                      ).colorScheme.primary.withOpacity(0.4),
                                      onChanged: (value) {
                                        if (value && !isGranted) {
                                          _requestPermission(perm);
                                        } else if (!value && isGranted) {
                                          openAppSettings();
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!isLast)
                              Divider(
                                height: 1,
                                thickness: 1,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.1),
                                indent: 80,
                              ),
                          ],
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
