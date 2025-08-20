import 'dart:math';

import 'package:flutter/material.dart';

/// A reusable Hero widget that provides a 3D flip animation during transitions
/// with customizable background color transitions and overlay opacity.
///
/// This widget wraps the standard Hero widget and adds a custom flightShuttleBuilder
/// that creates a smooth 3D flip effect with background color transitions and
/// overlay opacity control during hero transitions.
///
/// Usage:
/// ```dart
/// FlipHero(
///   tag: 'my_hero_tag',
///   baseColor: Colors.blue,
///   child: Container(
///     width: 200,
///     height: 200,
///     child: Text('My Content'),
///   ),
/// )
/// ```
class FlipHero extends StatelessWidget {
  /// The tag that identifies this hero widget for transitions
  final String tag;

  /// The child widget to be displayed and animated
  final Widget child;

  /// The base color for the background transition
  final Color baseColor;

  /// The final opacity factor for the overlay (0.0 to 1.0)
  /// Defaults to 0.0 (no overlay)
  final double finalOpacityFactor;

  /// Optional custom flight shuttle builder for advanced customization
  final HeroFlightShuttleBuilder? flightShuttleBuilder;

  /// Whether to enable the flip animation (defaults to true)
  final bool enableFlip;

  /// The duration of the flip animation (defaults to 300ms)
  final Duration flipDuration;

  /// The perspective depth for the 3D effect (defaults to 0.001)
  final double perspectiveDepth;

  /// Whether to hide the child during transition (defaults to true)
  final bool hideChildDuringTransition;

  /// The curve for the opacity animation (defaults to Curves.easeInOut)
  final Curve opacityCurve;

  /// The curve for the flip animation (defaults to Curves.easeInOut)
  final Curve flipCurve;

  const FlipHero({
    super.key,
    required this.tag,
    required this.child,
    required this.baseColor,
    this.finalOpacityFactor = 0.0,
    this.flightShuttleBuilder,
    this.enableFlip = true,
    this.flipDuration = const Duration(milliseconds: 300),
    this.perspectiveDepth = 0.001,
    this.hideChildDuringTransition = true,
    this.opacityCurve = Curves.easeInOut,
    this.flipCurve = Curves.easeInOut,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      flightShuttleBuilder:
          flightShuttleBuilder ?? _defaultFlightShuttleBuilder,
      child: child,
    );
  }

  /// Default flight shuttle builder that creates the flip animation with
  /// background color transitions and overlay opacity
  Widget _defaultFlightShuttleBuilder(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection direction,
    BuildContext fromContext,
    BuildContext toContext,
  ) {
    if (!enableFlip) {
      // If flip is disabled, return the child with overlay
      return _buildWithOverlay(animation);
    }

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        // Apply curve to the animation
        final curvedAnimation = flipCurve.transform(animation.value);

        // Calculate rotation angle for flip effect
        final rotationAngle = curvedAnimation * pi; // Full rotation (π radians)

        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, perspectiveDepth) // Add perspective
            ..rotateY(rotationAngle),
          alignment: Alignment.center,
          child: rotationAngle < pi / 2
              ? // Front face (first half of animation)
              _buildFrontFace(animation)
              : // Back face (second half of animation)
              _buildBackFace(animation),
        );
      },
    );
  }

  /// Builds the front face of the flip animation
  Widget _buildFrontFace(Animation<double> animation) {
    return Transform(
      transform: Matrix4.identity()..rotateY(0),
      alignment: Alignment.center,
      child: _buildWithOverlay(animation),
    );
  }

  /// Builds the back face of the flip animation
  Widget _buildBackFace(Animation<double> animation) {
    return Transform(
      transform: Matrix4.identity()..rotateY(pi), // Flip back face
      alignment: Alignment.center,
      child: _buildWithOverlay(animation),
    );
  }

  /// Builds the widget with background color and overlay
  Widget _buildWithOverlay(Animation<double> animation) {
    return Container(
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // Background color container
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(12),
            ),
          ),

          // Child widget (conditionally visible)
          if (!hideChildDuringTransition ||
              animation.value < 0.1 ||
              animation.value > 0.9)
            Opacity(
              opacity: hideChildDuringTransition
                  ? (animation.value < 0.1 || animation.value > 0.9 ? 1.0 : 0.0)
                  : 1.0,
              child: child,
            ),

          // Overlay with animated opacity
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: finalOpacityFactor *
                    opacityCurve.transform(animation.value),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
    );
  }
}

/// A more specialized version of FlipHero that provides factory constructors
/// for common use cases like "from" and "to" states
class FlipHeroWithStates extends StatelessWidget {
  /// The tag that identifies this hero widget for transitions
  final String tag;

  /// The child widget to be displayed and animated
  final Widget child;

  /// The base color for the background transition
  final Color baseColor;

  /// The final opacity factor for the overlay (0.0 to 1.0)
  final double finalOpacityFactor;

  /// Whether to enable the flip animation (defaults to true)
  final bool enableFlip;

  /// The duration of the flip animation (defaults to 300ms)
  final Duration flipDuration;

  /// The perspective depth for the 3D effect (defaults to 0.001)
  final double perspectiveDepth;

  /// Whether to hide the child during transition (defaults to true)
  final bool hideChildDuringTransition;

  /// The curve for the opacity animation (defaults to Curves.easeInOut)
  final Curve opacityCurve;

  /// The curve for the flip animation (defaults to Curves.easeInOut)
  final Curve flipCurve;

