import 'package:flutter/material.dart';
import 'package:blindly_dating_app/l10n/app_localizations.dart';
import 'package:blindly_dating_app/core/utils/vocab.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blindly_dating_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:blindly_dating_app/features/profile/provider/profile_provider.dart';

class EducationLevelScreen extends ConsumerStatefulWidget {
  final bool isEditMode;

  const EducationLevelScreen({super.key, this.isEditMode = false});

  @override
  ConsumerState<EducationLevelScreen> createState() =>
      _EducationLevelScreenState();
}

class _EducationLevelScreenState extends ConsumerState<EducationLevelScreen> {
  AppLocalizations get l10n => AppLocalizations.of(context);


  final List<String> _educationOptions = [
    'High school',
    'Grade School',
    'Diploma',
    'Under Graduate',
    'Post Graduate',
    'Doctorate',
    'Others',
  ];

  String? _selectedLevel;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(currentUserProfileProvider).value;
    _selectedLevel = profile?.educationLevel;
  }

  Future<void> _save() async {
    try {
      final userId = ref.read(currentUserProfileProvider).value!.id;
      final repo = ref.read(profileRepositoryProvider);

      await repo.updateProfile(userId, {'education_level': _selectedLevel});

      if (mounted) {
        final currentProfile = ref.read(currentUserProfileProvider).value;
        if (currentProfile != null) {
          final updatedProfile = currentProfile.copyWith(
            educationLevel: _selectedLevel,
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
          SnackBar(content: Text(l10n.errUpdateFailed('$e'))),
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
        title: Text(
          l10n.educationLevelTitle,
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
            child: Text(
              l10n.skip,
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
              itemCount: _educationOptions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final option = _educationOptions[index];
                final isSelected = _selectedLevel == option;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedLevel = option;
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
                      vocabLabel(l10n, option),
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
                child: Text(
                  l10n.save,
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
