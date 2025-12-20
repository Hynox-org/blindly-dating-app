import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/theme/app_theme.dart';

class ThemeSwitcher extends ConsumerWidget {
  const ThemeSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeModeProvider);

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color:
              Theme.of(context).cardTheme.color?.withOpacity(0.9) ??
              Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: AppThemeMode.values.map((mode) {
            final isSelected = currentTheme == mode;
            final color = _getThemeIconColor(mode, context);

            return GestureDetector(
              onTap: () {
                ref.read(themeModeProvider.notifier).setTheme(mode);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withOpacity(0.2)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getThemeIcon(mode),
                  color: isSelected ? color : Colors.grey.withOpacity(0.5),
                  size: 20,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  IconData _getThemeIcon(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.normal:
        return Icons.wb_sunny_rounded;
      case AppThemeMode.premium:
        return Icons.star_rounded;
      case AppThemeMode.incognito:
        return Icons.visibility_off_rounded;
    }
  }

  Color _getThemeIconColor(AppThemeMode mode, BuildContext context) {
    switch (mode) {
      case AppThemeMode.normal:
        return const Color(0xFF4A5D4F);
      case AppThemeMode.premium:
        return const Color(0xFFE6C97A);
      case AppThemeMode.incognito:
        return Colors.black;
    }
  }
}
