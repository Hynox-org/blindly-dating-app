import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/onboarding_provider.dart';
import 'base_onboarding_step_screen.dart';

class TermsScreen extends ConsumerStatefulWidget {
  const TermsScreen({super.key});

  @override
  ConsumerState<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends ConsumerState<TermsScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolledToBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;

    // Threshold to consider "bottom" (e.g., 20 pixels from bottom)
    if (currentScroll >= (maxScroll - 20)) {
      if (!_isScrolledToBottom) {
        setState(() {
          _isScrolledToBottom = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseOnboardingStepScreen(
      title: 'Community guidelines',
      nextLabel: 'Agree & Continue',
      // Enable only if scrolled to bottom
      isNextEnabled: _isScrolledToBottom,
      onNext: () {
        ref.read(onboardingProvider.notifier).completeStep('terms_accept');
      },
      // Fixed footer content
      // add padding to the footer
      footer: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            children: [
              const TextSpan(text: 'By Continue, you agree to our '),
              TextSpan(
                text: 'terms',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const TextSpan(text: '. See how we use your data in our '),
              TextSpan(
                text: 'privacy policy',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const TextSpan(text: '.'),
            ],
          ),
        ),
      ),
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Text(
              'Welcome to our community! To ensure safe and positive experience for every one, we ask that you follow simple guidelines.',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            _buildGuidelineBox(
              context,
              'Be kind and respectful',
              'Treat others as you would like to be treated. We\'re all in together to create welcoming environment.',
            ),
            const SizedBox(height: 12),
            _buildGuidelineBox(
              context,
              'Stay authentic',
              'Be genuine in your profile and interactions. We value authenticity and real connections.',
            ),
            const SizedBox(height: 12),
            _buildGuidelineBox(
              context,
              'Prioritize safety',
              'Do not share sensitive and personal information. Protect your self and others in the community.',
            ),
            const SizedBox(height: 12),
            _buildGuidelineBox(
              context,
              'No hate speech',
              'Harassment, bullying and illegal contents are not tolerate here. Help us keep in community safe.',
            ),
            const SizedBox(height: 12),
            _buildGuidelineBox(
              context,
              'Help keep us safe',
              'If you see something that violate our guideline. Please report it. Your help is invaluable.',
            ),
            const SizedBox(height: 12),
            _buildGuidelineBox(
              context,
              'Date with genuine intentions',
              'We\'re here for real connections. We don\'t allow catfish or coercion. We don\'t allow scams, impersonation, or any kind of manipulation for personal or financial gain.',
            ),
            const SizedBox(height: 12),
            _buildGuidelineBox(
              context,
              'Adults only',
              'You must be 18 years of age or older to use Blindly. This also means we don\'t allow photos of unaccompanied or unclothed minors, including photos of your younger self--no matter how adorable you were back then.',
            ),
            const SizedBox(height: 24),
            // Footer text moved to fixed param
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildGuidelineBox(
    BuildContext context,
    String title,
    String description,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
