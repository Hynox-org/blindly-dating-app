import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:blindly_dating_app/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
// CHECK YOUR IMPORTS
import '../../../../auth/providers/auth_providers.dart';
import '../../../../media/providers/media_provider.dart';
import '../../providers/onboarding_provider.dart';
import '../../../../../core/widgets/app_loader.dart';
import '../../../../profile/provider/profile_provider.dart';
import 'base_onboarding_step_screen.dart';

class PhotoUploadScreen extends ConsumerStatefulWidget {
  final bool isEditMode;

  const PhotoUploadScreen({super.key, this.isEditMode = false});

  @override
  ConsumerState<PhotoUploadScreen> createState() => _PhotoUploadScreenState();
}

class _PhotoUploadScreenState extends ConsumerState<PhotoUploadScreen> {
  AppLocalizations get l10n => AppLocalizations.of(context);

  @override
  void initState() {
    super.initState();
    // Load existing photos from DB/Storage on startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user != null) {
        ref.read(mediaProvider.notifier).loadUserMedia(user.id);
      }
    });
  }

  Future<void> _checkPermissionAndPick(
    BuildContext context,
    bool isCamera,
    int index,
  ) async {
    // Read before awaiting: the context may not be worth much afterwards.
    final theme = Theme.of(context);

    PermissionStatus status;
    if (Platform.isAndroid && !isCamera) {
      status = await Permission.photos.request();
      if (status.isDenied) status = await Permission.storage.request();
    } else {
      status = await (isCamera
          ? Permission.camera.request()
          : Permission.photos.request());
    }

    if (status.isGranted || status.isLimited) {
      final repo = ref.read(mediaRepositoryProvider);
      final notifier = ref.read(mediaProvider.notifier);

      // One source of truth for the limit, whichever way the photo arrives.
      final room = ref.read(mediaProvider).freeSlots(index);
      if (room <= 0) return;

      try {
        final picked = isCamera
            ? [await repo.pickImageFromCamera()].nonNulls
            : await repo.pickImagesFromGallery(maxImages: room);

        final files = <File>[];
        for (final xFile in picked.take(room)) {
          final cropped = await repo.cropImage(
            File(xFile.path),
            toolbarColor: theme.primaryColor,
            toolbarWidgetColor: theme.colorScheme.onPrimary,
            activeControlsWidgetColor: theme.primaryColor,
          );
          if (cropped != null) files.add(cropped);
        }

        await notifier.processAndAddFiles(files, index);
      } catch (e) {
        debugPrint("Error picking/cropping: $e");
      }
    } else if (status.isPermanentlyDenied) {
      if (context.mounted) {
        _showPermissionDialog(context, isCamera);
      }
    }
  }

  void _showPermissionDialog(BuildContext context, bool isCamera) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.permissionRequired),
        content: Text(
          l10n.grantPermissionPhotos(isCamera ? l10n.camera : l10n.photoLibrary),
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

  void _showImageSourceSheet(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(l10n.gallery),
              onTap: () {
                Navigator.pop(ctx);
                _checkPermissionAndPick(context, false, index);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(l10n.camera),
              onTap: () {
                Navigator.pop(ctx);
                _checkPermissionAndPick(context, true, index);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaState = ref.watch(mediaProvider);
    final theme = Theme.of(context);

    // A rejected photo and a failed request are different problems and get
    // different messages: one asks for another photo, the other for a retry.
    ref.listen(mediaProvider, (previous, next) {
      if (next.rejections.isNotEmpty) {
        _showRejectionDialog(next.rejections);
      } else if (next.error != null && next.error != previous?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_errorText(next.error!))),
        );
      }
    });

    final canProceed = mediaState.validPhotoCount >= 2;

    return Stack(
      children: [
        BaseOnboardingStepScreen(
          title: l10n.addPhotos,
          showBackButton: true,
          nextLabel: 'Continue',
          isNextEnabled: canProceed,
          isEditMode: widget.isEditMode, // Pass edit mode
          onNext: () {
            final user = ref.read(authRepositoryProvider).currentUser;
            if (user != null) {
              _handleNext(user.id);
            }
          },
          child: Column(
            children: [
              const SizedBox(height: 10),
              Text(
                l10n.addAtLeast2Photos,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.87),
                  height: 1.4,
                ),
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.tapPhotoToEdit,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: 32),

              // Photo Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: 6,
                itemBuilder: (context, index) {
                  final photoContent = index < mediaState.selectedPhotos.length
                      ? mediaState.selectedPhotos[index]
                      : null;

                  return GestureDetector(
                    onTap: () {
                      if (photoContent == null) {
                        _showImageSourceSheet(context, index);
                      } else {
                        _showEditOrRemoveSheet(context, index, photoContent);
                      }
                    },
                    child: _buildPhotoSlot(context, photoContent, index == 0),
                  );
                },
              ),

              const Spacer(),

              // Helper Text
              if (!canProceed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    l10n.addOneMorePhoto,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),

              if (mediaState.validPhotoCount > 0 &&
                  mediaState.validPhotoCount < 6)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TextButton(
                    onPressed: () {
                      int firstEmpty = mediaState.selectedPhotos.indexWhere(
                        (e) => e == null,
                      );
                      if (firstEmpty != -1) {
                        _showImageSourceSheet(context, firstEmpty);
                      }
                    },
                    child: Text(l10n.addMorePhotos),
                  ),
                ),
            ],
          ),
        ),
        if (mediaState.isLoading)
          Positioned.fill(
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  color: Colors.black.withValues(alpha: 0.3),
                  child: const Center(
                    child: AppLoader(
                      size: 40,
                      strokeWidth: 4,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Turns a moderation code into something the user can act on.
  String _reasonText(String code) => switch (code) {
    'no_face' => l10n.photoReasonNoFace,
    'group_photo' => l10n.photoReasonGroupPhoto,
    'face_too_small' => l10n.photoReasonFaceTooSmall,
    'unsafe' => l10n.photoReasonUnsafe,
    'bad_image' => l10n.photoReasonBadImage,
    'image_too_large' => l10n.photoReasonTooLarge,
    _ => l10n.photoReasonUnavailable,
  };

  String _errorText(String code) => switch (code) {
    'need_two_photos' => l10n.addOneMorePhoto,
    'photos_expired' => l10n.photosExpired,
    'load_failed' => l10n.photoLoadFailed,
    _ => l10n.photoSaveFailed,
  };

  void _showRejectionDialog(List<PhotoRejection> rejections) {
    // The same reason twice is one line, not two.
    final reasons = rejections.map((r) => _reasonText(r.code)).toSet().toList();
    final retryable = rejections.every((r) => r.retryable);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.photoNotAccepted),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              rejections.length == 1
                  ? l10n.couldNotVerifyPhoto
                  : l10n.photosNotAdded(rejections.length),
            ),
            const SizedBox(height: 10),
            ...reasons.map(
              (reason) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  "• $reason",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(retryable ? l10n.photoTryAgainLater : l10n.tryDifferentPhoto),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.tryAgain),
          ),
        ],
      ),
    );
  }

  Future<void> _handleNext(String userId) async {
    final notifier = ref.read(mediaProvider.notifier);
    await notifier.submitMedia(userId);
    if (!mounted || ref.read(mediaProvider).error != null) return;

    if (!widget.isEditMode) {
      ref.read(onboardingProvider.notifier).completeStep('photo_upload');
      return;
    }

    // Re-read what was just saved: the photos are signed URLs now, including
    // the ones added in this session, which the old code dropped.
    await notifier.loadUserMedia(userId);
    if (!mounted) return;

    final profile = ref.read(currentUserProfileProvider).value;
    if (profile != null) {
      final urls = ref
          .read(mediaProvider)
          .selectedPhotos
          .nonNulls
          .map((m) => m.url)
          .nonNulls
          .toList();
      ref
          .read(currentUserProfileProvider.notifier)
          .updateProfile(profile.copyWith(imageUrls: urls));
    }
    Navigator.pop(context);
  }

  Widget _buildPhotoSlot(
    BuildContext context,
    MediaContent? content,
    bool isMain,
  ) {
    if (content != null) {
      ImageProvider imageProvider;
      if (content.isLocal) {
        imageProvider = FileImage(content.file!);
      } else {
        imageProvider = NetworkImage(content.url!);
      }

      return Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
              border: isMain
                  ? Border.all(
                      color: Theme.of(context).colorScheme.secondary,
                      width: 3,
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.12),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),

          if (isMain)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star,
                      color: Theme.of(context).colorScheme.onSecondary,
                      size: 12,
                    ),
                    SizedBox(width: 2),
                    Text(
                      l10n.mainPhotoBadge,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                size: 16,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      );
    } else {
      return CustomPaint(
        painter: _DashedBorderPainter(
          color: Theme.of(context).colorScheme.onSurface,
          strokeWidth: 1.0,
          gap: 5.0,
        ),
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.12),
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.photo_library_rounded,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.54),
                  size: 24,
                ),
              ),
              const SizedBox(height: 4),
              Icon(
                Icons.add_circle,
                color: Theme.of(context).colorScheme.onSurface,
                size: 20,
              ),
            ],
          ),
        ),
      );
    }
  }

  void _showEditOrRemoveSheet(
    BuildContext context,
    int index,
    MediaContent content,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (content.isLocal)
              ListTile(
                leading: const Icon(Icons.crop),
                title: Text(l10n.editPhoto),
                onTap: () async {
                  Navigator.pop(ctx);
                  final repo = ref.read(mediaRepositoryProvider);
                  final theme = Theme.of(context);
                  final cropped = await repo.cropImage(
                    content.file!,
                    toolbarColor: theme.colorScheme.secondary,
                    toolbarWidgetColor: theme.colorScheme.onSecondary,
                    activeControlsWidgetColor: theme.colorScheme.primary,
                  );
                  if (cropped != null && context.mounted) {
                    // A re-crop is a new photo, so it is moderated again.
                    ref
                        .read(mediaProvider.notifier)
                        .replaceImage(index, cropped);
                  }
                },
              ),
            ListTile(
              leading: Icon(
                Icons.delete,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                l10n.removePhoto,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              onTap: () {
                Navigator.pop(ctx);
                ref.read(mediaProvider.notifier).removeImage(index);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  _DashedBorderPainter({
    this.color = Colors.black,
    this.strokeWidth = 1.0,
    this.gap = 5.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final Path path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(16),
        ),
      );

    final Path dashedPath = Path();

    double distance = 0.0;
    for (final PathMetric metric in path.computeMetrics()) {
      while (distance < metric.length) {
        dashedPath.addPath(
          metric.extractPath(distance, distance + gap),
          Offset.zero,
        );
        distance += gap * 2;
      }
    }

    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
