import '../../../onboarding/domain/models/lifestyle_chip_model.dart';
import '../../../onboarding/domain/models/profile_prompt_model.dart';

class ProfileUser {
  final String id;
  final String name;
  final int age;
  final String gender;
  final String city;
  final String bio;
  final List<String> imageUrls;
  final List<String> interests;
  final String education;
  final String profession;
  final double completionPercentage;

  // New Fields
  final int? height;
  final String? hometown;
  final List<String> languages;
  final List<ProfilePrompt> prompts;
  final List<LifestyleChip> lifestyleItems;
  final String? workTitle;
  final String? workCompany;
  final String? educatedAt; // Changed from educationSchool
  final String? educationLevel;
  final int? graduationYear; // New field
  final List<String> causesCommunities;
  final String? passportLocationGeom;

  // Added fields for Edit Profile 2.0
  final String? exercise;
  final String? drinking;
  final String? smoking;
  final String? kids;
  final bool? haveKids;
  final String? kidsPreference;
  final String? religion;
  final String? politics;
  final String? zodiac;
  final String? pronouns;
  final String? relationshipType;
  final List<String>
  lookingForModes; // ✅ New Looking For Mode Multiple Selection
  final String? sexualOrientation;
  final bool spotifyConnected;
  final List<String> qualities;
  final bool isVerified;
  final String verificationLevel;

  ProfileUser({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.city,
    required this.bio,
    required this.imageUrls,
    required this.interests,
    required this.education,
    required this.profession,
    required this.completionPercentage,
    this.height,
    this.hometown,
    this.languages = const [],
    this.prompts = const [],
    this.lifestyleItems = const [],
    this.causesCommunities = const [],
    this.workTitle,
    this.workCompany,
    this.educatedAt,
    this.educationLevel,
    this.graduationYear,
    this.exercise,
    this.drinking,
    this.smoking,
    this.kids,
    this.haveKids,
    this.kidsPreference,
    this.religion,
    this.politics,
    this.zodiac,
    this.pronouns,
    this.relationshipType,
    this.sexualOrientation,
    this.spotifyConnected = false,
    this.lookingForModes = const [],
    this.qualities = const [],
    this.passportLocationGeom,
    this.isVerified = false,
    this.verificationLevel = 'unverified',
  });

  factory ProfileUser.fromJson(
    Map<String, dynamic> json,
    List<String> images, {
    List<String> interestNames = const [],
    List<String> languageNames = const [],
    List<ProfilePrompt> promptList = const [],
    List<LifestyleChip> lifestyleList = const [],
  }) {
    return ProfileUser(
      id: json['id'],
      name: json['display_name'] ?? 'User',
      age: _calculateAge(json['birth_date']),
      gender: json['gender'] ?? '',
      city: json['hometown_city'] ?? json['city'] ?? json['hometown'] ?? '',
      bio:
          json['bio'] ??
          '', // Bio passed from provider (fetched from ProfileMode)
      imageUrls: images.isNotEmpty ? images : ['https://picsum.photos/400/600'],
      interests: interestNames, // Names passed from provider
      education:
          json['education_level'] ?? '', // Default to level if school not set
      profession: json['work_title'] ?? '',
      completionPercentage: (json['profile_completeness'] ?? 0) / 100.0,

      // New Fields Mapped
      height: json['height_cm'],
      hometown: json['hometown_city'], // Using city as main hometown string
      languages:
          (json['languages'] as List?)?.map((e) => e as String).toList() ??
          languageNames,
      prompts: promptList,
      lifestyleItems: lifestyleList,
      workTitle: json['work_title'],
      workCompany: json['work_company'],
      educatedAt: json['educated_at'],
      educationLevel: json['education_level'],
      graduationYear: json['graduation_year'] != null
          ? int.tryParse(json['graduation_year'].toString())
          : null,
      causesCommunities:
          (json['causes_communities'] as List?)
              ?.map((e) => e as String)
              .toList() ??
          [],

      // Mapped new fields (assuming columns exist or will return null)
      exercise: json['exercise'],
      drinking: json['drinking'],
      smoking: json['smoking'],
      kids: json['kids'],
      religion: json['religion'],
      politics: json['politics'],
      zodiac: json['star_sign'] ?? json['zodiac'],
      kidsPreference: json['kids_preference'],
      pronouns: json['pronouns'],
      haveKids: json['have_kids'],
      relationshipType: json['relationship_type'],
      lookingForModes:
          (json['looking_for'] as List?)?.map((e) => e as String).toList() ??
          [],
      sexualOrientation: json['sexual_orientation'],
      spotifyConnected: json['spotify_connected'] ?? false,
      qualities:
          (json['qualities'] as List?)?.map((e) => e as String).toList() ?? [],
      passportLocationGeom: json['passport_location_geom'],
      isVerified: json['is_verified'] ?? false,
      verificationLevel: json['verification_level'] ?? 'unverified',
    );
  }

