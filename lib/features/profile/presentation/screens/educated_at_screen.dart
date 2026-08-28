import 'package:flutter/material.dart';
import 'package:blindly_dating_app/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blindly_dating_app/core/widgets/app_loader.dart';
import 'package:blindly_dating_app/features/auth/providers/auth_providers.dart';
import 'package:blindly_dating_app/features/onboarding/data/repositories/onboarding_repository.dart';
import 'package:blindly_dating_app/features/profile/provider/profile_provider.dart';

class EducatedAtScreen extends ConsumerStatefulWidget {
  final bool isEditMode;

  const EducatedAtScreen({super.key, this.isEditMode = false});

  @override
  ConsumerState<EducatedAtScreen> createState() => _EducatedAtScreenState();
}

class _EducatedAtScreenState extends ConsumerState<EducatedAtScreen> {
  AppLocalizations get l10n => AppLocalizations.of(context);


  final TextEditingController _schoolController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final profile = ref.read(currentUserProfileProvider).value;
    if (profile != null) {
      _schoolController.text = profile.educatedAt ?? '';
      _yearController.text = profile.graduationYear?.toString() ?? '';
    }
  }

  Future<void> _handleSave() async {
    final school = _schoolController.text.trim();
    final year = _yearController.text.trim();

    if (school.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.enterInstitution)),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user != null) {
        final int? yearInt = int.tryParse(year);

        await ref.read(onboardingRepositoryProvider).updateProfileData(
          user.id,
          {'educated_at': school, 'graduation_year': yearInt},
        );

        if (mounted) {
          final currentProfile = ref.read(currentUserProfileProvider).value;
          if (currentProfile != null) {
            final updatedProfile = currentProfile.copyWith(
              educatedAt: school,
              graduationYear: yearInt,
            );
            ref
                .read(currentUserProfileProvider.notifier)
                .updateProfile(updatedProfile);
          }
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.errUpdateFailed('$e'))));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF4A503D); // Olive green

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.educatedAt, // Updated title
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Skip',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.showInstitutionOnProfile,
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 24),

            // Institution Field
            const Text(
              'Institution',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _schoolController,
              decoration: InputDecoration(
                hintText: 'HICAS',
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Year Field
            Text(
              l10n.graduationYear,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _yearController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '2022',
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),

            const Spacer(),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const AppLoader(color: Colors.white)
                    : const Text(
                        'Save',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
