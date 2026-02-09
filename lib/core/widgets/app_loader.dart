import 'package:flutter/material.dart';

class AppLoader extends StatelessWidget {
  final Color? color;
  final double size;
  final double strokeWidth;

  const AppLoader({
    super.key,
    this.color,
    this.size = 60.0,
    this.strokeWidth = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipOval(
            child: Image.asset(
              'assets/images/blindly-app-icon-color.jpg',
              width: size,
              height: size,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(
            height: size,
            width: size,
            child: CircularProgressIndicator(
              strokeWidth: strokeWidth,
              color: color ?? Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
