import 'package:flutter_riverpod/flutter_riverpod.dart';

// Defaults to 'false' (Not Verified) until we check cache/database
final verificationStatusProvider = StateProvider<bool>((ref) => false);