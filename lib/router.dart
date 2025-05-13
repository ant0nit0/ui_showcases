import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ui_showcases/1_Fitness/fitness_app_home_screen.dart';
import 'package:ui_showcases/2_Travel/travel_app_home_screen.dart.dart';
import 'package:ui_showcases/3_Tiktok/tiktok_clone.dart';
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
