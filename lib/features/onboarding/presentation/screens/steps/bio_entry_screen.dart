import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/onboarding_provider.dart';
import '../../../../auth/providers/auth_providers.dart';
import '../../../data/repositories/onboarding_repository.dart';
import 'base_onboarding_step_screen.dart';

class BioEntryScreen extends ConsumerStatefulWidget {
  const BioEntryScreen({super.key});

  @override
  ConsumerState<BioEntryScreen> createState() => _BioEntryScreenState();
}

class _BioEntryScreenState extends ConsumerState<BioEntryScreen> {
  final _controller = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleNext() async {
    final bio = _controller.text.trim();
    // Use onboarding repository to save bio
    setState(() => _isSaving = true);

    try {
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user != null) {
        await ref.read(onboardingRepositoryProvider).updateProfileData(
          user.id,
          {'bio': bio},
        );
      }
      if (mounted) {
        ref.read(onboardingProvider.notifier).completeStep('bio_entry');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save bio: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _handleSkip() {
    ref.read(onboardingProvider.notifier).skipStep('bio_entry');
  }

  @override
  Widget build(BuildContext context) {
    return BaseOnboardingStepScreen(
      title: 'About You',
      showBackButton: true,
      showSkipButton: false, // We use header action for skip
      headerAction: TextButton(
        onPressed: _handleSkip,
        child: const Text(
          'Skip',
          style: TextStyle(
            color: Colors.black, // Or app theme color
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      nextLabel: 'Continue',
      isNextEnabled: _controller.text.trim().length >= 10 && !_isSaving,
      onNext: _handleNext,
      isLoading: _isSaving,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Don't be shy! This is your chance to share your personality with a short bio.",
            style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _controller,
            maxLines: 8,
            maxLength: 300,
            decoration: InputDecoration(
              hintText: 'Text Here.....',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(color: Theme.of(context).primaryColor),
              ),
              counterText:
                  "", // We will build custom counter if needed, or rely on default.
              // Image has counter outside. TextField 'maxLength' puts it below.
              // To match image perfectly (counter aligned right below box), default is OK but might be too close or inside if not careful.
              // Let's use buildCounter to customize or just default.
              // Default puts it in helper text area.
            ),
          ),
          // Custom counter or default?
          // If I hide counterText, I can show it manually.
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${_controller.text.length}/300',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
