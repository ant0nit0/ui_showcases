import 'package:flutter/material.dart';
import 'package:ui_showcases/constants.dart';

class JournalFakePage extends StatelessWidget {
  final int index;
  const JournalFakePage({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    const double baseWidth = 600;
    const double baseHeight = 900; // 2:3 aspect ratio

    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: kColors[index % kColors.length],
        borderRadius: BorderRadius.circular(12),
      ),
      width: (MediaQuery.of(context).size.width - 2 * kLPad) / 2,
      child: const AspectRatio(
        aspectRatio: baseWidth / baseHeight,
        child: IgnorePointer(
          child: Center(
            child: FittedBox(
              child: SizedBox(
                width: baseWidth,
                height: baseHeight,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
