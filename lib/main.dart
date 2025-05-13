import 'package:flutter/material.dart';
import 'package:ui_showcases/2_Travel/travel_app_home_screen.dart.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TravelAppHomeScreen(),
    );
  }
}
