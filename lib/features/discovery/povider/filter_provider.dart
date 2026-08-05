import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repository/discovery_repository.dart';
import '../../../core/providers/connection_mode_provider.dart';
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

  Map<String, dynamic> toJson() {
    return {
      'genderPreference': genderPreference,
      'minAge': minAge,
      'maxAge': maxAge,
      'distanceLimit': distanceLimit,
      'selectedInterests': selectedInterests,
      'selectedLanguages': selectedLanguages,
      'religion': religion,
      'relationshipType': relationshipType,
      'sexualOrientation': sexualOrientation,
      'datingIntention': datingIntention,
    };
  }

  factory FilterState.fromJson(Map<String, dynamic> json) {
    return FilterState(
      genderPreference: json['genderPreference'] ?? 'Everyone',
      minAge: (json['minAge'] as num?)?.toDouble() ?? 18,
      maxAge: (json['maxAge'] as num?)?.toDouble() ?? 60,
      distanceLimit: (json['distanceLimit'] as num?)?.toDouble() ?? 50,
      selectedInterests: List<String>.from(json['selectedInterests'] ?? []),
      selectedLanguages: List<String>.from(json['selectedLanguages'] ?? []),
      religion: json['religion'],
      relationshipType: json['relationshipType'],
      sexualOrientation: json['sexualOrientation'],
      datingIntention: json['datingIntention'],
    );
  }

  // Initial state
  factory FilterState.initial() {
    return FilterState(
      genderPreference: 'Everyone',
      minAge: 18,
      maxAge: 60,
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
  final DiscoveryRepository? _repository;
  final String? _currentMode;

  FilterNotifier({DiscoveryRepository? repository, String? mode})
      : _repository = repository,
        _currentMode = mode,
        super(FilterState.initial()) {
    _loadFilters();
  }

  Future<void> _loadFilters() async {
    if (_repository != null && _currentMode != null) {
      final savedFilters = await _repository.getDiscoveryFilters(_currentMode);
      if (!mounted) return;
      if (savedFilters != null) {
        state = FilterState.fromJson(savedFilters);
      }
    }
  }

  void _saveFilters() {
    if (_repository != null && _currentMode != null) {
      _repository.saveDiscoveryFilters(_currentMode, state.toJson());
    }
  }

  void setState(FilterState newState) {
    state = newState;
  }

  void setGenderPreference(String gender) {
    state = state.copyWith(genderPreference: gender);
    _saveFilters();
  }

  void setAgeRange(double min, double max) {
    // Keep the pair ordered — RangeSlider asserts start <= end, and the SQL
    // BETWEEN would silently return nothing if they were swapped.
    final lo = min <= max ? min : max;
    final hi = min <= max ? max : min;
    state = state.copyWith(minAge: lo, maxAge: hi);
    _saveFilters();
  }

  void setDistanceLimit(double limit) {
    state = state.copyWith(distanceLimit: limit);
    _saveFilters();
  }

  void toggleInterest(String interest) {
    final interests = List<String>.from(state.selectedInterests);
    if (interests.contains(interest)) {
      interests.remove(interest);
    } else {
      interests.add(interest);
    }
    state = state.copyWith(selectedInterests: interests);
    _saveFilters();
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
    _saveFilters();
  }

  void setReligion(String? religion) {
    state = state.copyWith(religion: religion);
    _saveFilters();
  }

  void setRelationshipType(String? type) {
    state = state.copyWith(relationshipType: type);
    _saveFilters();
  }

  void setSexualOrientation(String? orientation) {
    state = state.copyWith(sexualOrientation: orientation);
    _saveFilters();
  }

  void setDatingIntention(String? intention) {
    state = state.copyWith(datingIntention: intention);
    _saveFilters();
  }

  void reset() {
    state = FilterState.initial();
    _saveFilters();
  }
}

final filterProvider = StateNotifierProvider<FilterNotifier, FilterState>((
  ref,
) {
  final repo = ref.watch(discoveryRepositoryProvider);
  final mode = ref.watch(connectionModeProvider);
  return FilterNotifier(repository: repo, mode: mode);
});

final interestsProvider = FutureProvider<List<InterestChip>>((ref) async {
  final repo = ref.watch(onboardingRepositoryProvider);
  final rawChips = await repo.getInterestChips();
  return rawChips.map((json) => InterestChip.fromJson(json)).toList();
});
