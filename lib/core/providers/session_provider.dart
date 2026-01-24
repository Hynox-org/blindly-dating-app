import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks if we have updated the user's location in this session.
/// false = Need to update.
/// true = Already updated, skip logic.
final locationUpdateSessionProvider = StateProvider<bool>((ref) => false);