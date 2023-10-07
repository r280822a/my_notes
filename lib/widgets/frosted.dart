import 'package:flutter/material.dart';
import 'dart:ui';

// Frosted look for given widget
class Frosted extends StatelessWidget {
  const Frosted({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: child,
      ),
    );
  }
}