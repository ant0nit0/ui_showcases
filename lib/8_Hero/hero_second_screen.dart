import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_showcases/8_Hero/flip_hero.dart';
import 'package:ui_showcases/constants.dart';

class HeroSecondScreen extends StatelessWidget {
  const HeroSecondScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(
            child: FlipHero(
              tag: 'hero_widget',
              baseColor: Colors.green,
              finalOpacityFactor: .5,
              child: Text(
                'I am the hero',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: kLPad),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Second Hero Screen'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => context.pop(),
                  child: const Text('Go back'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
