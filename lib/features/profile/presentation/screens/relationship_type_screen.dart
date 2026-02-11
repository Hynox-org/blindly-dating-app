import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../provider/profile_provider.dart';

class RelationshipTypeScreen extends ConsumerStatefulWidget {
  final bool isEditMode;

  const RelationshipTypeScreen({super.key, this.isEditMode = false});

  @override
  ConsumerState<RelationshipTypeScreen> createState() =>
      _RelationshipTypeScreenState();
}

class _RelationshipTypeScreenState
    extends ConsumerState<RelationshipTypeScreen> {
  final List<String> _options = [
    'Monogamy',
    'Non-monogamy',
    'Open to exploring',
    'Polyamory',
    'Open relationship',
    'Others',
  ];

  String? _selectedOption;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(currentUserProfileProvider).value;
    _selectedOption = profile?.relationshipType;
  }

  Future<void> _save() async {
    try {
      final userId = ref.read(currentUserProfileProvider).value!.id;
      final repo = ref.read(profileRepositoryProvider);

      await repo.updateProfile(userId, {'relationship_type': _selectedOption});

      if (mounted) {
        final currentProfile = ref.read(currentUserProfileProvider).value;
        if (currentProfile != null) {
          final updatedProfile = currentProfile.copyWith(
            relationshipType: _selectedOption,
          );
          ref
              .read(currentUserProfileProvider.notifier)
              .updateProfile(updatedProfile);
        }
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update relationship type: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Relationship Type',
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
            onPressed: () => Navigator.pop(context),
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
              padding: const EdgeInsets.all(16.0),
              itemCount: _options.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final option = _options[index];
                final isSelected = _selectedOption == option;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedOption = option;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(
                              0xFFE8D595,
                            ) // Gold/Yellow selection color
                          : const Color(0xFFF5F5F5), // Light grey background
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(color: Colors.transparent)
                          : Border.all(color: Colors.transparent),
                    ),
                    child: Text(
                      option,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A503D), // Dark olive green
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
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
