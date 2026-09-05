import 'package:flutter_dotenv/flutter_dotenv.dart';

/// The app ships a single environment file.
///
/// This used to switch on `String.fromEnvironment('ENV')` with a default of
/// 'dev', so any build that forgot `--dart-define=ENV=prod` silently loaded a
/// dead Supabase project and failed at login. One file, no switch, no foot-gun.
class EnvironmentConfig {
  static const String fileName = '.env.production';

  static Future<void> load() => dotenv.load(fileName: fileName);
}
