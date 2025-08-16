import 'package:flutter/foundation.dart';

/// Controller to programmatically control a journal widget.
///
/// It can be passed optionally to `Journal3D` (and underlying widgets).
/// If attached, you can call [nextPage] or [previousPage] to trigger
/// the flip animation to the next/previous spread.
class JournalController {
  VoidCallback? _onNext;
  VoidCallback? _onPrevious;

  /// Framework use only: binds the internal controls.
  /// Do not call this from outside; it is handled by the widget.
  void bindControls({
    required VoidCallback onNext,
    required VoidCallback onPrevious,
  }) {
    _onNext = onNext;
    _onPrevious = onPrevious;
  }

  /// Framework use only: unbinds the internal controls.
  void unbindControls() {
    _onNext = null;
    _onPrevious = null;
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
}
