import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:morphable_shape/morphable_shape.dart';
import 'package:ui_showcases/6_MorphAnimations/onboarding/onboarding_petal_configuration.dart';
import 'package:ui_showcases/6_MorphAnimations/onboarding/providers/onboarding_shape_controller_provider.dart';
import 'package:ui_showcases/6_MorphAnimations/onboarding/shapes/onboarding_shape.dart';

class OnboardingPetal extends ConsumerStatefulWidget {
  final Gradient gradient;
  final Gradient? secondGradient;
  final double size;
  final double secondSize;
  final bool clockwiseRotation;
  final Duration animationDuration;
  final VoidCallback? onTap;
  final OnboardingPetalOrientation petalStyle;
  final OnboardingPetalOrientation secondPetalStyle;
  final PetalPosition position;

  const OnboardingPetal({
    super.key,
    this.gradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Colors.blue, Colors.purple],
    ),
    this.secondGradient,
    this.size = 200.0,
    this.secondSize = 100.0,
    this.clockwiseRotation = true,
    this.animationDuration = const Duration(milliseconds: 1600),
    this.onTap,
    this.petalStyle = OnboardingPetalOrientation.topRight,
    this.secondPetalStyle = OnboardingPetalOrientation.topLeft,
    required this.position,
  });

  @override
  ConsumerState<OnboardingPetal> createState() => _OnboardingPetalState();
}

class _OnboardingPetalState extends ConsumerState<OnboardingPetal>
    with SingleTickerProviderStateMixin {
  late List<OnboardingPetalConfiguration> _morphableItems;
  int _currentIndex = 0;
  late AnimationController _controller;
  late Animation<double> _morphAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _gradientAnimation;

  @override
  void initState() {
    super.initState();
    _initializeMorphableItems();
    _initializeAnimations();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _currentIndex++;
          _controller.value = 0.0;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Register this petal's animation callback with the controller
    final shapeController =
        ref.read(onboardingShapeControllerProvider.notifier);
    shapeController.registerPetal(widget.position, _animateToNextShape);
  }

  void _initializeMorphableItems() {
    final fistShape = OnboardingPetalShape(petalStyle: widget.petalStyle);

    final firstShapeBorder = RoundedRectangleShapeBorder.fromJson(
      fistShape.toJson(),
    );

    final secondShape =
        OnboardingPetalShape(petalStyle: widget.secondPetalStyle);

    final secondShapeBorder = RoundedRectangleShapeBorder.fromJson(
      secondShape.toJson(),
    );

    _morphableItems = [
      OnboardingPetalConfiguration(
          shape: firstShapeBorder, gradient: widget.gradient),
      OnboardingPetalConfiguration(
        shape: secondShapeBorder,
        gradient: widget.secondGradient ?? widget.gradient,
      ),
    ];
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _morphAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutBack,
    );

    _rotationAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );

    _gradientAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    // Unregister this petal's animation callback
    final shapeController =
        ref.read(onboardingShapeControllerProvider.notifier);
    shapeController.unregisterPetal(widget.position);
    _controller.dispose();
    super.dispose();
  }

  OnboardingPetalConfiguration get _currentItem =>
      _morphableItems[_currentIndex % _morphableItems.length];
  OnboardingPetalConfiguration get _nextItem =>
      _morphableItems[(_currentIndex + 1) % _morphableItems.length];

  void _animateToNextShape() {
    if (_controller.isAnimating) return; // Prevent double-tap issues
    _controller.forward(from: 0.0);
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _animateToNextShape,
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            ShapeBorder shape;
            // ignore: unused_local_variable
            double _size;
            if (_controller.isAnimating || _controller.value > 0.0) {
              final tween = MorphableShapeBorderTween(
                begin: _currentItem.shape,
                end: _nextItem.shape,
                method: MorphMethod.auto,
              );
              shape = tween.lerp(_morphAnimation.value) ?? _currentItem.shape;
              _size = lerpDouble(
                      widget.size, widget.secondSize, _morphAnimation.value) ??
                  widget.size;
            } else {
              shape = _currentItem.shape;
              final sizes = [widget.size, widget.secondSize];
              _size = sizes[_currentIndex % sizes.length];
            }

            return Transform.rotate(
              angle: _rotationAnimation.value *
                  2 *
                  3.14159 *
                  (widget.clockwiseRotation ? 1 : -1),
              child: ClipPath(
                clipper: ShapeBorderClipper(shape: shape),
                child: AnimatedBuilder(
                  animation: _gradientAnimation,
                  builder: (context, child) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 800),
                      decoration: BoxDecoration(
                        gradient: _gradientAnimation.value < 0.5
                            ? _currentItem.gradient
                            : _nextItem.gradient,
                      ),
                      width: _size,
                      height: _size,
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
