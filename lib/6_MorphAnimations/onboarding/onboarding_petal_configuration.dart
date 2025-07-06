import 'package:flutter/material.dart';
import 'package:morphable_shape/morphable_shape.dart';

class OnboardingPetalConfiguration {
  final MorphableShapeBorder shape;
  final Gradient gradient;

  const OnboardingPetalConfiguration(
      {required this.shape, required this.gradient});
}
