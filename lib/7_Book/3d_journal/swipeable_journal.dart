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
  final JournalController controller;
  final JournalShadowsConfiguration shadowsConfiguration;
  final VoidCallback? onTap;

  const SwipeableJournal({
    super.key,
    required this.controller,
    this.shadowsConfiguration = const JournalShadowsConfiguration(),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Create and manage animation controller
    final animationController = useAnimationController(
      duration: controller.animationDuration,
    );
    useListenable(animationController);

    // Set animation controller immediately - use useEffect but ensure it runs
    useEffect(() {
      // Set the animation controller
      controller.setAnimationController(animationController);
      debugPrint('🔗 SwipeableJournal: AnimationController set');

      // Cleanup only on dispose
      return () {
        debugPrint('🔗 SwipeableJournal: Cleaning up AnimationController');
        controller.removeAnimationController();
      };
    }, [
      animationController
    ]); // Only depend on controller, not animationController

    // Local state for gesture handling
    final initialDragX = useState<double?>(null);

    // Listen to controller changes
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final double spreadWidth = constraints.maxWidth;
            final swipeProgress = controller.effectiveProgress;

            return AbsorbPointer(
              absorbing: controller.isAnimating,
              child: GestureDetector(
                onTap: onTap,
                onHorizontalDragStart: (details) {
                  if (controller.isAnimating) return;
                  initialDragX.value = details.localPosition.dx;
                },
                onHorizontalDragUpdate: (details) {
                  if (controller.isAnimating) return;
                  final double start =
                      initialDragX.value ?? details.localPosition.dx;
                  final double deltaX = details.localPosition.dx - start;

                  bool isLastOrFirstPage = false;
                  SwipeDirection? candidateDirection;

                  if (controller.swipeDirection == null) {
                    candidateDirection = deltaX > 0
                        ? SwipeDirection.leftToRight
                        : SwipeDirection.rightToLeft;
                    if (!controller.canSwipe(candidateDirection)) {
                      isLastOrFirstPage = true;
                      debugPrint('Swipe should not be allowed');
                    }
                    controller.updateProgress(candidateDirection, 0.0);
                  } else {
                    candidateDirection = controller.swipeDirection;
                    if (controller.swipeDirection ==
                        SwipeDirection.rightToLeft) {
                      if (controller.currentPageIndex + 2 >=
                          controller.totalPages) {
                        isLastOrFirstPage = true;
                      }
                    } else {
                      if (controller.currentPageIndex - 2 < 0) {
                        isLastOrFirstPage = true;
                      }
                    }
                  }

                  final max = isLastOrFirstPage ? .4 : 1.0;
                  final double magnitude = (deltaX.abs() / spreadWidth).clamp(
                    0.0,
                    1.0,
                  );
                  final reducedMagnitude = magnitude * max;
                  controller.updateProgress(
                    candidateDirection!,
                    reducedMagnitude,
                  );
                },
                onHorizontalDragEnd: (details) {
                  if (controller.isAnimating) return;
                  if (controller.swipeDirection == null) {
                    controller.updateProgress(
                      SwipeDirection.rightToLeft,
                      0.0,
                    );
                    return;
                  }

                  final SwipeDirection dir = controller.swipeDirection!;
                  final bool allowed = controller.canSwipe(dir);
                  final double magnitude =
                      controller.swipeProgress.clamp(0.0, 1.0);
                  final bool commit =
                      allowed && magnitude >= controller.flipThreshold;

                  controller.startAnimation(
                    commit: commit,
                    direction: dir,
                    from: magnitude,
                  );
                },
                onHorizontalDragCancel: () {
                  if (controller.isAnimating) return;
                  if (controller.swipeDirection != null) {
                    controller.startAnimation(
                      commit: false,
                      direction: controller.swipeDirection!,
                      from: controller.swipeProgress,
                    );
                  }
                },
                child: ColoredBox(
                  // Didn't really search why, but we need a colored box in order to detect taps events on the journal :)
                  color: Colors.transparent,
                  child: JournalRenderer(
                    perspective: controller.perspective,
                    idleTiltRadians:
                        controller.idleTiltDegrees * math.pi / 180.0,
                    currentPageIndex: controller.currentPageIndex,
                    swipeProgress: swipeProgress,
                    swipeDirection: controller.swipeDirection,
                    stackedItemsTranslateFactor:
                        controller.stackedItemsTranslateFactor,
                    shadowsConfiguration: shadowsConfiguration,
                    children: controller.renderPages,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
