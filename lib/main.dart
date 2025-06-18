import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
    final availablePages = {
      '1. Fitness': Routes.fitness.name,
      '2. Travel': Routes.travel.name,
      '3. Tiktok': Routes.tiktok.name,
      '4. Ecology': Routes.ecology.name,
      '5. Shaders': Routes.shaders.name,
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
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _makeButton(BuildContext context, String text, String pageName) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => context.pushNamed(pageName),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        child: Text(text),
      ),
    );
  }
}
