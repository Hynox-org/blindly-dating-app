import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/connection_mode_provider.dart';
import '../../povider/filter_provider.dart';
import '../../../onboarding/domain/models/interest_chip_model.dart';

class FilterScreen extends ConsumerWidget {
  const FilterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final connectionMode = ref.watch(connectionModeProvider);
    final filterState = ref.watch(filterProvider);
    final filterNotifier = ref.read(filterProvider.notifier);

    final isDating = connectionMode.toLowerCase() == 'date';
    final title = isDating ? 'Dating Preference' : 'BFF Preference';

    final interestsAsync = ref.watch(interestsProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: theme.colorScheme.onSurface,
            size: 22,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Who would you like to date?'),
            const SizedBox(height: 12),
            _buildFilterCard(
              context,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    filterState.genderPreference,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 20,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ],
              ),
              onTap: () => _showGenderPicker(context, ref),
            ),
            const SizedBox(height: 28),

            _buildSectionTitle('Age range?'),
            const SizedBox(height: 12),
            _buildFilterCard(
              context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${filterState.minAge.toInt()} years old',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SliderTheme(
                    data: _getSliderTheme(context),
                    child: Slider(
                      value: filterState.minAge,
                      min: 18,
                      max: 80,
                      divisions: 62,
                      onChanged: (value) {
                        filterNotifier.setAgeRange(
                          value,
                          filterState.maxAge < value
                              ? value
                              : filterState.maxAge,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            _buildSectionTitle('How far away they are?'),
            const SizedBox(height: 12),
            _buildFilterCard(
              context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${filterState.distanceLimit.toInt()} kilometers away',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 20,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  SliderTheme(
                    data: _getSliderTheme(context),
                    child: Slider(
                      value: filterState.distanceLimit,
                      min: 1,
                      max: 200,
                      divisions: 199,
                      onChanged: (value) {
                        filterNotifier.setDistanceLimit(value);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            _buildSectionTitle('Your interests?'),
            const SizedBox(height: 12),
            interestsAsync.when(
              data: (interests) =>
                  _buildInterestsCard(context, ref, filterState, interests),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error loading interests: $e'),
            ),
            const SizedBox(height: 28),

            _buildSectionTitle('Which language do you know?'),
            const SizedBox(height: 12),
            _buildFilterCard(
              context,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      filterState.selectedLanguages.isEmpty
                          ? 'Select languages'
                          : filterState.selectedLanguages.join(', '),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        overflow: TextOverflow.ellipsis,
                      ),
                      maxLines: 1,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 20,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ],
              ),
              onTap: () => _showMultiSelectPicker(
                context,
                ref,
                title: 'Languages',
                options: [
                  'English',
                  'Hindi',
                  'Spanish',
                  'French',
                  'German',
                  'Italian',
                  'Portuguese',
                  'Russian',
                  'Japanese',
                  'Korean',
                  'Chinese',
                  'Arabic',
                  'Turkish',
                ],
                selectedValues: filterState.selectedLanguages,
                onToggle: (value) => filterNotifier.toggleLanguage(value),
              ),
            ),
            const SizedBox(height: 28),

            _buildSectionTitle('Religion'),
            const SizedBox(height: 12),
            _buildFilterCard(
              context,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    filterState.religion ?? 'Select religion',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 20,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ],
              ),
              onTap: () => _showSingleSelectPicker(
                context,
                ref,
                title: 'Religion',
                options: [
                  'Hindu',
                  'Christian',
                  'Muslim',
                  'Sikh',
                  'Jain',
                  'Buddhist',
                  'Atheist',
                  'Agnostic',
                  'Spiritual',
                  'Other',
                ],
                selectedValue: filterState.religion,
                onSelect: (value) => filterNotifier.setReligion(value),
              ),
            ),
            const SizedBox(height: 28),

            _buildSectionTitle('Relationship type?'),
            const SizedBox(height: 12),
            _buildFilterCard(
              context,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    filterState.relationshipType ?? 'Select type',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 20,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ],
              ),
              onTap: () => _showSingleSelectPicker(
                context,
                ref,
                title: 'Relationship Type',
                options: [
                  'Monogamy',
                  'Polyamory',
                  'Open Relationship',
                  'Short Term',
                  'Long Term',
                ],
                selectedValue: filterState.relationshipType,
                onSelect: (value) => filterNotifier.setRelationshipType(value),
              ),
            ),
            const SizedBox(height: 28),

            _buildSectionTitle('Sexual orientation?'),
            const SizedBox(height: 12),
            _buildFilterCard(
              context,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    filterState.sexualOrientation ?? 'Select orientation',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 20,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ],
              ),
              onTap: () => _showSingleSelectPicker(
                context,
                ref,
                title: 'Sexual Orientation',
                options: [
                  'Straight',
                  'Gay',
                  'Lesbian',
                  'Bisexual',
                  'Asexual',
                  'Demisexual',
                  'Pansexual',
                  'Queer',
                  'Questioning',
                ],
                selectedValue: filterState.sexualOrientation,
                onSelect: (value) => filterNotifier.setSexualOrientation(value),
              ),
            ),
            const SizedBox(height: 28),

            _buildSectionTitle('Dating intention?'),
            const SizedBox(height: 12),
            _buildFilterCard(
              context,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    filterState.datingIntention ?? 'Select intention',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 20,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ],
              ),
              onTap: () => _showSingleSelectPicker(
                context,
                ref,
                title: 'Dating Intention',
                options: [
                  'Fun, causal dates',
                  'Life partner',
                  'Long-term relationship',
                  'Short-term relationship',
                  'Still figuring it out',
                ],
                selectedValue: filterState.datingIntention,
                onSelect: (value) => filterNotifier.setDatingIntention(value),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: GestureDetector(
                onTap: () {
                  ref.read(filterProvider.notifier).reset();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Filters cleared successfully! ✨'),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: theme.colorScheme.primary,
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.refresh_rounded,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Clear Filters',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildInterestsCard(
    BuildContext context,
    WidgetRef ref,
    FilterState state,
    List<InterestChip> interests,
  ) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.04),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filter by your interests',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              Icon(Icons.add, size: 24, color: theme.colorScheme.onSurface),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: interests.take(15).map<Widget>((interest) {
              final isSelected = state.selectedInterests.contains(
                interest.label,
              );
              return GestureDetector(
                onTap: () => ref
                    .read(filterProvider.notifier)
                    .toggleInterest(interest.label),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withValues(alpha: 0.05),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.01),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    interest.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: theme.colorScheme.onSurface.withValues(alpha: 
                        isSelected ? 1.0 : 0.8,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  SliderThemeData _getSliderTheme(BuildContext context) {
    final theme = Theme.of(context);
    return SliderTheme.of(context).copyWith(
      activeTrackColor: theme.colorScheme.primary,
      inactiveTrackColor: theme.colorScheme.onSurface.withValues(alpha: 0.1),
      thumbColor: theme.colorScheme.secondary,
      overlayColor: theme.colorScheme.secondary.withValues(alpha: 0.1),
      trackHeight: 3,
      thumbShape: const RoundSliderThumbShape(
        enabledThumbRadius: 9,
        elevation: 1,
      ),
      overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
      trackShape: const RoundedRectSliderTrackShape(),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 16,
        letterSpacing: -0.1,
      ),
    );
  }

  Widget _buildFilterCard(
    BuildContext context, {
    required Widget child,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.04),
            width: 1,
          ),
        ),
        child: child,
      ),
    );
  }

  void _showGenderPicker(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Show me',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 24),
                _buildPickerOption(context, ref, 'Women'),
                _buildPickerOption(context, ref, 'Men'),
                _buildPickerOption(context, ref, 'Everyone'),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSingleSelectPicker(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required List<String> options,
    required String? selectedValue,
    required Function(String) onSelect,
  }) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.8,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final option = options[index];
                        final isSelected = selectedValue == option;
                        return ListTile(
                          title: Text(
                            option,
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                          trailing: isSelected
                              ? Icon(
                                  Icons.check_circle,
                                  color: theme.colorScheme.primary,
                                )
                              : null,
                          onTap: () {
                            onSelect(option);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showMultiSelectPicker(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required List<String> options,
    required List<String> selectedValues,
    required Function(String) onToggle,
  }) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.8,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final option = options[index];
                        final isSelected = selectedValues.contains(option);
                        return ListTile(
                          title: Text(
                            option,
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                          trailing: isSelected
                              ? Icon(
                                  Icons.check_circle,
                                  color: theme.colorScheme.primary,
                                )
                              : null,
                          onTap: () {
                            onToggle(option);
                            // Do not pop for multi-select
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPickerOption(
    BuildContext context,
    WidgetRef ref,
    String option,
  ) {
    final isSelected = ref.read(filterProvider).genderPreference == option;
    return ListTile(
      title: Text(
        option,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? Theme.of(context).colorScheme.primary : null,
        ),
      ),
      trailing: isSelected
          ? Icon(
              Icons.check_circle,
              color: Theme.of(context).colorScheme.primary,
            )
          : null,
      onTap: () {
        ref.read(filterProvider.notifier).setGenderPreference(option);
        Navigator.pop(context);
      },
    );
  }
}
