import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../auth/providers/auth_providers.dart';
import '../../../../media/providers/media_provider.dart';
import '../../providers/onboarding_provider.dart';
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
    // Load existing photos if we haven't already (or refresh)
    // We can check if state is empty, or just always load.
    // Always load ensures sync with DB.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user != null) {
        // Only load if empty? Or always?
        // If we revisit, we want to see what's in provider.
        // But if provider is fresh (app restart), we need to load.
        // If provider has data, do we overwrite?
        // Let's assume provider state > DB state if in-memory session is active.
        // But how to tell? validPhotoCount == 0?
        // If user has 0 photos in DB, validPhotoCount will be 0.
        // Let's just load. The provider can handle diffing or just overwrite.
        // But wait, if I uploaded a photo, then went to next step, then back...
        // The provider still has the photo (which is local File or URL).
        // If I reload from DB, I get URLs.
        // Using URLs is safer for consistency.
        // So I will call loadUserMedia.
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
      if (isCamera) {
        await ref.read(mediaProvider.notifier).captureImage(index);
      } else {
        await ref.read(mediaProvider.notifier).pickImages(index);
      }
    } else if (status.isPermanentlyDenied) {
      if (context.mounted) {
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
    }
  }

  void _showImageSourceSheet(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
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

    ref.listen(mediaProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Photo Blocked'),
            content: Text(next.error!),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    });

    final canProceed = mediaState.validPhotoCount >= 2;

    return BaseOnboardingStepScreen(
      title: 'Add Photos',
      showBackButton: true,
      nextLabel: 'Continue',
      onNext: () {
        if (canProceed) {
          // We need access to user ID to submit
          final user = ref.read(authRepositoryProvider).currentUser;
          if (user != null) {
            // Wait for submitMedia to finish?
            // submitMedia is async but BaseOnboardingStepScreen onNext is void callback.
            // But we should maybe await it?
            // The provider handles logic. We can call it, then complete step.
            // But submitMedia needs to finish uploading.
            // Ideally we show loading state here.
            // But mediaState.isLoading should trigger loading UI.
            // Let's call submitMedia.
            // Wait, existing code called `completeStep` directly.
            // `completeStep` logic usually updates step status.
            // Does it save data?
            // `PhotoUploadScreen` didn't save data before?
            // Ah, the previous implementation did NOT have a save call in `onNext`.
            // It seemed to rely on `MediaProvider` state matching UI state?
            // But now `submitMedia` is needed to sync changes to DB.
            // So I should call `submitMedia` then `completeStep`.
            _handleNext(user.id);
          }
        } else {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('More Photos Needed'),
              content: const Text('Please add at least 2 photos to continue.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      },
      child: Column(
        children: [
          const SizedBox(height: 10),
          Text(
            'Add at least 2 photos to get your matches! First one is main picture',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.black87,
              height: 1.4,
            ),
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: 8),
          Text(
            'Tap on an added photo to edit or remove it.',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: 32),
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
          if (mediaState.isLoading)
            const Padding(
              padding: EdgeInsets.only(top: 20),
              child: Center(child: CircularProgressIndicator()),
            ),
          if (mediaState.error != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                mediaState.error!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),

          const Spacer(),

          if (!canProceed)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'Please add one more photo',
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            ),

          if (mediaState.validPhotoCount > 0 && mediaState.validPhotoCount < 6)
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
    );
  }

  Future<void> _handleNext(String userId) async {
    await ref.read(mediaProvider.notifier).submitMedia(userId);
    if (mounted) {
      // Check if error after submit
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
              border: isMain ? Border.all(color: Colors.amber, width: 3) : null,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
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
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: Colors.white, size: 12),
                    SizedBox(width: 2),
                    Text(
                      'MAIN',
                      style: TextStyle(
                        color: Colors.white,
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
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 16, color: Colors.black),
            ),
          ),
        ],
      );
    } else {
      return CustomPaint(
        painter: _DashedBorderPainter(
          color: Colors.black,
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
                  color: Colors.grey[200],
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.photo_library_rounded,
                  color: Colors.black54,
                  size: 24,
                ),
              ),
              const SizedBox(height: 4),
              const Icon(Icons.add_circle, color: Colors.black, size: 20),
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
                  final cropped = await repo.cropImage(content.file!);
                  if (cropped != null && context.mounted) {
                    ref
                        .read(mediaProvider.notifier)
                        .updateImage(index, cropped);
                  }
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Remove Photo',
                style: TextStyle(color: Colors.red),
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
