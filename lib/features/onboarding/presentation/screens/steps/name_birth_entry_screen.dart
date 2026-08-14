import 'package:flutter/material.dart';
import 'package:blindly_dating_app/l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/onboarding_provider.dart';
import '../../../../auth/providers/auth_providers.dart';
import '../../../data/repositories/onboarding_repository.dart';
import 'base_onboarding_step_screen.dart';
import '../../../../../core/utils/custom_popups.dart';
import 'package:blindly_dating_app/features/profile/provider/profile_provider.dart';

/// Whole years elapsed between [birthDate] and [now].
int ageOn(DateTime birthDate, DateTime now) {
  final hadBirthday =
      now.month > birthDate.month ||
      (now.month == birthDate.month && now.day >= birthDate.day);
  return now.year - birthDate.year - (hadBirthday ? 0 : 1);
}

/// The date these three fields describe, or null if they do not describe a
/// real date that belongs to someone eligible to be here.
///
/// Dart's DateTime rolls invalid dates forward rather than rejecting them --
/// DateTime(2000, 2, 30) is the 1st of March -- so the parts are compared back
/// against what was typed. Without that, "31/02/2000" was silently stored as a
/// birthday in March.
DateTime? parseBirthDate(
  String day,
  String month,
  String year, {
  required DateTime now,
}) {
  final d = int.tryParse(day);
  final m = int.tryParse(month);
  final y = int.tryParse(year);
  if (d == null || m == null || y == null) return null;
  if (y < 1900) return null;

  final date = DateTime(y, m, d);
  if (date.year != y || date.month != m || date.day != d) return null;
  if (date.isAfter(now)) return null;
  if (ageOn(date, now) < 18) return null;

  return date;
}

class NameBirthEntryScreen extends ConsumerStatefulWidget {
  final bool isEditMode;

  const NameBirthEntryScreen({super.key, this.isEditMode = false});

  @override
  ConsumerState<NameBirthEntryScreen> createState() =>
      _NameBirthEntryScreenState();
}

class _NameBirthEntryScreenState extends ConsumerState<NameBirthEntryScreen> {
  AppLocalizations get l10n => AppLocalizations.of(context);

  final _nameController = TextEditingController();
  final _dayController = TextEditingController();
  final _monthController = TextEditingController();
  final _yearController = TextEditingController();

