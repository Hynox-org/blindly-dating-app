import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

                      // Mosaic "Bento Box" Layout
                      if (validItems.isEmpty) return const SizedBox();

                      // Helper to build item at index (safely)
                      Widget buildSlot(int index) {
                        if (index >= validItems.length) {
                          // Empty slot placeholder if needed, or transparent
                          return const SizedBox();
                        }

                        final entry = validItems[index];

                        return _buildDragTargetItem(
                          context,
                          entry.value,
                          index,
                          entry.key,
                          index == 0, // isMain
                          (from, to) {
                            ref
                                .read(mediaProvider.notifier)
                                .reorderImages(from, to);
                          },
                          () => ref
                              .read(mediaProvider.notifier)
                              .removeImage(entry.key),
                        );
                      }

                      return Column(
                        children: [
                          // -- ROW 1 (Top Area) --
                          Flexible(
                            flex: 2,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // MAIN PHOTO (Index 0) - Big Left
                                Expanded(flex: 2, child: buildSlot(0)),

                                // Right Column (Index 1 & 2)
                                if (validItems.length > 1) ...[
                                  const SizedBox(width: 10),
                                  Expanded(
                                    flex: 1,
                                    child: Column(
                                      children: [
                                        // Index 1
                                        Expanded(child: buildSlot(1)),

                                        // Index 2
                                        if (validItems.length > 2) ...[
                                          const SizedBox(height: 10),
                                          Expanded(child: buildSlot(2)),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          // -- ROW 2 (Bottom Area) --
                          if (validItems.length > 3) ...[
                            const SizedBox(height: 10),
                            Flexible(
                              flex: 1,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Index 3
                                  Expanded(child: buildSlot(3)),

                                  // Index 4
                                  if (validItems.length > 4) ...[
                                    const SizedBox(width: 10),
                                    Expanded(child: buildSlot(4)),
                                  ],

                                  // Index 5
                                  if (validItems.length > 5) ...[
                                    const SizedBox(width: 10),
                                    Expanded(child: buildSlot(5)),
                                  ],
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 30), // Bottom padding
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDragTargetItem(
    BuildContext context,
    File photo,
    int index,
    int originalIndex,
    bool isMain,
    void Function(int, int) onSwap,
    VoidCallback onRemove,
  ) {
    // The data passing around is the VISUAL INDEX (0, 1, 2...)

    Widget buildCardContent({bool isDragging = false}) {
      return Container(
        // Allow widget to fill parent
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.file(photo, fit: BoxFit.cover),

              if (isMain) ...[
                // Shine overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                      ],
                    ),
                  ),
                ),
                // Main Badge
                Positioned(
                  bottom: 12,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6C97A),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 8),
                        ],
                      ),
                      child: const Text(
                        'MAIN',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ),
              ] else
                // Strip Number
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              // Delete Button (Top Right)
              if (!isDragging)
                Positioned(
                  top: 8,
                  right: 8,
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
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return DragTarget<int>(
      onWillAccept: (fromIndex) => fromIndex != null && fromIndex != index,
      onAccept: (fromIndex) {
        onSwap(fromIndex, index);
      },
      builder: (context, candidateData, rejectedData) {
        final isHovered = candidateData.isNotEmpty;

        return Draggable<int>(
          data: index,
          // Fixed size feedback for consistent drag experience
          feedback: Material(
            color: Colors.transparent,
            child: SizedBox(
              width: 100,
              height: 100,
              child: buildCardContent(isDragging: true),
            ),
          ),
          childWhenDragging: Opacity(opacity: 0.3, child: buildCardContent()),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform: isHovered
                ? (Matrix4.identity()..scale(
                    0.95,
                  )) // Shrink slightly on hover to indicate "replace me"
                : Matrix4.identity(),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: isHovered
                  ? Border.all(color: const Color(0xFFE6C97A), width: 3)
                  : null,
            ),
            child: buildCardContent(),
          ),
        );
      },
    );
  }
}
