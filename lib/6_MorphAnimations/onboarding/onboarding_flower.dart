import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_showcases/6_MorphAnimations/onboarding/onboarding_petal.dart';
import 'package:ui_showcases/6_MorphAnimations/onboarding/providers/onboarding_shape_controller_provider.dart';
import 'package:ui_showcases/6_MorphAnimations/onboarding/shapes/onboarding_shape.dart';

class OnboardingFlower extends ConsumerWidget {
  final double size;
  final double secondSize;
  final double bottomOffset;
  const OnboardingFlower({
    super.key,
    this.size = 200,
    this.secondSize = 100,
    this.bottomOffset = 0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    const centerColor = Color(0xFF96C85F);
    final isAllPetalsExpanded = ref
        .watch(onboardingShapeControllerProvider.notifier)
        .isAllPetalsExpanded;

    final x = width / 2;
    final y = isAllPetalsExpanded ? secondSize : size;

    return Stack(
      children: [
        // Top left
        Positioned(
          top: 0,
          right: x,
          child: OnboardingPetal(
            size: size,
            position: PetalPosition.topLeft,
            petalStyle: OnboardingPetalOrientation.diagonalTopLeft,
            secondPetalStyle: OnboardingPetalOrientation.bottomRight,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF06FFDB),
                centerColor,
              ],
            ),
          ),
        ),
        // Top right
        Positioned(
          top: 0,
          left: x,
          child: OnboardingPetal(
              size: size,
              position: PetalPosition.topRight,
              petalStyle: OnboardingPetalOrientation.diagonalTopRight,
              secondPetalStyle: OnboardingPetalOrientation.bottomLeft,
              gradient: const LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Color(0xFF414C17),
                  centerColor,
                ],
              )),
        ),
        // Bottom left
        Positioned(
          top: y,
          right: x,
          child: OnboardingPetal(
              size: size,
              position: PetalPosition.bottomLeft,
              petalStyle: OnboardingPetalOrientation.diagonalTopRight,
              secondPetalStyle: OnboardingPetalOrientation.topRight,
              gradient: const LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: [
                  Color(0xFFED8007),
                  centerColor,
                ],
              )),
        ),
        // Bottom right
        Positioned(
          top: y,
          left: x,
          child: OnboardingPetal(
              size: size,
              position: PetalPosition.bottomRight,
              petalStyle: OnboardingPetalOrientation.diagonalTopLeft,
              secondPetalStyle: OnboardingPetalOrientation.topLeft,
              gradient: const LinearGradient(
                begin: Alignment.bottomRight,
                end: Alignment.topLeft,
                colors: [
                  Color(0xFFFF689C),
                  Color(0xFFFC8671),
                  centerColor,
                ],
              )),
        ),
      ],
    );
  }
}
