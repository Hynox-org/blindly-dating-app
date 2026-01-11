import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/onboarding_provider.dart';
import '../../../../auth/providers/auth_providers.dart';
import '../../../data/repositories/onboarding_repository.dart';
import 'base_onboarding_step_screen.dart';
import '../../../../../core/utils/custom_popups.dart';

class NameBirthEntryScreen extends ConsumerStatefulWidget {
  const NameBirthEntryScreen({super.key});

  @override
  ConsumerState<NameBirthEntryScreen> createState() =>
      _NameBirthEntryScreenState();
}

class _NameBirthEntryScreenState extends ConsumerState<NameBirthEntryScreen> {
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

  /// Validates inputs and returns the derived DateTime if valid and age >= 18
  DateTime? _getValidDate() {
    final day = int.tryParse(_dayController.text);
    final month = int.tryParse(_monthController.text);
    final year = int.tryParse(_yearController.text);

    if (day == null || month == null || year == null) return null;
    if (month < 1 || month > 12) return null;
    if (day < 1 || day > 31) return null;
    // Simple check for days in month could be added, but basic 1-31 is often sufficient for initial valid check

    try {
      final date = DateTime(year, month, day);
      // Check age
      final now = DateTime.now();
      final age =
          now.year -
          date.year -
          ((now.month < date.month ||
                  (now.month == date.month && now.day < date.day))
              ? 1
              : 0);

      if (age < 18) return null; // Underage
      if (date.isAfter(now)) return null; // Future date
      if (year < 1900) return null; // Too old

      return date;
    } catch (e) {
      return null; // Invalid date (e.g. Feb 30)
    }
  }

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

      await ref
          .read(onboardingProvider.notifier)
          .completeStep('name_birth_entry');
    } catch (e) {
      if (mounted) {
        showErrorPopup(context, 'Failed to save data: $e');
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
      title: "Let's introduce you!",
      showBackButton: true,
      nextLabel: 'Continue',
      isNextEnabled: isNextEnabled,
      isLoading: _isSaving,
      onNext: _handleNext,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subtitle 1
            Text(
              'We need your Name to create your profile',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withOpacity(0.54),
              ),
            ),
            const SizedBox(height: 24),

            // Name Label
            Text(
              'Name',
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
                hintText: 'Enter Your Name',
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
              'We need your DOB to create your profile',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withOpacity(0.54),
              ),
            ),
            const SizedBox(height: 24),

            // DOB Label
            Text(
              'Date of birth',
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
              'Your birthday is used to calculate your age and will be shown on your profile. Your full name will not be public',
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
