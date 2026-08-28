import 'package:flutter/material.dart';
import 'package:blindly_dating_app/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blindly_dating_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:blindly_dating_app/features/profile/provider/profile_provider.dart';

class PronounsScreen extends ConsumerStatefulWidget {
  final bool isEditMode;

  const PronounsScreen({super.key, this.isEditMode = false});

  @override
  ConsumerState<PronounsScreen> createState() => _PronounsScreenState();
}

class _PronounsScreenState extends ConsumerState<PronounsScreen> {
  AppLocalizations get l10n => AppLocalizations.of(context);


  // Enum values as keys, display strings as values
  final Map<String, String> _pronounOptions = {
    'she_her': 'She/Her',
    'he_him': 'He/Him',
    'they_them': 'They/Them',
    've_ver': 'Ve/Ver',
    'ey_em': 'Ey/Em', // Note: Check backend support for these
    'per_per': 'Per/Per',
    'ze_zir': 'Ze/Zir',
    'prefer_not': 'Prefer not to say',
  };

  String? _selectedPronoun;
  bool _showOnProfile = false; // TODO: Persist if supported by backend

  @override
  void initState() {
    super.initState();
    final profile = ref.read(currentUserProfileProvider).value;
    if (profile != null) {
      _selectedPronoun = profile.pronouns;
    }
  }

  Future<void> _save() async {
    if (_selectedPronoun != null) {
      try {
        await ref.read(profileRepositoryProvider).updateProfile(
          ref.read(currentUserProfileProvider).value!.id,
          {'pronouns': _selectedPronoun},
        );
        if (mounted) {
          final currentProfile = ref.read(currentUserProfileProvider).value;
          if (currentProfile != null) {
            final updatedProfile = currentProfile.copyWith(
              pronouns: _selectedPronoun,
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
          l10n.pickYourPronoun,
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
            onPressed: () {
              // Skip logic - just pop or clear selection?
              // Assuming skip means keep existing or do nothing
              Navigator.pop(context);
            },
            child: Text(
              l10n.skip,
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
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
                    l10n.pronounsBody,
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _pronounOptions.entries.map((entry) {
                      final isSelected = _selectedPronoun == entry.key;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            // Single selection logic for now as per schema constraints
                            if (isSelected) {
                              _selectedPronoun = null;
                            } else {
                              _selectedPronoun = entry.key;
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
                                ? const Color(
                                    0xFFDCC780,
                                  ) // Gold-ish selection color from image
                                : const Color(
                                    0xFFF5F5F5,
                                  ), // Light grey unselected
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            entry.value,
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
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        l10n.showPronounOnProfile,
                        style: const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                    Switch(
                      value: _showOnProfile,
                      onChanged: (val) {
                        setState(() {
                          _showOnProfile = val;
                        });
                      },
                      activeThumbColor: const Color(
                        0xFF4A503D,
                      ), // Dark olive green
                    ),
                  ],
                ),
                const SizedBox(height: 16),
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
                const SizedBox(height: 16), // Bottom safe area margin
              ],
            ),
          ),
        ],
      ),
    );
  }
}
