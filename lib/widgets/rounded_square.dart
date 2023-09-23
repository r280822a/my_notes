import 'package:flutter/material.dart';

class RoundedSquare extends StatelessWidget {
  const RoundedSquare({
    super.key,
    required this.size,
    required this.child,
  });

  final double size;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // Progress indicator inside square with rounded edges
      height: size,
      width: size,
      child: Stack(
        children: <Widget>[
          Center(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: const BorderRadius.all(Radius.circular(20))
              ),
              child: SizedBox(height: size, width: size)
            ),
          ),
          Center(child: child),
        ],
      ),
    );
  }
}
