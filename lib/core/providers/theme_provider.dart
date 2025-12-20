import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';

final themeModeProvider = StateNotifierProvider<ThemeNotifier, AppThemeMode>((
  ref,
) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<AppThemeMode> {
  ThemeNotifier() : super(AppThemeMode.normal);

  void setTheme(AppThemeMode mode) {
    state = mode;
  }

  void toggleTheme() {
    if (state == AppThemeMode.normal) {
      state = AppThemeMode.premium;
    } else if (state == AppThemeMode.premium) {
      state = AppThemeMode.incognito;
    } else {
      state = AppThemeMode.normal;
    }
  }
}
