import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../media/providers/media_provider.dart';
import '../../providers/onboarding_provider.dart';
import 'base_onboarding_step_screen.dart';

class PhotoUploadScreen extends ConsumerWidget {
  const PhotoUploadScreen({super.key});

  Future<void> _checkPermissionAndPick(
    BuildContext context,
    WidgetRef ref,
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

  void _showImageSourceSheet(BuildContext context, WidgetRef ref, int index) {
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
                _checkPermissionAndPick(context, ref, false, index);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(ctx);
                _checkPermissionAndPick(context, ref, true, index);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaState = ref.watch(mediaProvider);
    final theme = Theme.of(context);

    // -------------------------------------------------------------------------
    // 🔔 NEW: Listen for "Photo Blocked" errors and show a popup
    // -------------------------------------------------------------------------
    ref.listen(mediaProvider, (previous, next) {
      // If there is a new error that is different from the last one...
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
    // -------------------------------------------------------------------------

    // Validation
    final canProceed = mediaState.selectedPhotos.whereType<File>().length >= 2;

    return BaseOnboardingStepScreen(
      title: 'Add Photos',
      // Explicitly hide next button from base, as we want custom button in body or custom footer?
      // Actually standard Next button is fine if styled similarly, but design has it at bottom.
      // Base screen puts it at bottom. We just need to ensure style matches.
      // But the design shows "Add more photos" text above it.
      // Let's keep using BaseOnboardingStepScreen for consistency but maybe pass custom footer?
      // BaseOnboardingStepScreen structure is flexible.
      nextLabel: 'Continue',
      onNext: () {
        if (canProceed) {
          ref.read(onboardingProvider.notifier).completeStep('photo_upload');
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
              color: Colors.black87, // Stronger contrast per design
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
          // 2x3 Grid
          // Fixed height grid or expanded? The design shows 6 large squares.
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85, // Sqaure-ish but card-like
            ),
            itemCount: 6,
            itemBuilder: (context, index) {
              final photo = index < mediaState.selectedPhotos.length
                  ? mediaState.selectedPhotos[index]
                  : null;

              return GestureDetector(
                onTap: () {
                  if (photo == null) {
                    // Only open if it's the next available slot OR any slot?
                    // User Request: "select exact position and add image on that position"
                    // So we allow any slot.
                    _showImageSourceSheet(context, ref, index);
                  } else {
                    // Tap on existing
                    _showEditOrRemoveSheet(context, ref, index, photo);
                  }
                },
                child: _buildPhotoSlot(context, photo, index == 0),
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

          // "Add more photos" button
          // If usage is random-access, this button acts as "Add to first empty slot"?
          // Or just hide it since grid slots are clickable.
          // Let's keep it and make it add to first empty slot for convenience.
          if (mediaState.validPhotoCount > 0 && mediaState.validPhotoCount < 6)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TextButton(
                onPressed: () {
                  // Find first empty slot
                  int firstEmpty = mediaState.selectedPhotos.indexOf(null);
                  if (firstEmpty != -1) {
                    _showImageSourceSheet(context, ref, firstEmpty);
                  }
                },
                child: const Text('Add more photos'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPhotoSlot(BuildContext context, File? photo, bool isMain) {
    if (photo != null) {
      // Filled State
      return Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: FileImage(photo),
                fit: BoxFit.cover,
              ),
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

          // Remove button
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
      // Empty State - Dashed Border
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
    WidgetRef ref,
    int index,
    File file,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.crop),
              title: const Text('Edit Photo'),
              onTap: () async {
                Navigator.pop(ctx);
                final repo = ref.read(mediaRepositoryProvider);
                // We need to re-crop this specific file
                final cropped = await repo.cropImage(file);
                if (cropped != null && context.mounted) {
                  // Update the file in the provider.
                  // Provider needs a update method?
                  // Currently we only have remove/add.
                  // Let's remove and insert at same index?
                  // No, reorderImages handles move.
                  // We need an "updateImage(index, file)" method in provider.
                  // For now, remove and add is clunky as it changes order.
                  // I should add `updateImage` to provider.
                  // Waiting for that... assume remove+insert for now or separate task.
                  // Actually, let's just trigger capture/pick again?
                  // User asked for "Edit".
                  // Let's implement a quick updateHack:
                  ref.read(mediaProvider.notifier).updateImage(index, cropped);
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
