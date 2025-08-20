import 'package:flutter/material.dart';
import 'package:ui_showcases/8_Hero/flip_hero.dart';

/// Example widget demonstrating the improved FlipHero widget usage
/// with background color transitions and overlay opacity control.
class FlipHeroChildExample extends StatelessWidget {
  final double whiteOverlayOpacity;
  final Color baseColor;

  const FlipHeroChildExample({
    super.key,
    required this.whiteOverlayOpacity,
    required this.baseColor,
  });

  /// Factory constructor for the "from" state (no overlay)
  factory FlipHeroChildExample.from({
    Key? key,
    Color baseColor = Colors.green,
  }) {
    return FlipHeroChildExample(
      key: key,
      whiteOverlayOpacity: 0.0,
      baseColor: baseColor,
    );
  }

  /// Factory constructor for the "to" state (with overlay)
  factory FlipHeroChildExample.to({
    Key? key,
    Color baseColor = Colors.green,
    double whiteOverlayOpacity = 0.5,
  }) {
    return FlipHeroChildExample(
      key: key,
      whiteOverlayOpacity: whiteOverlayOpacity,
      baseColor: baseColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FlipHero(
      tag: 'flip_hero_example',
      baseColor: baseColor,
      finalOpacityFactor: whiteOverlayOpacity,
      child: const Center(
        child: Text(
          'I am a Hero',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}

/// Alternative implementation using the FlipHeroWithStates class
/// for more convenient "from" and "to" state management
class FlipHeroChildExampleWithStates extends StatelessWidget {
  final Color baseColor;
  final double finalOpacityFactor;

  const FlipHeroChildExampleWithStates({
    super.key,
    required this.baseColor,
    required this.finalOpacityFactor,
  });

  /// Factory constructor for the "from" state (no overlay)
  factory FlipHeroChildExampleWithStates.from({
    Key? key,
    Color baseColor = Colors.green,
  }) {
    return FlipHeroChildExampleWithStates(
      key: key,
      baseColor: baseColor,
      finalOpacityFactor: 0.0,
    );
  }

  /// Factory constructor for the "to" state (with overlay)
  factory FlipHeroChildExampleWithStates.to({
    Key? key,
    Color baseColor = Colors.green,
    double finalOpacityFactor = 0.5,
  }) {
    return FlipHeroChildExampleWithStates(
      key: key,
      baseColor: baseColor,
      finalOpacityFactor: finalOpacityFactor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FlipHeroWithStates(
      tag: 'flip_hero_states_example',
      baseColor: baseColor,
      finalOpacityFactor: finalOpacityFactor,
      child: const Center(
        child: Text(
          'I am a Hero with States',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}

/// Example using the extension methods for even more convenient usage
class FlipHeroChildExampleWithExtensions extends StatelessWidget {
  final Color baseColor;
  final double finalOpacityFactor;
  final bool isFromState;

  const FlipHeroChildExampleWithExtensions({
    super.key,
    required this.baseColor,
    this.finalOpacityFactor = 0.5,
    this.isFromState = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = const Center(
      child: Text(
        'I am a Hero with Extensions',
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
    );

    if (isFromState) {
      return child.flipHeroFrom(
        tag: 'flip_hero_extensions_example',
        baseColor: baseColor,
      );
    } else {
      return child.flipHeroTo(
        tag: 'flip_hero_extensions_example',
        baseColor: baseColor,
        finalOpacityFactor: finalOpacityFactor,
      );
    }
  }
}
