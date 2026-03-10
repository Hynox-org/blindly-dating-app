import 'package:flutter/material.dart';

class NavigationUtils {
  static Future<T?> navigateToWithSlide<T>(
    BuildContext context,
    Widget screen,
  ) {
    return Navigator.of(context).push<T>(
      PageRouteBuilder(
        opaque:
            false, // ✅ Set to false to allow underlying screens to show behind dialog-like screens
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0); // Slide from right
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));

          var offsetAnimation = animation.drive(tween);

          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }
}
