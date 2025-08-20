import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_showcases/8_Hero/flip_hero.dart';
import 'package:ui_showcases/constants.dart';
import 'package:ui_showcases/router.dart';

class HeroScreen extends StatelessWidget {
  const HeroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kLPad),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Hero Screen'),
            const Center(
              child: FlipHero(
                tag: 'hero_widget',
                baseColor: Colors.green,
                child: Text('I am the Hero'),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.pushNamed(Routes.heroSecond.name),
              child: const Text('Go to Hero Second'),
            ),
          ],
        ),
      ),
    );
  }
}
