import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Utility class that provides easy access to the current
/// screen dimensions. Instead of using mutable `late` fields,
/// the values are calculated once and exposed as `final`
/// properties, making the class simpler and safer to use.
class Responsive {
  final double width;
  final double height;
  final double diagonal;
  final bool isTablet;

  /// Creates a [Responsive] object from the given [BuildContext].
  factory Responsive.of(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final diagonal =
        math.sqrt(math.pow(size.width, 2) + math.pow(size.height, 2));
    final isTablet = size.shortestSide >= 600;

    return Responsive._(
      width: size.width,
      height: size.height,
      diagonal: diagonal,
      isTablet: isTablet,
    );
  }

  const Responsive._({
    required this.width,
    required this.height,
    required this.diagonal,
    required this.isTablet,
  });

  double wp(double percent) => width * percent / 100;
  double hp(double percent) => height * percent / 100;
  double dp(double percent) => diagonal * percent / 100;
}
