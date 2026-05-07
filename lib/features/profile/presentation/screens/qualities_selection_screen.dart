import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../provider/profile_provider.dart';
import '../../domain/repositories/profile_repository.dart';

class QualitiesSelectionScreen extends ConsumerStatefulWidget {
  final bool isEditMode;
  const QualitiesSelectionScreen({super.key, this.isEditMode = false});

  @override
  ConsumerState<QualitiesSelectionScreen> createState() =>
      _QualitiesSelectionScreenState();
}

class _QualitiesSelectionScreenState
    extends ConsumerState<QualitiesSelectionScreen> {
  final List<String> _allQualities = [
    'Ambition',
    'Confidence',
    'Empathy',
    'Humor',
    'Kindness',
    'Openness',
    'Optimism',
    'Sassiness',
    'Playfulness',
    'Leadership',
    'Humility',
    'Loyalty',
    'Sarcasm',
    'Gratitude',
    'Curiosity',
    'Emotional Intelligence',
  ];

  final List<String> _selectedQualities = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(currentUserProfileProvider).value;
    if (profile != null) {
      _selectedQualities.addAll(profile.qualities);
    }
  }

  void _toggleQuality(String quality) {
    setState(() {
      if (_selectedQualities.contains(quality)) {
        _selectedQualities.remove(quality);
      } else {
        if (_selectedQualities.length < 3) {
          _selectedQualities.add(quality);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You can select up to 3 qualities only.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    });
  }

  Future<void> _saveAndContinue() async {
    setState(() => _isLoading = true);
    try {
      final currentProfile = ref.read(currentUserProfileProvider).value;
      if (currentProfile != null) {
        final updatedProfile = currentProfile.copyWith(
          qualities: _selectedQualities,
        );
        
        await ref.read(currentUserProfileProvider.notifier).updateProfileAndRecalculateTrust(
          userId: currentProfile.id,
          updates: {'qualities': _selectedQualities},
          updatedProfile: updatedProfile,
        );

        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving qualities: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Person Qualities',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Skip',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(
              'Choose 3 qualities that would make a connection that much stronger.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _allQualities.map((quality) {
                    final isSelected = _selectedQualities.contains(quality);
                    return GestureDetector(
                      onTap: () => _toggleQuality(quality),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(
                                  0xFFE8D595,
                                ) // Gold/Yellow selection color
                              : const Color(
                                  0xFFF5F5F5,
                                ), // Light grey unselected
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFE8D595)
                                : Colors.transparent,
                          ),
                        ),
                        child: Text(
                          quality,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${_selectedQualities.length}/3 Selected',
                style: const TextStyle(color: Colors.black54, fontSize: 14),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveAndContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A503D), // Dark Olive Green
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Save',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
