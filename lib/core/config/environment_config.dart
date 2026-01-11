import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvironmentConfig {
  static const String envKey = 'ENV';
  static const String prod = 'prod';
  static const String dev = 'dev';

  static String get currentEnv {
    const env = String.fromEnvironment(envKey, defaultValue: dev);
    return env;
  }

  static String get fileName {
    return currentEnv == prod ? '.env.production' : '.env.development';
  }

  static Future<void> load() async {
    await dotenv.load(fileName: fileName);
  }
}
