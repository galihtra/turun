import 'package:flutter/material.dart';

class SlidePageRoute extends PageRouteBuilder {
  final Widget page;
  final AxisDirection direction;
  SlidePageRoute({
    required this.page,
    this.direction = AxisDirection.right,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var begin = const Offset(1.0, 0.0);
            switch (direction) {
              case AxisDirection.up:
                begin = const Offset(0.0, 1.0);
                break;
              case AxisDirection.down:
                begin = const Offset(0.0, -1.0);
                break;
              case AxisDirection.left:
                begin = const Offset(-1.0, 0.0);
                break;
              case AxisDirection.right:
              begin = const Offset(1.0, 0.0);
            }

            var end = Offset.zero;
            var curve = Curves.easeInOut;

            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        );
}



class FadePageRoute extends PageRouteBuilder {
  final Widget page;
  final Duration duration;
  
  FadePageRoute({required this.page, this.duration = const Duration(milliseconds: 500)})
      : super(
          transitionDuration: duration, // Atur durasi animasi
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var curve = Curves.ease;
            var tween = Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve));

            return FadeTransition(
              opacity: animation.drive(tween),
              child: child,
            );
          },
        );
}



