import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/theme/app_theme.dart';

class ThemeSwitcher extends ConsumerWidget {
  const ThemeSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeModeProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: AppThemeMode.values.map((mode) {
          final isSelected = currentTheme == mode;
          final color = _getThemeIconColor(mode);

          return GestureDetector(
            onTap: () => ref.read(themeModeProvider.notifier).setTheme(mode),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? color : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Icon(
                _getThemeIcon(mode),
                color: isSelected ? color : Colors.grey,
                size: 24,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _getThemeIcon(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.normal:
        return Icons.wb_sunny_outlined;
      case AppThemeMode.premium:
        return Icons.star_border_rounded;
      case AppThemeMode.incognito:
        return Icons.visibility_off_outlined;
    }
  }

  Color _getThemeIconColor(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.normal:
        return const Color(0xFF414833);
      case AppThemeMode.premium:
        return const Color(0xFFE6C97A);
      case AppThemeMode.incognito:
        return Colors.white;
    }
  }
}
