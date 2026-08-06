import 'package:flutter/material.dart';
import 'package:blindly_dating_app/l10n/app_localizations.dart';
import '../../../../core/utils/vocab.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../provider/profile_provider.dart';

class ReligionScreen extends ConsumerStatefulWidget {
  final bool isEditMode;

  const ReligionScreen({super.key, this.isEditMode = false});

  @override
  ConsumerState<ReligionScreen> createState() => _ReligionScreenState();
}

class _ReligionScreenState extends ConsumerState<ReligionScreen> {
  AppLocalizations get l10n => AppLocalizations.of(context);


  // List of religion options as per design
  final List<String> _religionOptions = [
    'Hindu',
    'Catholic',
    'Muslim',
    'Atheist',
    'Christian',
    'Buddhist',
    'Agnostic',
    'Latter day saint',
    'Zoroastrian', // Fixed spelling from checklist if needed, or keep as user wrote
    'Jewish',
    'Jain',
    'Mormon',
    'Spiritual',
    'Others',
  ];

  String? _selectedReligion;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(currentUserProfileProvider).value;
    if (profile != null) {
      _selectedReligion = profile.religion;
    }
  }

  Future<void> _save() async {
    if (_selectedReligion != null) {
      try {
        await ref.read(profileRepositoryProvider).updateProfile(
          ref.read(currentUserProfileProvider).value!.id,
          {'religion': _selectedReligion},
        );
        if (mounted) {
          final currentProfile = ref.read(currentUserProfileProvider).value;
          if (currentProfile != null) {
            final updatedProfile = currentProfile.copyWith(
              religion: _selectedReligion,
            );
            ref
                .read(currentUserProfileProvider.notifier)
                .updateProfile(updatedProfile);
          }
          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errUpdateFailed('$e'))),
        );
      }
    } else {
      // If unselected, maybe clear it? Or just pop if user didn't mean to change.
      // For now, if null, we just pop.
      // If user wants to clear, they might need a clear button or deselect logic.
      // Assuming single selection toggle behavior below.
      Navigator.pop(context);
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
          l10n.religionViewTitle,
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
          // User requested NO skip button
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.sensitiveInfoNote,
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Religion',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _religionOptions.map((option) {
                      final isSelected = _selectedReligion == option;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedReligion = null;
                            } else {
                              _selectedReligion = option;
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFDCC780) // Gold-ish selection
                                : const Color(0xFFF5F5F5), // Light grey
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            option,
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
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
