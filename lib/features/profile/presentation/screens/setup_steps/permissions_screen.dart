import 'package:flutter/material.dart';
import 'package:blindly_dating_app/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../onboarding/presentation/providers/onboarding_provider.dart';
import '../../../../onboarding/presentation/screens/steps/base_onboarding_step_screen.dart';
import '../../../../../core/widgets/app_loader.dart';

class PermissionsScreen extends ConsumerStatefulWidget {
  const PermissionsScreen({super.key});

  @override
  ConsumerState<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends ConsumerState<PermissionsScreen>
    with WidgetsBindingObserver {
  AppLocalizations get l10n => AppLocalizations.of(context);

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
            title: Text(l10n.permissionRequired),
            content: Text(
              l10n.permissionRequiredBody,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  openAppSettings();
                },
                child: Text(l10n.settingsTitle),
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
    if (perm == Permission.camera) return l10n.cameraAccess;
    if (perm == Permission.photos) return l10n.photoLibrary;
    if (perm == Permission.locationWhenInUse) return l10n.locationAccess;
    if (perm == Permission.notification) return l10n.notificationAccess;
    if (perm == Permission.microphone) return l10n.microphoneAccess;
    return l10n.unknownAccess;
  }

  String _getDescriptionForPermission(Permission perm) {
    if (perm == Permission.camera) {
      return l10n.cameraReason;
    }
    if (perm == Permission.photos) return l10n.photoReason;
    if (perm == Permission.locationWhenInUse) {
      return l10n.locationReason;
    }
    if (perm == Permission.notification) {
      return l10n.notificationReason;
    }
    if (perm == Permission.microphone) {
      return l10n.microphoneReason;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return BaseOnboardingStepScreen(
      title: l10n.appPermissions,
      showBackButton: true,
      nextLabel: l10n.continueLabel,
      onNext: () {
        ref.read(onboardingProvider.notifier).completeStep('permissions');
      },
      child: _isLoading
          ? const AppLoader()
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
                          ).colorScheme.onSurface.withValues(alpha: 0.05),
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
                                      ).colorScheme.primary.withValues(alpha: 0.4),
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
                                ).colorScheme.onSurface.withValues(alpha: 0.1),
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
