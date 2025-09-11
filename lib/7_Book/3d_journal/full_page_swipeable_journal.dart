import 'package:flutter/material.dart';
import 'package:ui_showcases/7_Book/3d_journal/journal_controller.dart';
import 'package:ui_showcases/7_Book/3d_journal/models/journal_shadows_configuration.dart';
import 'package:ui_showcases/7_Book/3d_journal/swipeable_journal.dart';

enum SpreadSide { left, right }

/// A wrapper around [SwipeableJournal] that allows providing full-spread pages.
///
/// Each provided page is duplicated into two widgets: one clipped to the left
/// half of the spread and one clipped to the right half. This preserves the
/// flipping logic (which expects a left and right page at consecutive indices)
/// while letting the content be designed for the entire spread width.
class FullPageSwipeableJournal extends StatelessWidget {
  final List<Widget> pages;
  final double perspective;
  final double idleTiltDegrees;
  final Duration animationDuration;
  final Curve animationCurve;
  final double flipThreshold;
  final double stackedItemsTranslateFactor;
  final Function(int)? onPageChanged;
  final double spreadWidth;
  final JournalController? controller;
  final JournalShadowsConfiguration shadowsConfiguration;
  final VoidCallback? onTap;
  final int? initialIndex;

  const FullPageSwipeableJournal({
    super.key,
    required this.pages,
    required this.spreadWidth,
    this.perspective = .001,
    this.idleTiltDegrees = 0.0,
    this.animationDuration = const Duration(milliseconds: 350),
    this.animationCurve = Curves.easeOutCubic,
    this.flipThreshold = 0.33,
    this.stackedItemsTranslateFactor = 10.0,
    this.onPageChanged,
    this.controller,
    this.shadowsConfiguration = const JournalShadowsConfiguration(),
    this.onTap,
    this.initialIndex,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> doubled = <Widget>[];
    for (final page in pages) {
      doubled.add(
        _SpreadHalf(
          side: SpreadSide.left,
          spreadWidth: spreadWidth,
          child: page,
        ),
      );
      doubled.add(
        _SpreadHalf(
          side: SpreadSide.right,
          spreadWidth: spreadWidth,
          child: page,
        ),
      );
    }

    // Convert the initialIndex to work with doubled pages
    final int? doubledInitialIndex =
        initialIndex != null ? initialIndex! * 2 : null;

    return SwipeableJournal(
      pages: doubled,
      perspective: perspective,
      idleTiltDegrees: idleTiltDegrees,
      animationDuration: animationDuration,
      animationCurve: animationCurve,
      flipThreshold: flipThreshold,
      stackedItemsTranslateFactor: stackedItemsTranslateFactor,
      shadowsConfiguration: shadowsConfiguration,
      onPageChanged: onPageChanged == null
          ? null
          : (int doubledIndex) => onPageChanged!(doubledIndex ~/ 2),
      controller: controller,
      onTap: onTap,
      initialIndex: doubledInitialIndex,
    );
  }
}

class _SpreadHalf extends StatelessWidget {
  final Widget child;
  final SpreadSide side;
  final double spreadWidth;

  const _SpreadHalf({
    required this.child,
    required this.side,
    required this.spreadWidth,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final Alignment alignment = side == SpreadSide.left
            ? Alignment.centerLeft
            : Alignment.centerRight;

        final bool hasTightWidth =
            constraints.hasBoundedWidth && constraints.maxWidth.isFinite;
        final bool hasTightHeight =
            constraints.hasBoundedHeight && constraints.maxHeight.isFinite;

        if (hasTightWidth && hasTightHeight) {
          return SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: ClipRect(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: alignment,
                child: SizedBox(
                  width: spreadWidth,
                  child: child,
                ),
              ),
            ),
          );
        }

        // Unbounded: let the child size itself naturally, and show only half
        // using Align widthFactor and ClipRect. This keeps the child's
        // intrinsic aspect ratio/size.
        return ClipRect(
          child: Align(
            alignment: alignment,
            widthFactor: 0.5,
            heightFactor: 1.0,
            child: SizedBox(
              width: spreadWidth,
              child: child,
            ),
          ),
        );
      },
    );
  }
}
