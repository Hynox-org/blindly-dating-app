import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../provider/profile_provider.dart';

class ZodiacScreen extends ConsumerStatefulWidget {
  final bool isEditMode;

  const ZodiacScreen({super.key, this.isEditMode = false});

  @override
  ConsumerState<ZodiacScreen> createState() => _ZodiacScreenState();
}

class _ZodiacScreenState extends ConsumerState<ZodiacScreen> {
  // List of zodiac options
  final List<String> _zodiacOptions = [
    'Aries',
    'Taurus',
    'Gemini',
    'Cancer',
    'Leo',
    'Virgo',
    'Libra',
    'Scorpio',
    'Sagittarius',
    'Capricorn',
    'Aquarius',
    'Pisces',
  ];

  String? _selectedZodiac;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(currentUserProfileProvider).value;
    if (profile != null) {
      _selectedZodiac = profile.zodiac;
    }
  }

  Future<void> _save() async {
    try {
      final userId = ref.read(currentUserProfileProvider).value!.id;
      final repo = ref.read(profileRepositoryProvider);

      // Update 'star_sign' column as per requirement
      // If selection is null (deselected), we can save null or empty string depending on DB
      // Assuming nullable varchar
      await repo.updateProfile(userId, {'star_sign': _selectedZodiac});

      if (mounted) {
        final currentProfile = ref.read(currentUserProfileProvider).value;
        if (currentProfile != null) {
          final updatedProfile = currentProfile.copyWith(
            zodiac: _selectedZodiac,
          );
          ref
              .read(currentUserProfileProvider.notifier)
              .updateProfile(updatedProfile);
        }
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update zodiac: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if any is selected to show count or enable save (logic can vary)
    // Design shows "0/1 Selected" etc.
    final selectedCount = _selectedZodiac != null ? 1 : 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Zodiac Sign',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context), // Skip acts as close/cancel
            child: const Text(
              'Skip',
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              itemCount: _zodiacOptions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final option = _zodiacOptions[index];
                final isSelected = _selectedZodiac == option;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedZodiac = null;
                      } else {
                        _selectedZodiac = option;
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFDCC780) // Selection color
                          : const Color(0xFFF5F5F5), // Default grey
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.transparent, // Or subtle border if needed
                      ),
                    ),
                    child: Text(
                      option,
                      style: TextStyle(
                        color: Colors.black, // Always black text as per design
                        fontSize: 14,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$selectedCount/1 Selected',
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(
                        0xFF4A503D,
                      ), // Dark olive green
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
