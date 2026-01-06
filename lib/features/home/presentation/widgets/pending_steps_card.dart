import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../onboarding/data/repositories/onboarding_repository.dart';
import '../../../auth/providers/auth_providers.dart';
// Import step screens directly
import '../../../profile/presentation/screens/setup_steps/interests_select_screen.dart';
import '../../../profile/presentation/screens/setup_steps/lifestyle_prefs_screen.dart';
import '../../../profile/presentation/screens/setup_steps/bio_entry_screen.dart';
import '../../../profile/presentation/screens/setup_steps/gov_id_screen.dart';
import '../../../profile/presentation/screens/setup_steps/voice_intro_screen.dart';
import '../../../profile/presentation/screens/setup_steps/profile_prompts_screen.dart';
import '../../../profile/presentation/screens/setup_steps/selfie_verification_screen.dart';
// Add others as needed

class PendingStepsCard extends ConsumerStatefulWidget {
  const PendingStepsCard({super.key});

  @override
  ConsumerState<PendingStepsCard> createState() => _PendingStepsCardState();
}

class _PendingStepsCardState extends ConsumerState<PendingStepsCard> {
  List<String> _skippedSteps = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSkippedSteps();
  }

  Future<void> _fetchSkippedSteps() async {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) return;

    final profile = await ref
        .read(onboardingRepositoryProvider)
        .getProfileRaw(user.id);

    if (profile != null && profile['steps_progress'] != null) {
      final progressMap = Map<String, dynamic>.from(profile['steps_progress']);
      final skippedList = progressMap.entries
          .where((entry) => entry.value == 'skipped')
          .map((entry) => entry.key)
          .toList();

      if (mounted) {
        setState(() {
          _skippedSteps = skippedList;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const SizedBox.shrink();
    if (_skippedSteps.isEmpty) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.all(16),
      color: Colors.orange.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.orange.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange.shade800,
                ),
                const SizedBox(width: 8),
                Text(
                  'Complete your profile',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.orange.shade900,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'You skipped some steps. Complete them to get the most out of the app.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _skippedSteps.map((stepKey) {
                return ActionChip(
                  label: Text(_formatStepName(stepKey)),
                  onPressed: () {
                    Navigator.of(context)
                        .push(
                          MaterialPageRoute(
                            builder: (_) => _getScreenForStep(stepKey),
                          ),
                        )
                        .then((_) => _fetchSkippedSteps()); // Refresh on return
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  String _formatStepName(String key) {
    // Simple formatter, ideally fetch name from config or use a map
    return key
        .split('_')
        .map(
          (word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1)}'
              : '',
        )
        .join(' ');
  }

  Widget _getScreenForStep(String stepKey) {
    // Map of keys to screens
    switch (stepKey) {
      case 'bio_entry':
        return const BioEntryScreen();
      case 'interests_select':
        return const InterestsSelectScreen();
      case 'lifestyle_prefs':
        return const LifestylePrefsScreen();
      case 'gov_id_optional':
        return const GovernmentIdVerificationScreen();
      case 'voice_intro':
        return const VoiceIntroScreen();
      case 'profile_prompts':
        return const ProfilePromptsScreen();
      case 'selfie_capture':
        return const SelfieVerificationScreen();
      // Add other optional steps mappings here
      default:
        return Scaffold(
          appBar: AppBar(title: Text(_formatStepName(stepKey))),
          body: const Center(child: Text("This step is not yet available.")),
        );
    }
  }
}
