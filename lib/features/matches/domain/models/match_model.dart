class MatchModel {
  final String matchId;
  final String userAId;
  final String userBId;
  final String status;
  final DateTime expiresAt;
  final DateTime createdAt;

  MatchModel({
    required this.matchId,
    required this.userAId,
    required this.userBId,
    required this.status,
    required this.expiresAt,
    required this.createdAt,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    // 🔒 Defensive parsing (VERY IMPORTANT)
    final matchId = json['match_id']?.toString();
    final userAId = json['user_a_id']?.toString();
    final userBId = json['user_b_id']?.toString();

    if (matchId == null || userAId == null || userBId == null) {
      throw Exception('Invalid match row: missing IDs');
    }

    return MatchModel(
      matchId: matchId,
      userAId: userAId,
      userBId: userBId,

      // ✅ status ALWAYS becomes String
      status: json['status']?.toString() ?? 'active',

      // ✅ Safe DateTime parsing
      expiresAt: DateTime.tryParse(
            json['expires_at']?.toString() ?? '',
          ) ??
          DateTime.now().add(const Duration(hours: 24)),

      createdAt: DateTime.tryParse(
            json['created_at']?.toString() ?? '',
          ) ??
          DateTime.now(),
    );
  }
}
