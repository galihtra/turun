import 'package:flutter/material.dart';

class SpacerHeight extends StatelessWidget {
  final double height;
  const SpacerHeight(this.height, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
    );
  }
}

class SpacerWidth extends StatelessWidget {
  final double width;
  const SpacerWidth(this.width, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
    );
  }
}