  const FlipHeroWithStates({
    super.key,
    required this.tag,
    required this.child,
    required this.baseColor,
    required this.finalOpacityFactor,
    this.enableFlip = true,
    this.flipDuration = const Duration(milliseconds: 300),
    this.perspectiveDepth = 0.001,
    this.hideChildDuringTransition = true,
    this.opacityCurve = Curves.easeInOut,
    this.flipCurve = Curves.easeInOut,
  });

  /// Factory constructor for the "from" state (no overlay)
  factory FlipHeroWithStates.from({
    Key? key,
    required String tag,
    required Widget child,
    required Color baseColor,
    bool enableFlip = true,
    Duration flipDuration = const Duration(milliseconds: 300),
    double perspectiveDepth = 0.001,
    bool hideChildDuringTransition = true,
    Curve opacityCurve = Curves.easeInOut,
    Curve flipCurve = Curves.easeInOut,
  }) {
    return FlipHeroWithStates(
      key: key,
      tag: tag,
      child: child,
      baseColor: baseColor,
      finalOpacityFactor: 0.0, // No overlay in "from" state
      enableFlip: enableFlip,
      flipDuration: flipDuration,
      perspectiveDepth: perspectiveDepth,
      hideChildDuringTransition: hideChildDuringTransition,
      opacityCurve: opacityCurve,
      flipCurve: flipCurve,
    );
  }

  /// Factory constructor for the "to" state (with overlay)
  factory FlipHeroWithStates.to({
    Key? key,
    required String tag,
    required Widget child,
    required Color baseColor,
    double finalOpacityFactor = 0.5,
    bool enableFlip = true,
    Duration flipDuration = const Duration(milliseconds: 300),
    double perspectiveDepth = 0.001,
    bool hideChildDuringTransition = true,
    Curve opacityCurve = Curves.easeInOut,
    Curve flipCurve = Curves.easeInOut,
  }) {
    return FlipHeroWithStates(
      key: key,
      tag: tag,
      child: child,
      baseColor: baseColor,
      finalOpacityFactor: finalOpacityFactor, // Overlay in "to" state
      enableFlip: enableFlip,
      flipDuration: flipDuration,
      perspectiveDepth: perspectiveDepth,
      hideChildDuringTransition: hideChildDuringTransition,
      opacityCurve: opacityCurve,
      flipCurve: flipCurve,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FlipHero(
      tag: tag,
      child: child,
      baseColor: baseColor,
      finalOpacityFactor: finalOpacityFactor,
      enableFlip: enableFlip,
      flipDuration: flipDuration,
      perspectiveDepth: perspectiveDepth,
      hideChildDuringTransition: hideChildDuringTransition,
      opacityCurve: opacityCurve,
      flipCurve: flipCurve,
    );
  }
}

/// Extension to provide a more convenient way to create FlipHero widgets
extension FlipHeroExtension on Widget {
  /// Wraps this widget in a FlipHero with the given tag and base color
  Widget flipHero({
    required String tag,
    required Color baseColor,
    double finalOpacityFactor = 0.0,
    HeroFlightShuttleBuilder? flightShuttleBuilder,
    bool enableFlip = true,
    Duration flipDuration = const Duration(milliseconds: 300),
    double perspectiveDepth = 0.001,
    bool hideChildDuringTransition = true,
    Curve opacityCurve = Curves.easeInOut,
    Curve flipCurve = Curves.easeInOut,
  }) {
    return FlipHero(
      tag: tag,
      baseColor: baseColor,
      finalOpacityFactor: finalOpacityFactor,
      flightShuttleBuilder: flightShuttleBuilder,
      enableFlip: enableFlip,
      flipDuration: flipDuration,
      perspectiveDepth: perspectiveDepth,
      hideChildDuringTransition: hideChildDuringTransition,
      opacityCurve: opacityCurve,
      flipCurve: flipCurve,
      child: this,
    );
  }

  /// Wraps this widget in a FlipHeroWithStates.from with the given tag and base color
  Widget flipHeroFrom({
    required String tag,
    required Color baseColor,
    bool enableFlip = true,
    Duration flipDuration = const Duration(milliseconds: 300),
    double perspectiveDepth = 0.001,
    bool hideChildDuringTransition = true,
    Curve opacityCurve = Curves.easeInOut,
    Curve flipCurve = Curves.easeInOut,
  }) {
    return FlipHeroWithStates.from(
      tag: tag,
      baseColor: baseColor,
      enableFlip: enableFlip,
      flipDuration: flipDuration,
      perspectiveDepth: perspectiveDepth,
      hideChildDuringTransition: hideChildDuringTransition,
      opacityCurve: opacityCurve,
      flipCurve: flipCurve,
      child: this,
    );
  }

  /// Wraps this widget in a FlipHeroWithStates.to with the given tag and base color
  Widget flipHeroTo({
    required String tag,
    required Color baseColor,
    double finalOpacityFactor = 0.5,
    bool enableFlip = true,
    Duration flipDuration = const Duration(milliseconds: 300),
    double perspectiveDepth = 0.001,
    bool hideChildDuringTransition = true,
    Curve opacityCurve = Curves.easeInOut,
    Curve flipCurve = Curves.easeInOut,
  }) {
    return FlipHeroWithStates.to(
      tag: tag,
      baseColor: baseColor,
      finalOpacityFactor: finalOpacityFactor,
      enableFlip: enableFlip,
      flipDuration: flipDuration,
      perspectiveDepth: perspectiveDepth,
      hideChildDuringTransition: hideChildDuringTransition,
      opacityCurve: opacityCurve,
      flipCurve: flipCurve,
      child: this,
    );
  }
}
