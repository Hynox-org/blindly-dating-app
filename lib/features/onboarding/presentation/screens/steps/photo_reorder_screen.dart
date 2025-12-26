import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../media/providers/media_provider.dart';
import '../../providers/onboarding_provider.dart';
import 'base_onboarding_step_screen.dart';

class PhotoReorderScreen extends ConsumerWidget {
  const PhotoReorderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaState = ref.watch(mediaProvider);
    final theme = Theme.of(context);

    return BaseOnboardingStepScreen(
      title: 'Arranging photos',
      showBackButton: true,
      onNext: () async {
        final userId = Supabase.instance.client.auth.currentUser?.id;
        if (userId == null) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Session Expired'),
              content: const Text(
                'Your session has expired. Please log in again.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
          return;
        }

        await ref.read(mediaProvider.notifier).submitMedia(userId);

        final error = ref.read(mediaProvider).error;
        if (error != null) {
          if (context.mounted) {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Error'),
                content: Text(error),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
        } else {
          ref.read(onboardingProvider.notifier).completeStep('photo_reorder');
        }
      },
      showSkipButton: false,
      child: Column(
        children: [
          const SizedBox(height: 10),
          Text(
            'Drag and drop to reorder. The first photo will be your main profile picture.',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: mediaState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Builder(
                    builder: (context) {
                      // Filter out nulls and keep track of original indices
                      final validItems = <MapEntry<int, File>>[];
                      for (
                        int i = 0;
                        i < mediaState.selectedPhotos.length;
                        i++
                      ) {
                        if (mediaState.selectedPhotos[i] != null) {
                          validItems.add(
                            MapEntry(i, mediaState.selectedPhotos[i]!),
                          );
                        }
                      }

                      return ReorderableGridView.builder(
                        itemCount: validItems.length,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(
                          bottom: 100,
                        ), // Zero horizontal to match Base padding
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3, // Matches PhotoUploadScreen
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio:
                                  0.85, // Matches PhotoUploadScreen
                            ),
                        onReorder: (oldIndex, newIndex) {
                          ref
                              .read(mediaProvider.notifier)
                              .reorderImages(oldIndex, newIndex);
                        },
                        itemBuilder: (context, index) {
                          final entry = validItems[index];
                          final originalIndex =
                              entry.key; // Sparse index if needed for delete
                          final photo = entry.value;

                          // Unique key for reordering
                          final key = ValueKey(photo.path);

                          return _buildGridItem(
                            context,
                            key,
                            photo,
                            index,
                            () => ref
                                .read(mediaProvider.notifier)
                                .removeImage(originalIndex),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem(
    BuildContext context,
    Key key,
    File photo,
    int index,
    VoidCallback onRemove,
  ) {
    final isMain = index == 0;
    return Container(
      key: key,
      decoration: BoxDecoration(
        // color: Colors.white, // Removed to prevent white halo during drag
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image (Bottom Layer)
            Image.file(photo, fit: BoxFit.cover),

            // Border Overlay
            if (isMain)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFE6C97A),
                    width: 3,
                    strokeAlign: BorderSide.strokeAlignInside,
                  ),
                ),
              ),

            // "Main" Badge (Bottom)
            if (isMain)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6C97A).withOpacity(0.95),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(0),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'MAIN PHOTO',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Position Indicator (Top Left)
            // Show for all cards to indicate order
            Positioned(
              top: 6,
              left: 6,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isMain ? const Color(0xFFE6C97A) : Colors.black54,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),

            // Delete Button (Top Right)
            Positioned(
              top: 6,
              right: 6,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 4),
                    ],
                  ),
                  child: const Icon(Icons.close, size: 16, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
