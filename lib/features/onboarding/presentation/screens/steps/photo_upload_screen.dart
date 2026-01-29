import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
// CHECK YOUR IMPORTS
import '../../../../auth/providers/auth_providers.dart';
import '../../../../media/providers/media_provider.dart';
import '../../providers/onboarding_provider.dart';
import '../../../../../core/widgets/app_loader.dart';
import 'base_onboarding_step_screen.dart';

class PhotoUploadScreen extends ConsumerStatefulWidget {
  const PhotoUploadScreen({super.key});

  @override
  ConsumerState<PhotoUploadScreen> createState() => _PhotoUploadScreenState();
}

class _PhotoUploadScreenState extends ConsumerState<PhotoUploadScreen> {
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
      final mediaState = ref.read(mediaProvider);
      final theme = Theme.of(context);

      try {
        List<File> filesToProcess = [];

        if (isCamera) {
          // Check limit for camera (1 photo)
          if (mediaState.validPhotoCount >= 6 &&
              mediaState.selectedPhotos[index] == null) {
            // Although technically we shouldn't have enabled the button, double check.
            return;
          }

          final xFile = await repo.pickImageFromCamera();
          if (xFile != null) {
            final file = File(xFile.path);
            final cropped = await repo.cropImage(
              file,
              toolbarColor: theme.primaryColor,
              toolbarWidgetColor: theme.colorScheme.onPrimary,
              activeControlsWidgetColor: theme.primaryColor,
            );
            if (cropped != null) {
              filesToProcess.add(cropped);
            }
          }
        } else {
          // Gallery
          final currentValidCount = mediaState.validPhotoCount;
          final isTargetOccupied = mediaState.selectedPhotos[index] != null;
          final maxToPick = 6 - currentValidCount + (isTargetOccupied ? 1 : 0);

          if (maxToPick <= 0) return;

          final images = await repo.pickImagesFromGallery(maxImages: maxToPick);

          for (final xFile in images) {
            final file = File(xFile.path);
            final cropped = await repo.cropImage(
              file,
              toolbarColor: theme.primaryColor,
              toolbarWidgetColor: theme.colorScheme.onPrimary,
              activeControlsWidgetColor: theme.primaryColor,
            );
            if (cropped != null) {
              filesToProcess.add(cropped);
            }
          }
        }

        if (filesToProcess.isNotEmpty) {
          await notifier.processAndAddFiles(filesToProcess, index);
        }
      } catch (e) {
        // Handle error? or just let it fail silently/log?
        // MediaNotifier stores error in state, but we are doing picking here.
        // We should probably set error in state if picking fails, but Notifier.pickImages did that.
        // Let's just catch and ignore or print for now as UI feedback comes from State.
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
        title: const Text('Permission Required'),
        content: Text(
          'Please grant ${isCamera ? "Camera" : "Photos"} permission to upload photos for your profile.',
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
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(ctx);
                _checkPermissionAndPick(context, false, index);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
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

    // -----------------------------------------------------------
    // ✅ DIALOG LOGIC: Displays the specific Reason from Lambda
    // -----------------------------------------------------------
    ref.listen(mediaProvider, (previous, next) {
      // If there is an error, and it's a NEW error (not the same as before)
      if (next.error != null && next.error != previous?.error) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Photo Not Accepted"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("We could not verify your photo because:"),
                const SizedBox(height: 10),
                // "next.error" contains the string from Lambda/Provider
                // e.g., "Face too far away" or "Group photos not allowed"
                Text(
                  "• ${next.error}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                const SizedBox(height: 20),
                const Text("Please try uploading a different photo."),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Try Again'),
              ),
            ],
          ),
        );
      }
    });

    final canProceed = mediaState.validPhotoCount >= 2;

    return Stack(
      children: [
        BaseOnboardingStepScreen(
          title: 'Add Photos',
          showBackButton: true,
          nextLabel: 'Continue',
          isNextEnabled: canProceed,
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
                'Add at least 2 photos to get your matches! First one is main picture',
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
                'Tap on an added photo to edit or remove it.',
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
                    'Please add one more photo',
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
                    child: const Text('Add more photos'),
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

  Future<void> _handleNext(String userId) async {
    await ref.read(mediaProvider.notifier).submitMedia(userId);
    if (mounted) {
      if (ref.read(mediaProvider).error == null) {
        ref.read(onboardingProvider.notifier).completeStep('photo_upload');
      }
    }
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
                      'MAIN',
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
                title: const Text('Edit Photo'),
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
                    ref
                        .read(mediaProvider.notifier)
                        .updateImage(index, cropped);
                  }
                },
              ),
            ListTile(
              leading: Icon(
                Icons.delete,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                'Remove Photo',
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
