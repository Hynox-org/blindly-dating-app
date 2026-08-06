import 'package:flutter/material.dart';
import 'package:blindly_dating_app/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/onboarding_provider.dart';
import 'base_onboarding_step_screen.dart';

class TermsScreen extends ConsumerStatefulWidget {
  const TermsScreen({super.key});

  @override
  ConsumerState<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends ConsumerState<TermsScreen> {
  AppLocalizations get l10n => AppLocalizations.of(context);

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
    debugPrint('📜 TermsScreen: BUILD');
    return BaseOnboardingStepScreen(
      title: l10n.communityGuidelines,
      nextLabel: l10n.agreeAndContinue,
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
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            children: [
              TextSpan(text: l10n.termsByContinuePrefix),
              TextSpan(
                text: 'terms',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              TextSpan(text: l10n.termsBridge),
              TextSpan(
                text: l10n.privacyPolicyWord,
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
              l10n.guidelinesIntro,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            _buildGuidelineBox(
              context,
              l10n.beKindTitle,
              l10n.beKindBody,
            ),
            const SizedBox(height: 12),
            _buildGuidelineBox(
              context,
              l10n.stayAuthenticTitle,
              l10n.stayAuthenticBody,
            ),
            const SizedBox(height: 12),
            _buildGuidelineBox(
              context,
              l10n.prioritizeSafetyTitle,
              l10n.prioritizeSafetyBody,
            ),
            const SizedBox(height: 12),
            _buildGuidelineBox(
              context,
              l10n.noHateTitle,
              l10n.noHateBody,
            ),
            const SizedBox(height: 12),
            _buildGuidelineBox(
              context,
              l10n.helpKeepSafeTitle,
              l10n.helpKeepSafeBody,
            ),
            const SizedBox(height: 12),
            _buildGuidelineBox(
              context,
              l10n.genuineIntentTitle,
              l10n.genuineIntentBody,
            ),
            const SizedBox(height: 12),
            _buildGuidelineBox(
              context,
              l10n.adultsOnlyTitle,
              l10n.adultsOnlyBody,
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
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
