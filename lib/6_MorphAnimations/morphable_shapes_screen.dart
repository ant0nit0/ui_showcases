import 'package:flutter/material.dart';
import 'package:ui_showcases/6_MorphAnimations/v2/morpher.dart';

class MorphableShapesShowcasePage extends StatefulWidget {
  const MorphableShapesShowcasePage({super.key});

  @override
  State<MorphableShapesShowcasePage> createState() =>
      _MorphableShapesShowcasePageState();
}

class _MorphableShapesShowcasePageState
    extends State<MorphableShapesShowcasePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Morpher();
    // return Scaffold(
    //   body: Column(
    //     mainAxisAlignment: MainAxisAlignment.center,
    //     children: [
    //       Center(
    //         child: AnimatedBuilder(
    //           animation: _controller,
    //           builder: (context, child) {
    //             return SizedBox(
    //               width: 200,
    //               height: 200,
    //               child: CustomPaint(
    //                 painter: MorphingPainter(_controller.value),
    //               ),
    //             );
    //           },
    //         ),
    //       ),
    //       ElevatedButton(
    //         onPressed: () {
    //           if (_controller.isCompleted) {
    //             _controller.reverse();
    //           } else {
    //             _controller.forward();
    //           }
    //         },
    //         child: const Text('Morph'),
    //       ),
    //     ],
    //   ),
    // );
  }
}
