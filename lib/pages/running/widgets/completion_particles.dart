import 'package:flutter/material.dart';

class CompletionParticles extends StatelessWidget {
  const CompletionParticles({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(20, (index) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 1000 + (index * 50)),
          builder: (context, value, child) {
            final distance = value * 200;
            return Positioned(
              top: MediaQuery.of(context).size.height * 0.3 +
                  (distance * (index.isEven ? 1 : -1) * 0.5),
              left: MediaQuery.of(context).size.width / 2 +
                  (distance * (index.isEven ? 1 : -1)),
              child: Opacity(
                opacity: 1 - value,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: [
                      Colors.amber,
                      Colors.orange,
                      Colors.green,
                      Colors.blue,
                      Colors.purple,
                    ][index % 5],
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
