import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:ui_showcases/6_MorphAnimations/onboarding/onboarding_flower.dart';
import 'package:ui_showcases/6_MorphAnimations/onboarding/providers/onboarding_shape_controller_provider.dart';

class OnboardingFlowerControllerExample extends HookConsumerWidget {
  const OnboardingFlowerControllerExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shapeController =
        ref.watch(onboardingShapeControllerProvider.notifier);

    final initialState = useState(true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flower Animation Controller'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Flower display area
          Positioned.fill(
            child: OnboardingFlower(bottomOffset: 0),
          ),

          // Control buttons
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Individual petal controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildPetalButton(
                        'Top Left',
                        () =>
                            shapeController.animatePetal(PetalPosition.topLeft),
                        Colors.blue,
                      ),
                      _buildPetalButton(
                        'Top Right',
                        () => shapeController
                            .animatePetal(PetalPosition.topRight),
                        Colors.green,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildPetalButton(
                        'Bottom Left',
                        () => shapeController
                            .animatePetal(PetalPosition.bottomLeft),
                        Colors.orange,
                      ),
                      _buildPetalButton(
                        'Bottom Right',
                        () => shapeController
                            .animatePetal(PetalPosition.bottomRight),
                        Colors.purple,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Group animation controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildPetalButton(
                        'All Petals',
                        () {
                          shapeController.animateAllPetals();
                          initialState.value = !initialState.value;
                        },
                        Colors.red,
                      ),
                      _buildPetalButton(
                        'Sequence',
                        () => shapeController.animatePetalsInSequence(),
                        Colors.yellow,
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  _buildPetalButton(
                    'Reset States',
                    () => shapeController.resetPetalStates(),
                    Colors.grey,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetalButton(String label, VoidCallback onPressed, Color color) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }
}