  final _dayFocus = FocusNode();
  final _monthFocus = FocusNode();
  final _yearFocus = FocusNode();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fetchExistingData();
    _nameController.addListener(_onInputChanged);
    _dayController.addListener(_onInputChanged);
    _monthController.addListener(_onInputChanged);
    _yearController.addListener(_onInputChanged);
  }

  void _onInputChanged() {
    setState(() {});
  }

  Future<void> _fetchExistingData() async {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user != null) {
      final repo = ref.read(onboardingRepositoryProvider);
      final profile = await repo.getProfileRaw(user.id);

      if (profile != null) {
        if (mounted) {
          setState(() {
            if (profile['display_name'] != null) {
              _nameController.text = profile['display_name'] as String;
            }
            if (profile['birth_date'] != null) {
              final dateStr = profile['birth_date'] as String;
              final parts = dateStr.split('-');
              if (parts.length == 3) {
                // Assuming YYYY-MM-DD from DB
                _yearController.text = parts[0];
                _monthController.text = parts[1];
                _dayController.text = parts[2];
              }
            }
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    _dayFocus.dispose();
    _monthFocus.dispose();
    _yearFocus.dispose();
    super.dispose();
  }

  DateTime? _getValidDate() => parseBirthDate(
    _dayController.text,
    _monthController.text,
    _yearController.text,
    now: DateTime.now(),
  );

  Future<void> _handleNext() async {
    final name = _nameController.text.trim();
    final validDate = _getValidDate();

    if (name.isEmpty || validDate == null) return;

    setState(() => _isSaving = true);

    try {
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user != null) {
        final dateString =
            "${validDate.year}-${validDate.month.toString().padLeft(2, '0')}-${validDate.day.toString().padLeft(2, '0')}";

        await ref.read(onboardingRepositoryProvider).updateProfileData(
          user.id,
          {'display_name': name, 'birth_date': dateString},
        );
      }

      if (widget.isEditMode) {
        if (mounted) {
          final currentProfile = ref.read(currentUserProfileProvider).value;
          if (currentProfile != null) {
            final updatedProfile = currentProfile.copyWith(
              name: name,
              age: ageOn(validDate, DateTime.now()),
            );
            ref
                .read(currentUserProfileProvider.notifier)
                .updateProfile(updatedProfile);
          }
          Navigator.pop(context);
        }
      } else {
        await ref
            .read(onboardingProvider.notifier)
            .completeStep('name_birth_entry');
      }
    } catch (e) {
      if (mounted) {
        showErrorPopup(context, l10n.failedToSaveData('$e'));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Determine validity
    final nameValid = _nameController.text.trim().isNotEmpty;
    final dateValid = _getValidDate() != null;

    // Only enable if name is present AND date is valid (18+)
    bool isNextEnabled = nameValid && dateValid && !_isSaving;

    return BaseOnboardingStepScreen(
      title: l10n.letsIntroduceYou,
      showBackButton: true,
      nextLabel: widget.isEditMode ? l10n.update : l10n.continueLabel,
      isNextEnabled: isNextEnabled,
      isLoading: _isSaving,
      onNext: _handleNext,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subtitle 1
            Text(
              l10n.needNameForProfile,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withOpacity(0.54),
              ),
            ),
            const SizedBox(height: 24),

            // Name Label
            Text(
              l10n.nameLabel,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withOpacity(0.87),
              ),
            ),
            const SizedBox(height: 8),

            // Name Input
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                hintText: l10n.enterYourName,
                hintStyle: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.4),
                ),
                filled: true,
                fillColor: theme
                    .colorScheme
                    .surface, // Matches app theme surface (likely F5F5F5 or similar)
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.12),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.primaryColor),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Subtitle 2
            Text(
              l10n.needDobForProfile,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withOpacity(0.54),
              ),
            ),
            const SizedBox(height: 24),

            // DOB Label
            Text(
              l10n.dateOfBirth,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withOpacity(0.87),
              ),
            ),
            const SizedBox(height: 8),

            // Date Input Row
            Row(
              children: [
                Expanded(
                  child: _buildDateInput(
                    context: context,
                    controller: _dayController,
                    hint: "DD",
                    focusNode: _dayFocus,
                    nextFocus: _monthFocus,
                    maxLength: 2,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDateInput(
                    context: context,
                    controller: _monthController,
                    hint: "MM",
                    focusNode: _monthFocus,
                    nextFocus: _yearFocus,
                    prevFocus: _dayFocus,
                    maxLength: 2,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2, // Give year slightly more space if needed, or equal
                  child: _buildDateInput(
                    context: context,
                    controller: _yearController,
                    hint: "YYYY",
                    focusNode: _yearFocus,
                    prevFocus: _monthFocus,
                    maxLength: 4,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Text(
              l10n.birthdayNote,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withOpacity(0.54),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateInput({
    required BuildContext context,
    required TextEditingController controller,
    required String hint,
    required FocusNode focusNode,
    FocusNode? nextFocus,
    FocusNode? prevFocus,
    required int maxLength,
  }) {
    final theme = Theme.of(context);

    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(maxLength),
      ],
      onChanged: (value) {
        // Auto-focus next ONLY when filled
        if (value.length == maxLength && nextFocus != null) {
          nextFocus.requestFocus();
        }
        // Removed auto-backtrack on empty to prevent annoying jumps during editing

        // State update handled by listener init
      },
      decoration: InputDecoration(
        counterText: "", // Hide character counter
        hintText: hint,
        hintStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
        ),
        filled: true,
        fillColor: theme.colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.primaryColor),
        ),
      ),
    );
  }
}
