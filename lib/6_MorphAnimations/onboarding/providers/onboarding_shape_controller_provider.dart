import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'onboarding_shape_controller_provider.g.dart';

enum PetalPosition {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

@riverpod
class OnboardingShapeController extends _$OnboardingShapeController {
  final Map<PetalPosition, VoidCallback> _petalAnimators = {};
  final Map<PetalPosition, bool> _petalStates = {};

  @override
  OnboardingShapeController build() {
    return this;
  }

  /// Register a petal's animation callback
  void registerPetal(PetalPosition position, VoidCallback animator) {
    _petalAnimators[position] = animator;
    _petalStates[position] = false;
  }

  /// Unregister a petal's animation callback
  void unregisterPetal(PetalPosition position) {
    _petalAnimators.remove(position);
    _petalStates.remove(position);
  }

  /// Animate a specific petal
  void animatePetal(PetalPosition position) {
    final animator = _petalAnimators[position];
    if (animator != null) {
      animator();
      _petalStates[position] = !(_petalStates[position] ?? false);
    }
  }

  /// Animate all petals
  void animateAllPetals() {
    for (final animator in _petalAnimators.values) {
      animator();
    }
    for (final position in _petalStates.keys) {
      _petalStates[position] = !(_petalStates[position] ?? false);
    }
  }

  /// Animate petals in sequence with a delay
  void animatePetalsInSequence(
      {Duration delay = const Duration(milliseconds: 200)}) {
    final positions = _petalAnimators.keys.toList();
    for (int i = 0; i < positions.length; i++) {
      Future.delayed(delay * i, () {
        animatePetal(positions[i]);
      });
    }
  }

  /// Get the current state of a petal
  bool getPetalState(PetalPosition position) {
    return _petalStates[position] ?? false;
  }

  bool get isAllPetalsExpanded => _petalStates.values.every((state) => state);

  /// Reset all petal states
  void resetPetalStates() {
    for (final position in _petalStates.keys) {
      _petalStates[position] = false;
    }
  }
}
