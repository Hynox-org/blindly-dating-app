import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:blindly_dating_app/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:veriff_flutter/veriff_flutter.dart';

import 'package:blindly_dating_app/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:blindly_dating_app/features/onboarding/presentation/screens/steps/base_onboarding_step_screen.dart';

const String _stepKey = 'gov_id_optional';

/// Veriff decides once per session, and that decision covers document, face
/// match and liveness together. These are the only statuses a session can hold.
const Set<String> _retryableStatuses = {
  'declined',
  'resubmission_requested',
  'expired',
  'abandoned',
};

/// Submitted, no verdict yet. Manual review at Veriff can take hours, and the
/// session cannot be reopened, so the only honest thing to show is "waiting".
const Set<String> _pendingStatuses = {'submitted', 'review'};

/// The four states this screen can be in. One enum instead of a step plus two
/// booleans: the states are mutually exclusive, and every visual on the screen
/// is a function of exactly this value.
enum _VerifyState {
  /// Nothing in flight. The only state where verification can be started.
  idle,

  /// Creating the session, inside the Veriff SDK, or -- on entry -- still
  /// working out whether an earlier attempt is in flight. The screen opens
  /// here: offering "Start verification" before that is known lets the user
  /// mint a second session on top of one already in review.
  busy,

  /// Submitted; Veriff has not returned a verdict (or has it in manual review).
  /// Starting again would only reopen a submitted session and error.
  pending,

  /// Approved.
  verified,
}

class GovernmentIdVerificationScreen extends ConsumerStatefulWidget {
  const GovernmentIdVerificationScreen({super.key});

  @override
  ConsumerState<GovernmentIdVerificationScreen> createState() =>
      _GovernmentIdVerificationScreenState();
}

