import 'package:flutter/foundation.dart';
import 'package:ui_showcases/7_Book/3d_journal/swipeable_journal.dart';

/// Controller to programmatically control a journal widget.
///
/// It can be passed optionally to `Journal3D` (and underlying widgets).
/// If attached, you can call [nextPage] or [previousPage] to trigger
/// the flip animation to the next/previous spread.
class JournalController {
  VoidCallback? _onNext;
  VoidCallback? _onPrevious;
  void Function(SwipeDirection direction, double progress)? _onUpdateProgress;

  /// Framework use only: binds the internal controls.
  /// Do not call this from outside; it is handled by the widget.
  void bindControls({
    required VoidCallback onNext,
    required VoidCallback onPrevious,
    void Function(SwipeDirection direction, double progress)? onUpdateProgress,
  }) {
    _onNext = onNext;
    _onPrevious = onPrevious;
    _onUpdateProgress = onUpdateProgress;
  }

  /// Framework use only: unbinds the internal controls.
  void unbindControls() {
    _onNext = null;
    _onPrevious = null;
    _onUpdateProgress = null;
  }

  /// Tries to flip to the next spread.
  ///
  /// Returns true if the action was dispatched (controller is attached
  /// and the widget will attempt to animate), false otherwise.
  bool nextPage() {
    final cb = _onNext;
    if (cb == null) return false;
    cb();
    return true;
  }

  /// Tries to flip to the previous spread.
  ///
  /// Returns true if the action was dispatched (controller is attached
  /// and the widget will attempt to animate), false otherwise.
  bool previousPage() {
    final cb = _onPrevious;
    if (cb == null) return false;
    cb();
    return true;
  }

  /// Updates the swipe progress programmatically.
  ///
  /// [direction] specifies the swipe direction (leftToRight or rightToLeft).
  /// [progress] should be a value between 0.0 and 1.0 representing the swipe progress.
  ///
  /// Returns true if the action was dispatched (controller is attached),
  /// false otherwise.
  bool updateProgress(SwipeDirection direction, double progress) {
    final cb = _onUpdateProgress;
    if (cb == null) return false;
    cb(direction, progress.clamp(0.0, 1.0));
    return true;
  }
}