  ProfileUser copyWith({
    String? id,
    String? name,
    int? age,
    String? gender,
    String? city,
    String? bio,
    List<String>? imageUrls,
    List<String>? interests,
    String? education,
    String? profession,
    double? completionPercentage,
    int? height,
    String? hometown,
    List<String>? languages,
    List<ProfilePrompt>? prompts,
    List<LifestyleChip>? lifestyleItems,
    String? workTitle,
    String? workCompany,
    String? educatedAt,
    String? educationLevel,
    int? graduationYear,
    List<String>? causesCommunities,
    String? exercise,
    String? drinking,
    String? smoking,
    String? kids,
    bool? haveKids,
    String? kidsPreference,
    String? religion,
    String? politics,
    String? zodiac,
    String? pronouns,
    String? relationshipType,
    List<String>? lookingForModes,
    String? sexualOrientation,
    bool? spotifyConnected,
    List<String>? qualities,
    String? passportLocationGeom,
    bool? isVerified,
    String? verificationLevel,
  }) {
    return ProfileUser(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      city: city ?? this.city,
      bio: bio ?? this.bio,
      imageUrls: imageUrls ?? this.imageUrls,
      interests: interests ?? this.interests,
      education: education ?? this.education,
      profession: profession ?? this.profession,
      completionPercentage: completionPercentage ?? this.completionPercentage,
      height: height ?? this.height,
      hometown: hometown ?? this.hometown,
      languages: languages ?? this.languages,
      prompts: prompts ?? this.prompts,
      lifestyleItems: lifestyleItems ?? this.lifestyleItems,
      workTitle: workTitle ?? this.workTitle,
      workCompany: workCompany ?? this.workCompany,
      educatedAt: educatedAt ?? this.educatedAt,
      educationLevel: educationLevel ?? this.educationLevel,
      graduationYear: graduationYear ?? this.graduationYear,
      causesCommunities: causesCommunities ?? this.causesCommunities,
      exercise: exercise ?? this.exercise,
      drinking: drinking ?? this.drinking,
      smoking: smoking ?? this.smoking,
      kids: kids ?? this.kids,
      haveKids: haveKids ?? this.haveKids,
      kidsPreference: kidsPreference ?? this.kidsPreference,
      religion: religion ?? this.religion,
      politics: politics ?? this.politics,
      zodiac: zodiac ?? this.zodiac,
      pronouns: pronouns ?? this.pronouns,
      relationshipType: relationshipType ?? this.relationshipType,
      lookingForModes: lookingForModes ?? this.lookingForModes,
      sexualOrientation: sexualOrientation ?? this.sexualOrientation,
      spotifyConnected: spotifyConnected ?? this.spotifyConnected,
      qualities: qualities ?? this.qualities,
      passportLocationGeom: passportLocationGeom ?? this.passportLocationGeom,
      isVerified: isVerified ?? this.isVerified,
      verificationLevel: verificationLevel ?? this.verificationLevel,
    );
  }

  static int _calculateAge(String? dobString) {
    if (dobString == null) return 0;
    try {
      final dob = DateTime.parse(dobString);
      final now = DateTime.now();
      int age = now.year - dob.year;
      if (now.month < dob.month ||
          (now.month == dob.month && now.day < dob.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return 0;
    }
  }
}
