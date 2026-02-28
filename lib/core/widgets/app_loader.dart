import 'package:flutter/material.dart';

class AppLoader extends StatelessWidget {
  final Color? color;
  final double size;
  final double strokeWidth;

  const AppLoader({
    super.key,
    this.color,
    this.size = 40.0,
    this.strokeWidth = 3.0,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = color ?? Theme.of(context).colorScheme.primary;

    return Center(
      child: SizedBox(
        height: size,
        width: size,
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth,
          strokeCap: StrokeCap.round,
          backgroundColor: themeColor.withOpacity(0.15),
          valueColor: AlwaysStoppedAnimation<Color>(themeColor),
        ),
      ),
    );
  }
}
