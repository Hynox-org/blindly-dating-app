import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:blindly_dating_app/l10n/app_localizations.dart';
import '../../../../core/utils/vocab.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../provider/profile_provider.dart';

class HeightScreen extends ConsumerStatefulWidget {
  final bool isEditMode;

  const HeightScreen({super.key, this.isEditMode = false});

  @override
  ConsumerState<HeightScreen> createState() => _HeightScreenState();
}

class _HeightScreenState extends ConsumerState<HeightScreen> {
  AppLocalizations get l10n => AppLocalizations.of(context);


  // Range: 90cm to 250cm
  final int _minHeight = 90;
  final int _maxHeight = 250;
  late int _selectedHeight;
  late FixedExtentScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(currentUserProfileProvider).value;
    // Default to 170 if not set, or if out of range (just in case)
    int initialHeight = profile?.height ?? 170;
    if (initialHeight < _minHeight) initialHeight = _minHeight;
    if (initialHeight > _maxHeight) initialHeight = _maxHeight;

    _selectedHeight = initialHeight;
    _scrollController = FixedExtentScrollController(
      initialItem: _selectedHeight - _minHeight,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    try {
      final userId = ref.read(currentUserProfileProvider).value!.id;
      final repo = ref.read(profileRepositoryProvider);

      await repo.updateProfile(userId, {'height_cm': _selectedHeight});

      if (mounted) {
        final currentProfile = ref.read(currentUserProfileProvider).value;
        if (currentProfile != null) {
          final updatedProfile = currentProfile.copyWith(
            height: _selectedHeight,
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
        ).showSnackBar(SnackBar(content: Text(l10n.errUpdateFailed('$e'))));
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
          l10n.howTallAreYou,
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
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.showsOnProfile,
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  SizedBox(height: 24),
                  Text(
                    l10n.yourHeight,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: SizedBox(
                height: 350, // Slightly taller
                child: CupertinoPicker(
                  scrollController: _scrollController,
                  itemExtent: 64, // Bigger item extent for spacing
                  onSelectedItemChanged: (index) {
                    setState(() {
                      _selectedHeight = _minHeight + index;
                    });
                  },
                  selectionOverlay: Container(
                    decoration: const BoxDecoration(
                      border: Border.symmetric(
                        horizontal: BorderSide(
                          color: Colors.black12,
                          width: 1.0,
                        ),
                      ),
                    ),
                  ),
                  children: List.generate(_maxHeight - _minHeight + 1, (index) {
                    final isSelected = (_minHeight + index) == _selectedHeight;
                    return Center(
                      child: Text(
                        l10n.heightCm('${_minHeight + index}'),
                        style: TextStyle(
                          fontSize: isSelected ? 32 : 28, // Bigger font
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: isSelected ? Colors.black : Colors.black26,
                        ),
                      ),
                    );
                  }),
                ),
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
