import 'discovery_user_model.dart';

class DiscoveryLandingData {
  final Map<String, List<DiscoveryUser>> feeds;
  final DateTime? lastRefreshedAt;

  DiscoveryLandingData({required this.feeds, this.lastRefreshedAt});
}
