import 'package:flutter/material.dart';

class AppLoader extends StatelessWidget {
  final Color? color;
  final double size;
  final double strokeWidth;

  const AppLoader({
    super.key,
    this.color,
    this.size = 24.0,
    this.strokeWidth = 3.0,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: size,
        width: size,
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth,
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }
}
