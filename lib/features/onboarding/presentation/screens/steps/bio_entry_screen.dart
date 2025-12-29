import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/onboarding_provider.dart';
import 'base_onboarding_step_screen.dart';

class BioEntryScreen extends ConsumerStatefulWidget {
  const BioEntryScreen({super.key});

  @override
  ConsumerState<BioEntryScreen> createState() => _BioEntryScreenState();
}

class _BioEntryScreenState extends ConsumerState<BioEntryScreen> {
  final _controller = TextEditingController();
  int _characterCount = 0;
  bool _showError = false; // Only for visual indicator

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateCharacterCount);
  }

  void _updateCharacterCount() {
    setState(() {
      _characterCount = _controller.text.length;
      // Clear error indicator when user starts typing
      if (_showError && _controller.text.trim().isNotEmpty) {
        _showError = false;
      }
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_updateCharacterCount);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseOnboardingStepScreen(
      title: 'Describe yourself',
      showBackButton: true,
      onNext: () {
        // Trim whitespace from input
        final trimmedBio = _controller.text.trim();

        // Validation 1: Check if bio is empty (optional field, so show confirmation)
        if (trimmedBio.isEmpty) {
          // Show error indicator
          setState(() {
            _showError = true;
          });
          
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange[700],
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'No Bio',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                content: const Text(
                  'You haven\'t added a bio. A bio helps others get to know you better. Do you want to continue without a bio?',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Add Bio',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      setState(() {
                        _showError = false; // Clear error
                      });
                      ref.read(onboardingProvider.notifier).completeStep('bio_entry');
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
          return;
        }

        // Validation 2: Check minimum length (at least 10 characters for meaningful bio)
        if (trimmedBio.length < 10) {
          // Show error indicator
          setState(() {
            _showError = true;
          });
          
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red[700],
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Bio Too Short',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                content: const Text(
                  'Your bio must be at least 10 characters long to give others a better sense of who you are.',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
          return;
        }

        // Validation 3: Check maximum length (already enforced by maxLength, but double-check)
        if (trimmedBio.length > 500) {
          // Show error indicator
          setState(() {
            _showError = true;
          });
          
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red[700],
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Bio Too Long',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                content: const Text(
                  'Your bio must be 500 characters or less.',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
          return;
        }
        
        // All validations passed - proceed to next step
        setState(() {
          _showError = false;
        });
        ref.read(onboardingProvider.notifier).completeStep('bio_entry');
      },
      showSkipButton: true,
      onSkip: () {
        // No validation needed for skip
        ref.read(onboardingProvider.notifier).skipStep('bio_entry');
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            maxLines: 5,
            maxLength: 500,
            inputFormatters: [
              LengthLimitingTextInputFormatter(500),
            ],
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
              hintText: 'I love long walks on the beach... 🌊',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _showError ? Colors.red : Colors.grey[300]!,
                  width: _showError ? 2 : 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _showError ? Colors.red : const Color(0xFF4A5A3E),
                  width: 2,
                ),
              ),
              counterText: '', // Hide the default counter
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Tell others about your interests, hobbies, and what makes you unique. Emojis are welcome! 😊',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$_characterCount/500',
                style: TextStyle(
                  fontSize: 12,
                  color: _characterCount > 500
                      ? Colors.red
                      : Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
