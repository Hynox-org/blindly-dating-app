import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../onboarding/data/repositories/onboarding_repository.dart';
import '../../onboarding/domain/models/interest_chip_model.dart';

class FilterState {
  final String genderPreference; // 'Women', 'Men', 'Everyone'
  final double minAge;
  final double maxAge; // Age Range
  final double distanceLimit; // in kilometers
  final List<String> selectedInterests;

  // New Filters
  final List<String> selectedLanguages;
  final String? religion;
  final String? relationshipType;
  final String? sexualOrientation;
  final String? datingIntention;

  FilterState({
    required this.genderPreference,
    required this.minAge,
    required this.maxAge,
    required this.distanceLimit,
    required this.selectedInterests,
    this.selectedLanguages = const [],
    this.religion,
    this.relationshipType,
    this.sexualOrientation,
    this.datingIntention,
  });

  FilterState copyWith({
    String? genderPreference,
    double? minAge,
    double? maxAge,
    double? distanceLimit,
    List<String>? selectedInterests,
    List<String>? selectedLanguages,
    String? religion,
    String? relationshipType,
    String? sexualOrientation,
    String? datingIntention,
  }) {
    return FilterState(
      genderPreference: genderPreference ?? this.genderPreference,
      minAge: minAge ?? this.minAge,
      maxAge: maxAge ?? this.maxAge,
      distanceLimit: distanceLimit ?? this.distanceLimit,
      selectedInterests: selectedInterests ?? this.selectedInterests,
      selectedLanguages: selectedLanguages ?? this.selectedLanguages,
      religion: religion ?? this.religion,
      relationshipType: relationshipType ?? this.relationshipType,
      sexualOrientation: sexualOrientation ?? this.sexualOrientation,
      datingIntention: datingIntention ?? this.datingIntention,
    );
  }

  // Initial state
  factory FilterState.initial() {
    return FilterState(
      genderPreference: 'Everyone',
      minAge: 18,
      maxAge: 50,
      distanceLimit: 50,
      selectedInterests: [],
      selectedLanguages: [],
      religion: null,
      relationshipType: null,
      sexualOrientation: null,
      datingIntention: null,
    );
  }
}

class FilterNotifier extends StateNotifier<FilterState> {
  FilterNotifier() : super(FilterState.initial());

  void setGenderPreference(String gender) {
    state = state.copyWith(genderPreference: gender);
  }

  void setAgeRange(double min, double max) {
    state = state.copyWith(minAge: min, maxAge: max);
  }

  void setDistanceLimit(double limit) {
    state = state.copyWith(distanceLimit: limit);
  }

  void toggleInterest(String interest) {
    final interests = List<String>.from(state.selectedInterests);
    if (interests.contains(interest)) {
      interests.remove(interest);
    } else {
      interests.add(interest);
    }
    state = state.copyWith(selectedInterests: interests);
  }

  // New Filter Modifiers
  void toggleLanguage(String language) {
    final languages = List<String>.from(state.selectedLanguages);
    if (languages.contains(language)) {
      languages.remove(language);
    } else {
      languages.add(language);
    }
    state = state.copyWith(selectedLanguages: languages);
  }

  void setReligion(String? religion) {
    state = state.copyWith(religion: religion);
  }

  void setRelationshipType(String? type) {
    state = state.copyWith(relationshipType: type);
  }

  void setSexualOrientation(String? orientation) {
    state = state.copyWith(sexualOrientation: orientation);
  }

  void setDatingIntention(String? intention) {
    state = state.copyWith(datingIntention: intention);
  }

  void reset() {
    state = FilterState.initial();
  }
}

final filterProvider = StateNotifierProvider<FilterNotifier, FilterState>((
  ref,
) {
  return FilterNotifier();
});

final interestsProvider = FutureProvider<List<InterestChip>>((ref) async {
  final repo = ref.watch(onboardingRepositoryProvider);
  final rawChips = await repo.getInterestChips();
  return rawChips.map((json) => InterestChip.fromJson(json)).toList();
});
