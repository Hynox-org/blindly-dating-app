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
  });

  factory ProfileUser.fromJson(Map<String, dynamic> json, List<String> images) {
    return ProfileUser(
      id: json['id'],
      // ✅ Schema Mappings
      name: json['display_name'] ?? 'User',  // Changed from first_name
      age: _calculateAge(json['birth_date']), // Changed from dob
      gender: json['gender'] ?? '',
      city: json['city'] ?? '',
      bio: json['bio'] ?? '',
      imageUrls: images.isNotEmpty ? images : ['https://picsum.photos/400/600'],
      // Note: 'selected_interest_ids' gives IDs, not names. 
      // For now we default to empty until we add a Join query.
      interests: [], 
      education: '', // Not in schema provided, defaulting
      profession: '', // Not in schema provided, defaulting
      completionPercentage: (json['profile_completeness'] ?? 0) / 100.0, // Use DB calculation
    );
  }

  static int _calculateAge(String? dobString) {
    if (dobString == null) return 0;
    try {
      final dob = DateTime.parse(dobString);
      final now = DateTime.now();
      int age = now.year - dob.year;
      if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return 0;
    }
  }
}