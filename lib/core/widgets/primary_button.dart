import 'package:flutter/material.dart';
import 'app_loader.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final double? width;
  final double height;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double borderRadius;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.width,
    this.height = 56.0,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius = 30.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: (isEnabled && !isLoading) ? onPressed : null,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: backgroundColor ?? theme.colorScheme.primary,
          foregroundColor: foregroundColor ?? theme.colorScheme.onPrimary,
          disabledBackgroundColor:
              (backgroundColor ?? theme.colorScheme.primary).withOpacity(0.5),
          disabledForegroundColor:
              (foregroundColor ?? theme.colorScheme.onPrimary).withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: isLoading
            ? AppLoader(
                size: 24,
                color: foregroundColor ?? theme.colorScheme.onPrimary,
                strokeWidth: 2,
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
