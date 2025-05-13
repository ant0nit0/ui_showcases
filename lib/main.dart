import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_showcases/1_Fitness/fitness_app_home_screen.dart';
import 'package:ui_showcases/2_Travel/travel_app_home_screen.dart.dart';
import 'package:ui_showcases/3_Tiktok/tiktok_clone.dart';
import 'package:ui_showcases/router.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);
    return MaterialApp.router(
      title: 'UI Showcases',
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    const availablePages = {
      '1. Fitness': FitnessAppHomeScreen(),
      '2. Travel': TravelAppHomeScreen(),
      '3. Tiktok': TiktokHomeClone(),
    };

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                for (final page in availablePages.entries)
                  _makeButton(context, page.key, page.value),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _makeButton(BuildContext context, String text, Widget page) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        child: Text(text),
      ),
    );
  }
}
