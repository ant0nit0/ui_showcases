import 'package:flutter/material.dart';
import 'package:ui_showcases/7_Book/3d_journal/full_page_swipeable_journal.dart';
import 'package:ui_showcases/7_Book/3d_journal/journal_controller.dart';
import 'package:ui_showcases/7_Book/3d_journal/models/journal_shadows_configuration.dart';
import 'package:ui_showcases/7_Book/3d_journal/swipeable_journal.dart';
import 'package:ui_showcases/constants.dart';

enum JournalViewMode { fullPage, twoPages }

class Journal3D extends StatelessWidget {
  final List<Widget> pages;
  final double perspective;
  final double idleTiltDegrees;
  final Duration animationDuration;
  final Curve animationCurve;
  final double flipThreshold;
  final double stackedItemsTranslateFactor;
  final Function(int)? onPageChanged;
  final double? spreadWidth;
  final JournalViewMode viewMode;
  final JournalController? controller;
  final JournalShadowsConfiguration shadowsConfiguration;
  final VoidCallback? onTap;
  final int? initialIndex;

  const Journal3D({
    super.key,
    required this.pages,
    this.perspective = .001,
    this.idleTiltDegrees = 0.0,
    this.animationDuration = const Duration(milliseconds: 350),
    this.animationCurve = Curves.easeOutCubic,
    this.flipThreshold = 0.33,
    this.stackedItemsTranslateFactor = 10.0,
    this.onPageChanged,
    this.viewMode = JournalViewMode.fullPage,
    this.spreadWidth,
    this.controller,
    this.shadowsConfiguration = const JournalShadowsConfiguration(),
    this.onTap,
    this.initialIndex,
  });
  @override
  Widget build(BuildContext context) {
    final spreadWidth =
        this.spreadWidth ?? MediaQuery.of(context).size.width - 2 * kLPad;

    if (viewMode == JournalViewMode.fullPage) {
      return SizedBox(
        width: spreadWidth,
        child: FullPageSwipeableJournal(
          key: key,
          pages: pages,
          spreadWidth: spreadWidth,
          perspective: perspective,
          idleTiltDegrees: idleTiltDegrees,
          animationDuration: animationDuration,
          animationCurve: animationCurve,
          flipThreshold: flipThreshold,
          stackedItemsTranslateFactor: stackedItemsTranslateFactor,
          shadowsConfiguration: shadowsConfiguration,
          onPageChanged: onPageChanged,
          controller: controller,
          onTap: onTap,
          initialIndex: initialIndex,
        ),
      );
    } else {
      return SwipeableJournal(
        key: key,
        pages: pages,
        perspective: perspective,
        idleTiltDegrees: idleTiltDegrees,
        animationDuration: animationDuration,
        animationCurve: animationCurve,
        flipThreshold: flipThreshold,
        stackedItemsTranslateFactor: stackedItemsTranslateFactor,
        shadowsConfiguration: shadowsConfiguration,
        onPageChanged: onPageChanged,
        controller: controller,
        onTap: onTap,
        initialIndex: initialIndex,
      );
    }
  }
}
