import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_showcases/1_Fitness/fitness_app_home_screen.dart';
import 'package:ui_showcases/2_Travel/travel_app_home_screen.dart.dart';
import 'package:ui_showcases/3_Tiktok/tiktok_clone.dart';
import 'package:ui_showcases/4_Ecology/ecology_app_launch_screen.dart';
import 'package:ui_showcases/5_Shaders/shaders_showcase_page.dart';
import 'package:ui_showcases/6_MorphAnimations/morphable_shapes_screen.dart';
import 'package:ui_showcases/6_MorphAnimations/onboarding/onboarding_flower_controller_example.dart';
import 'package:ui_showcases/7_Book/book_screen.dart';
import 'package:ui_showcases/8_Hero/hero_screen.dart';
import 'package:ui_showcases/8_Hero/hero_second_screen.dart';
import 'package:ui_showcases/main.dart';

final goRouterProvider = Provider<GoRouter>((ref) => generateRouter());

extension GoRouterRiverpod on Ref {
  GoRouter get goRouter => read(goRouterProvider);
}

final navigatorKey = GlobalKey<NavigatorState>();

class KRoute {
  final String name;
  final String path;

  const KRoute({required this.name}) : path = '/$name';

  const KRoute.custom({required this.name, required this.path});
}

class Routes {
  static const home = KRoute.custom(name: 'home', path: '/');

  static const fitness = KRoute(name: 'fitness');
  static const travel = KRoute(name: 'travel');
  static const tiktok = KRoute(name: 'tiktok');
  static const ecology = KRoute(name: 'ecology');
  static const shaders = KRoute(name: 'shaders');
  static const morphableShapes = KRoute(name: 'morphableShapes');
  static const flowerController = KRoute(name: 'flowerController');
  static const book = KRoute(name: 'book');
  static const hero = KRoute(name: 'hero');
  static const heroSecond = KRoute(name: 'heroSecond');
}

// Custom page transition for hero animation
class HeroPageTransition extends CustomTransitionPage<void> {
  HeroPageTransition({
    required super.child,
    required super.transitionsBuilder,
    Duration? transitionDuration,
  }) : super(
          transitionDuration:
              transitionDuration ?? const Duration(milliseconds: 800),
          reverseTransitionDuration:
              transitionDuration ?? const Duration(milliseconds: 800),
        );
}

GoRouter generateRouter({
  String? initialLocation,
  List<GoRoute>? additionalRoutes,
  List<NavigatorObserver>? observers,
}) {
  return GoRouter(
      initialLocation: Routes.home.path,
      navigatorKey: navigatorKey,
      errorBuilder: (context, state) => const PageNotFound(),
      observers: [
        ...?observers,
      ],
      routes: [
        // Home
        GoRoute(
          name: Routes.home.name,
          path: Routes.home.path,
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          name: Routes.fitness.name,
          path: Routes.fitness.path,
          builder: (context, state) => const FitnessAppHomeScreen(),
        ),
        GoRoute(
          name: Routes.travel.name,
          path: Routes.travel.path,
          builder: (context, state) => const TravelAppHomeScreen(),
        ),
        GoRoute(
          name: Routes.tiktok.name,
          path: Routes.tiktok.path,
          builder: (context, state) => const TiktokHomeClone(),
        ),
        GoRoute(
          name: Routes.ecology.name,
          path: Routes.ecology.path,
          builder: (context, state) => const EcologyAppLaunchScreen(),
        ),
        GoRoute(
          name: Routes.shaders.name,
          path: Routes.shaders.path,
          builder: (context, state) => const ShadersShowcasePage(),
        ),
        GoRoute(
          name: Routes.morphableShapes.name,
          path: Routes.morphableShapes.path,
          builder: (context, state) => const MorphableShapesShowcasePage(),
        ),
        GoRoute(
          name: Routes.flowerController.name,
          path: Routes.flowerController.path,
          builder: (context, state) =>
              const OnboardingFlowerControllerExample(),
        ),
        GoRoute(
          name: Routes.book.name,
          path: Routes.book.path,
          builder: (context, state) => const BookScreen(),
        ),
        GoRoute(
          name: Routes.hero.name,
          path: Routes.hero.path,
          builder: (context, state) => const HeroScreen(),
        ),
        GoRoute(
          name: Routes.heroSecond.name,
          path: Routes.heroSecond.path,
          pageBuilder: (context, state) => HeroPageTransition(
            transitionDuration:
                const Duration(milliseconds: 1200), // Custom duration
            child: const HeroSecondScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
        ),
      ]);
}

class PageNotFound extends StatelessWidget {
  final String? message;
  const PageNotFound({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text(message ?? '404 - Page not found')),
    );
  }
}
