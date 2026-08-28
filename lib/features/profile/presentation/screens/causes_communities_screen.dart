import 'package:flutter/material.dart';
import 'package:blindly_dating_app/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blindly_dating_app/features/profile/provider/profile_provider.dart';

class CausesCommunitiesScreen extends ConsumerStatefulWidget {
  final bool isEditMode;

  const CausesCommunitiesScreen({super.key, this.isEditMode = false});

  @override
  ConsumerState<CausesCommunitiesScreen> createState() =>
      _CausesCommunitiesScreenState();
}

class _CausesCommunitiesScreenState
    extends ConsumerState<CausesCommunitiesScreen> {
  AppLocalizations get l10n => AppLocalizations.of(context);


  final List<String> _options = [
    'Human Rights',
    'Disability Rights',
    'Feminism',
    'Black Lives Matter', // Corrected spelling from 'Black Live Matters'
    'Environmentalism',
    'LGBTQ Rights',
    'Immigrant Rights',
    'End Religious Hate',
    'Indigenous Rights',
    'Neuro diversity',
    'Voter Rights',
    'Reproductive Rights',
  ];

  final List<String> _selectedCauses = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(currentUserProfileProvider).value;
    if (profile?.causesCommunities != null) {
      _selectedCauses.addAll(profile!.causesCommunities);
    }
  }

  void _toggleSelection(String cause) {
    setState(() {
      if (_selectedCauses.contains(cause)) {
        _selectedCauses.remove(cause);
      } else {
        if (_selectedCauses.length < 3) {
          _selectedCauses.add(cause);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.maxThreeOptions)),
          );
        }
      }
    });
  }

  Future<void> _save() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final currentProfile = ref.read(currentUserProfileProvider).value;
      if (currentProfile == null) return;

      final updatedProfile = currentProfile.copyWith(
        causesCommunities: _selectedCauses,
      );

      await ref.read(currentUserProfileProvider.notifier).updateProfileAndRecalculateTrust(
        userId: currentProfile.id,
        updates: {'causes_communities': _selectedCauses},
        updatedProfile: updatedProfile,
      );

      if (mounted) {
        Navigator.pop(context);
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.causesTitle,
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
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              l10n.selectUpTo3Causes,
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _options.map((option) {
                  final isSelected = _selectedCauses.contains(option);
                  return GestureDetector(
                    onTap: () => _toggleSelection(option),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFE8D595) // Gold selection
                            : const Color(0xFFF5F5F5), // Light grey
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        option,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${_selectedCauses.length}/3 Selected',
                style: const TextStyle(color: Colors.black, fontSize: 14),
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
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
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
