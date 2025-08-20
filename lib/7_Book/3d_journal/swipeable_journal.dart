import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:ui_showcases/7_Book/3d_journal/journal_controller.dart';
import 'package:ui_showcases/7_Book/3d_journal/journal_renderer.dart';
import 'package:ui_showcases/7_Book/3d_journal/models/journal_shadows_configuration.dart';

enum SwipeDirection {
  leftToRight,
  rightToLeft,
}

class SwipeableJournal extends HookWidget {
  final List<Widget> pages;
  final double perspective;
  final double idleTiltDegrees;
  final Duration animationDuration;
  final Curve animationCurve;
  final double flipThreshold;
  final double stackedItemsTranslateFactor;
  final JournalShadowsConfiguration shadowsConfiguration;

  final Function(int)? onPageChanged;
  final JournalController? controller;
  final VoidCallback? onTap;

  const SwipeableJournal({
    super.key,
    required this.pages,
    this.perspective = .001,
    this.idleTiltDegrees = 0.0,
    this.animationDuration = const Duration(milliseconds: 350),
    this.animationCurve = Curves.easeOutCubic,
    this.flipThreshold = 0.33,
    this.stackedItemsTranslateFactor = 10.0,
    this.shadowsConfiguration = const JournalShadowsConfiguration(),
    this.onPageChanged,
    this.controller,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currentPageIndex = useState(0);
    final swipeProgress = useState(0.0); // 0..1
    final swipeDirection = useState<SwipeDirection?>(null);
    final initialDragX = useState<double?>(null);

    final animating = useState(false);
    final animationController = useAnimationController(
      duration: animationDuration,
    );
    useListenable(animationController);

    bool canSwipe(SwipeDirection dir) {
      if (dir == SwipeDirection.rightToLeft) {
        return currentPageIndex.value + 2 < pages.length;
      } else {
        return currentPageIndex.value - 2 >= 0;
      }
    }

    Future<void> startAnimation({
      required bool commit,
      required SwipeDirection direction,
      required double from,
    }) async {
      animating.value = true;
      animationController.stop();
      animationController.value = from.clamp(0.0, 1.0);

      final double remaining =
          (commit ? 1.0 - animationController.value : animationController.value)
              .clamp(0.0, 1.0);
      final int millis =
          (animationDuration.inMilliseconds * remaining).clamp(80, 450).toInt();

      if (commit) {
        await animationController
            .animateTo(
          1.0,
          duration: Duration(milliseconds: millis),
          curve: animationCurve,
        )
            .whenComplete(() async {
          animating.value = false;
          swipeProgress.value = 0.0;
          final dir = swipeDirection.value ?? direction;
          swipeDirection.value = null;

          if (dir == SwipeDirection.rightToLeft &&
              currentPageIndex.value + 2 < pages.length) {
            currentPageIndex.value += 2;
          } else if (dir == SwipeDirection.leftToRight &&
              currentPageIndex.value - 2 >= 0) {
            currentPageIndex.value -= 2;
          }
          animationController.value = 0.0;
          await onPageChanged?.call(currentPageIndex.value);
        });
      } else {
        await animationController
            .animateBack(
          0.0,
          duration: Duration(milliseconds: millis),
          curve: animationCurve,
        )
            .whenComplete(() async {
          animating.value = false;
          swipeProgress.value = 0.0;
          swipeDirection.value = null;
          animationController.value = 0.0;
          await onPageChanged?.call(currentPageIndex.value);
        });
      }
    }

    Future<bool> goNext() async {
      if (animating.value) return false;
      if (!canSwipe(SwipeDirection.rightToLeft)) return false;
      swipeDirection.value = SwipeDirection.rightToLeft;
      await startAnimation(
        commit: true,
        direction: SwipeDirection.rightToLeft,
        from: 0.0,
      );
      return true;
    }

    Future<bool> goPrevious() async {
      if (animating.value) return false;
      if (!canSwipe(SwipeDirection.leftToRight)) return false;
      swipeDirection.value = SwipeDirection.leftToRight;
      await startAnimation(
        commit: true,
        direction: SwipeDirection.leftToRight,
        from: 0.0,
      );
      return true;
    }

    void updateProgress(SwipeDirection direction, double progress) {
      debugPrint('updateProgress: $progress');
      if (animating.value) {
        debugPrint('animating - updateProgress - abort');
        return;
      }
      if (!canSwipe(direction)) {
        debugPrint("Can't swipe - updateProgress - abort");
        return;
      }

      swipeDirection.value = direction;
      swipeProgress.value = progress.clamp(0.0, 1.0);
    }

    Future<bool> animateTo(int index) async {
      if (animating.value) return false;
      if (index < 0 || index >= pages.length) return false;

      final i = index * 2;

      final forward = i > currentPageIndex.value;
      do {
        if (forward) {
          await goNext();
        } else {
          await goPrevious();
        }
      } while (currentPageIndex.value != i);

      return true;
    }

    useEffect(() {
      controller?.bindControls(
        onNext: goNext,
        onPrevious: goPrevious,
        onUpdateProgress: updateProgress,
        onAnimateTo: animateTo,
      );
      return () {
        controller?.unbindControls();
      };
    }, [controller, pages.length]);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double spreadWidth = constraints.maxWidth;
        return AbsorbPointer(
          absorbing: animating.value,
          child: GestureDetector(
            onTap: onTap,
            onHorizontalDragStart: (details) {
              if (animating.value) return;
              initialDragX.value = details.localPosition.dx;
            },
            onHorizontalDragUpdate: (details) {
              if (animating.value) return;
              final double start =
                  initialDragX.value ?? details.localPosition.dx;
              final double deltaX = details.localPosition.dx - start;

              if (swipeDirection.value == null) {
                final SwipeDirection candidate = deltaX > 0
                    ? SwipeDirection.leftToRight
                    : SwipeDirection.rightToLeft;
                if (!canSwipe(candidate)) {
                  return; // Disallow swipe in this direction
                }
                swipeDirection.value = candidate;
              }

              final double magnitude = (deltaX.abs() / spreadWidth).clamp(
                0.0,
                1.0,
              );
              swipeProgress.value = magnitude;
            },
            onHorizontalDragEnd: (details) {
              if (animating.value) return;
              if (swipeDirection.value == null) {
                swipeProgress.value = 0.0;
                return;
              }

              final SwipeDirection dir = swipeDirection.value!;
              final bool allowed = canSwipe(dir);
              final double magnitude = swipeProgress.value.clamp(0.0, 1.0);
              final bool commit = allowed && magnitude >= flipThreshold;

              startAnimation(commit: commit, direction: dir, from: magnitude);
            },
            onHorizontalDragCancel: () {
              if (animating.value) return;
              if (swipeDirection.value != null) {
                startAnimation(
                  commit: false,
                  direction: swipeDirection.value!,
                  from: swipeProgress.value,
                );
              }
            },
            child: ColoredBox(
              // Didn't really search why, but we need a colored box in order to detect taps events on the journal :)
              color: Colors.transparent,
              child: JournalRenderer(
                perspective: perspective,
                idleTiltRadians: idleTiltDegrees * math.pi / 180.0,
                currentPageIndex: currentPageIndex.value,
                swipeProgress: animating.value
                    ? animationController.value
                    : swipeProgress.value,
                swipeDirection: animating.value
                    ? (swipeDirection.value)
                    : swipeDirection.value,
                stackedItemsTranslateFactor: stackedItemsTranslateFactor,
                shadowsConfiguration: shadowsConfiguration,
                children: pages,
              ),
            ),
          ),
        );
      },
    );
  }
}
