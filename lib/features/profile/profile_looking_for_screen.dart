import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'provider/profile_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/providers/connection_mode_provider.dart';

class ProfileLookingForScreen extends ConsumerStatefulWidget {
  final bool isEditMode;

  const ProfileLookingForScreen({super.key, this.isEditMode = false});

  @override
  ConsumerState<ProfileLookingForScreen> createState() =>
      _ProfileLookingForScreenState();
}

class _ProfileLookingForScreenState
    extends ConsumerState<ProfileLookingForScreen> {
  List<String> _selectedOptions = [];
  bool _isLoading = false;

  final Map<String, List<String>> _modeOptions = {
    'date': [
      'Long-term relationship',
      'Short-term relationship',
      'Long-term, open to short',
      'Short-term, open to long',
      'Casual dating',
      'New friends',
      'Still figuring it out',
    ],
    'bff': [
      'Close friends',
      'Activity partners',
      'Professional networking',
      'Workout buddy',
      'Roommates / Housemates',
      'Travel buddies',
    ],
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  void _loadInitialData() {
    final profileState = ref.read(currentUserProfileProvider);
    profileState.whenData((profile) {
      if (profile.lookingForModes.isNotEmpty) {
        setState(() {
          _selectedOptions = List.from(profile.lookingForModes);
        });
      }
    });
  }

  void _toggleOption(String option) {
    setState(() {
      if (_selectedOptions.contains(option)) {
        _selectedOptions.remove(option);
      } else {
        if (_selectedOptions.length < 3) {
          _selectedOptions.add(option);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You can select up to 3 options')),
          );
        }
      }
    });
  }

  Future<void> _saveOptions() async {
    setState(() => _isLoading = true);

    try {
      final currentMode = ref
          .read(connectionModeProvider)
          .toLowerCase(); // 'date' or 'bff'
      final authId = Supabase.instance.client.auth.currentUser?.id;

      if (authId == null) throw Exception('No authenticated user');

      // 1. Get profile ID
      final profileResponse = await Supabase.instance.client
          .from('profiles')
          .select('id')
          .eq('user_id', authId)
          .single();

      final profileId = profileResponse['id'];

      // 2. Update profile_modes
      await Supabase.instance.client
          .from('profile_modes')
          .update({'looking_for': _selectedOptions})
          .eq('profile_id', profileId)
          .eq('mode', currentMode);

      // Refresh provider
      ref.invalidate(currentUserProfileProvider);

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving preferences: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentMode = ref
        .watch(connectionModeProvider)
        .toLowerCase(); // 'date' or 'bff'
    final theme = Theme.of(context);
    final options = _modeOptions[currentMode] ?? _modeOptions['date']!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What are you looking for?',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'You can select up to 3 options for the current mode ($currentMode).',
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ...options.map((option) => _buildOptionRow(option, theme)),
                  const SizedBox(height: 100), // padding for button
                ],
              ),
            ),
          ),

          if (_isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),

          // Save Button fixed at bottom
          Positioned(
            bottom: 32,
            left: 24,
            right: 24,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveOptions,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Save',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionRow(String option, ThemeData theme) {
    final isSelected = _selectedOptions.contains(option);

    return GestureDetector(
      onTap: () => _toggleOption(option),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: theme.dividerColor.withValues(alpha: 0.2)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              option,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? theme.primaryColor
                    : theme.colorScheme.onSurface,
              ),
            ),
            if (isSelected) Icon(Icons.check, color: theme.primaryColor),
          ],
        ),
      ),
    );
  }
}
