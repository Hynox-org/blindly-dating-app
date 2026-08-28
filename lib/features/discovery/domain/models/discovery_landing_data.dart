import 'package:blindly_dating_app/features/matching/domain/models/match_profile.dart';

class DiscoveryLandingData {
  final Map<String, List<MatchProfile>> feeds;
  final DateTime? lastRefreshedAt;

  DiscoveryLandingData({required this.feeds, this.lastRefreshedAt});
}