class _GovernmentIdVerificationScreenState
    extends ConsumerState<GovernmentIdVerificationScreen> {
  AppLocalizations get l10n => AppLocalizations.of(context);

  _VerifyState _state = _VerifyState.busy;

  /// Last decision rendered, as `status@updated_at`. The timestamp matters: a
  /// retry that ends on the same verdict as the previous one must still be
  /// reported, or the user finishes the whole flow and the screen does nothing.
  String? _lastHandledDecision;

  StreamSubscription<List<Map<String, dynamic>>>? _statusSub;

  bool get _isVerified => _state == _VerifyState.verified;
  bool get _canStart => _state == _VerifyState.idle;

  @override
  void initState() {
    super.initState();
    _watchDecision();
    _resolveExistingAttempt();
  }

  /// Asks Veriff about any earlier attempt before the screen becomes usable.
  /// Covers every way a result can be lost: app killed mid-flow, SDK reporting
  /// 'canceled' after a real submission, or a webhook that never arrived --
  /// the last of which leaves the row on 'created' indefinitely while the
  /// attempt sits in manual review.
  Future<void> _resolveExistingAttempt() async {
    await _pullDecision();
    // Anything conclusive arrived through the stream and already moved us on.
    // Still busy means there is nothing in flight, so let the user start.
    if (_state == _VerifyState.busy) _setState(_VerifyState.idle);
  }

  @override
  void dispose() {
    _statusSub?.cancel();
    super.dispose();
  }

  void _setState(_VerifyState next) {
    if (mounted) setState(() => _state = next);
  }

  // ---------------------------------------------------------------- decision

  /// Subscribes to this profile's latest Veriff row. The webhook and the
  /// `veriff-decision` pull both write it, so whichever lands first renders
  /// here and the second is a no-op.
  Future<void> _watchDecision() async {
    final authUserId = Supabase.instance.client.auth.currentUser?.id;
    if (authUserId == null) return;

    try {
      final profile = await Supabase.instance.client
          .from('profiles')
          .select('id, is_verified')
          .eq('user_id', authUserId)
          .maybeSingle();

      if (profile == null) {
        debugPrint('gov_id: no profile for the signed-in user');
        return;
      }

      if (profile['is_verified'] == true) {
        _setState(_VerifyState.verified);
        if (mounted) _showToast(l10n.alreadyVerified);
        return; // Nothing left to watch.
      }

      _statusSub = Supabase.instance.client
          .from('veriff_verifications')
          .stream(primaryKey: ['id'])
          .eq('profile_id', profile['id'])
          .order('created_at', ascending: false)
          .limit(1)
          .listen((rows) {
            if (!mounted) return;
            // No session ever created: nothing to wait on.
            if (rows.isEmpty) {
              if (_state == _VerifyState.busy) _setState(_VerifyState.idle);
              return;
            }
            _handleDecision(rows.first);
          });
    } catch (e) {
      debugPrint('gov_id: decision stream failed: $e');
    }
  }

  void _handleDecision(Map<String, dynamic> row) {
    final String status = row['status'] ?? 'created';

    final String decision = '$status@${row['updated_at']}';
    if (_lastHandledDecision == decision) return;
    _lastHandledDecision = decision;

    if (status == 'approved') {
      _setState(_VerifyState.verified);
      _showToast(l10n.verificationSuccessful);
      return;
    }

    // Submitted, or in manual review at Veriff's end. Nothing the user can do;
    // the stream stays open and fires again on the final decision.
    if (_pendingStatuses.contains(status)) {
      _setState(_VerifyState.pending);
      _showToast(l10n.verificationSubmitted);
      return;
    }

    // Declined, or retryable. Either way the user stays here and can start
    // again -- a resubmission deliberately reuses the original session.
    if (_retryableStatuses.contains(status)) {
      _setState(_VerifyState.idle);
      _showFailureDialog(_failureReason(row), code: row['decision_code']);
    }
  }

  /// Veriff's own words for why this failed. `fail_reason` is the column the
  /// webhook fills, but Veriff leaves `reason` null on plenty of decisions and
  /// puts the detail in the decision payload instead -- so fall back to it
  /// before giving up and showing something generic.
  String _failureReason(Map<String, dynamic> row) {
    final direct = (row['fail_reason'] as String?)?.trim();
    if (direct != null && direct.isNotEmpty) return direct;

    final payload = row['meta_payload'];
    if (payload is Map) {
      final verification = payload['verification'];
      if (verification is Map) {
        for (final key in const ['reason', 'reasonCode', 'decisionReason']) {
          final value = verification[key]?.toString().trim();
          if (value != null && value.isNotEmpty) return value;
        }
        // Per-document notes, when Veriff attached any.
        final comments = verification['comments'];
        if (comments is List && comments.isNotEmpty) {
          final texts = comments
              .map((c) => c is Map ? c['comment']?.toString() : c?.toString())
              .whereType<String>()
              .where((c) => c.trim().isNotEmpty);
          if (texts.isNotEmpty) return texts.join('\n');
        }
      }
    }

    return l10n.documentNotVerified;
  }

  /// Asks Veriff for this user's decision directly instead of waiting on the
  /// webhook, whose URL lives in Veriff's Customer Portal and is therefore a
  /// single point of failure outside this codebase. Writes the same row.
  ///
  /// Also records whether the session was merely opened or actually submitted,
  /// which is the only way that is learnt when the portal's webhook URL is
  /// unset. Takes ~10s: it polls, since Veriff does not decide instantly.
  ///
  /// Left unawaited after the SDK returns -- the user is free to leave, and
  /// Veriff delays a resubmission verdict by ~5 min for SDK sessions.
  Future<void> _pullDecision() async {
    try {
      final r = await Supabase.instance.client.functions.invoke(
        'veriff-decision',
      );
      debugPrint('gov_id: veriff-decision -> ${r.data}');
    } catch (e) {
      debugPrint('gov_id: veriff-decision failed, webhook will cover it: $e');
    }
  }

  // ------------------------------------------------------------- veriff flow

  Future<void> _startVeriffFlow() async {
    // A retry can end on the same verdict as the last one; clear the guard so
    // the outcome is shown again.
    _lastHandledDecision = null;
    _setState(_VerifyState.busy);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception(l10n.userNotLoggedIn);

      final sessionUrl = await _createSession(user);
      final result = await Veriff().start(Configuration(sessionUrl));

      // The SDK owns the screen for minutes; the user can background the app
      // or pop this route in the meantime.
      if (!mounted) return;

      switch (result.status) {
        case Status.done:
          _setState(_VerifyState.pending);
          _showToast(l10n.verificationSubmitted);
          unawaited(_pullDecision());
        case Status.canceled:
          // 'canceled' is not proof nothing was submitted -- the SDK reports it
          // when the user dismisses the final screen too. Ask Veriff either way.
          _setState(_VerifyState.idle);
          unawaited(_pullDecision());
        default:
          debugPrint('gov_id: Veriff SDK error: ${result.error}');
          _setState(_VerifyState.idle);
          _showToast(l10n.somethingWentWrong, isError: true);
      }
    } catch (e, stack) {
      debugPrint('gov_id: could not start verification: $e\n$stack');
      if (!mounted) return;
      _setState(_VerifyState.idle);
      _showToast(l10n.somethingWentWrong, isError: true);
    }
  }

  /// Returns a Veriff session URL. The edge function reuses a live session
  /// where that is correct and mints a fresh one otherwise.
  Future<String> _createSession(User user) async {
    final response = await Supabase.instance.client.functions.invoke(
      'create-veriff-session',
      body: {
        'firstName': user.userMetadata?['first_name'] ?? '',
        'lastName': user.userMetadata?['last_name'] ?? '',
      },
    );

    final raw = response.data;
    final data = raw is String
        ? Map<String, dynamic>.from(jsonDecode(raw))
        : Map<String, dynamic>.from(raw ?? {});

    if (response.status != 200 || data.containsKey('error')) {
      throw Exception(data['error'] ?? 'create-veriff-session ${response.status}');
    }

    final url = data['url'];
    if (url == null) throw Exception('create-veriff-session returned no URL');
    return url as String;
  }

  // ----------------------------------------------------------------- actions

  /// Inside the onboarding shell there is no route to pop -- the shell swaps
  /// the step widget -- so the provider drives navigation. Pushed as a route
  /// (home's pending-steps card, profile edit) the provider changes nothing on
  /// screen, and without this the buttons are dead and the user is trapped.
  bool _popIfPushed() {
    if (!Navigator.of(context).canPop()) return false;
    Navigator.pop(context);
    return true;
  }

  Future<void> _onSkip() async {
    final notifier = ref.read(onboardingProvider.notifier);
    // Verified users must not be recorded as 'skipped' -- the home screen lists
    // every skipped step, so a verified profile would nag about ID forever.
    // Awaited so that card, which refreshes when this route pops, reads the new
    // status rather than the old one.
    if (_isVerified) {
      await notifier.completeStep(_stepKey);
    } else {
      await notifier.skipStep(_stepKey);
    }
    if (mounted) _popIfPushed();
  }

  void _onBack() {
    if (_popIfPushed()) return;
    ref.read(onboardingProvider.notifier).goToPreviousStep();
  }

  // -------------------------------------------------------------- status copy

  /// Every state-dependent visual in one place, so the widget tree below stays
  /// free of nested conditionals.
  ({IconData icon, Color color, String label}) _statusVisual(
    ColorScheme scheme,
  ) => switch (_state) {
    _VerifyState.verified => (
      icon: Icons.check_circle,
      color: Colors.green.shade600,
      label: l10n.verificationComplete,
    ),
    _VerifyState.pending => (
      icon: Icons.hourglass_top_rounded,
      color: Colors.orange.shade700,
      label: l10n.reviewingYourPhotos,
    ),
    _ => (
      icon: Icons.camera_alt_rounded,
      color: scheme.primary,
      label: l10n.tapToScanDocument,
    ),
  };

  String get _headline => _isVerified ? l10n.youAreVerified : l10n.quickCheckSafe;

  String get _subhead => switch (_state) {
    _VerifyState.verified => l10n.identityConfirmed,
    _VerifyState.pending => l10n.verificationInProgress,
    _ => l10n.veriffExplainer,
  };

  String get _primaryButtonLabel => switch (_state) {
    _VerifyState.verified => l10n.verified,
    _VerifyState.pending => l10n.reviewingYourPhotos,
    _VerifyState.busy => l10n.processing,
    _VerifyState.idle => l10n.startVerification,
  };

  // --------------------------------------------------------------------- UI

  @override
  Widget build(BuildContext context) {
    return BaseOnboardingStepScreen(
      title: l10n.verifyYourProfile,
      showBackButton: false,
      onBack: _onBack,
      showNextButton: false,
      showSkipButton: false,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildBadge(),
                  const SizedBox(height: 24),
                  _buildHeadline(),
                  const SizedBox(height: 32),
                  _buildStatusCard(),
                  const SizedBox(height: 32),
                  if (!_isVerified) _buildGuidelines(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          _buildPrimaryButton(),
          _buildFooterNav(),
        ],
      ),
    );
  }

  Widget _buildBadge() {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: _isVerified ? Colors.green.shade100 : scheme.primary,
        shape: BoxShape.circle,
      ),
      child: Icon(
        _isVerified ? Icons.check_circle_rounded : Icons.shield_outlined,
        size: 40,
        color: _isVerified ? Colors.green.shade700 : scheme.onPrimary,
      ),
    );
  }

  Widget _buildHeadline() {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          _headline,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _subhead,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: scheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  /// The tappable card: start button when idle, spinner while busy, and a
  /// read-only status otherwise.
  Widget _buildStatusCard() {
    final scheme = Theme.of(context).colorScheme;
    final visual = _statusVisual(scheme);

    return GestureDetector(
      onTap: _canStart ? _startVeriffFlow : null,
      child: Container(
        height: 220,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: _isVerified
              ? Colors.green.shade50.withValues(alpha: 0.5)
              : scheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _canStart
                ? scheme.primary.withValues(alpha: 0.5)
                : visual.color.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        child: Center(
          child: _state == _VerifyState.busy
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      l10n.verifyingResults,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(visual.icon, size: 40, color: visual.color),
                    const SizedBox(height: 16),
                    Text(
                      visual.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: visual.color,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (!_isVerified) ...[
                      const SizedBox(height: 8),
                      Text(
                        l10n.poweredByVeriff,
                        style: TextStyle(
                          color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildGuidelines() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGuidelineItem(l10n.prepareIdCard),
          const SizedBox(height: 16),
          _buildGuidelineItem(l10n.ensureGoodLighting),
          const SizedBox(height: 16),
          _buildGuidelineItem(l10n.readyForSelfie),
        ],
      ),
    );
  }

  Widget _buildGuidelineItem(String text) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(Icons.circle, color: scheme.primary, size: 16),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton() {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _canStart ? _startVeriffFlow : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: scheme.primary,
            foregroundColor: scheme.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(
            _primaryButtonLabel,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  /// Back and Skip/Next. Never disabled while a decision is pending -- waiting
  /// on Veriff must not cost the user their way off this screen.
  Widget _buildFooterNav() {
    final scheme = Theme.of(context).colorScheme;
    final busy = _state == _VerifyState.busy;
    final labelStyle = TextStyle(
      color: scheme.onSurface,
      fontSize: 16,
      fontWeight: FontWeight.w600,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton.icon(
          onPressed: busy ? null : _onBack,
          icon: Icon(Icons.arrow_back, size: 20, color: scheme.onSurface),
          label: Text(l10n.back, style: labelStyle),
        ),
        TextButton(
          onPressed: busy ? null : _onSkip,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_isVerified ? l10n.next : l10n.skip, style: labelStyle),
              const SizedBox(width: 8),
              Icon(
                _isVerified
                    ? Icons.arrow_forward_rounded
                    : Icons.skip_next_rounded,
                size: 24,
                color: scheme.onSurface,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------- feedback UI

  void _showFailureDialog(String reason, {int? code}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange,
              size: 28,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(l10n.verificationFailed)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.veriffReason),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    reason,
                    style: TextStyle(
                      color: Colors.brown.shade800,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  // Veriff's own code, so support can match this screen to the
                  // session without asking the user to describe it.
                  if (code != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        '#$code',
                        style: TextStyle(
                          color: Colors.brown.shade400,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(l10n.tryClearerImage),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.tryAgain,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showToast(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
