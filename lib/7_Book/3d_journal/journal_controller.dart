import 'package:ui_showcases/7_Book/3d_journal/swipeable_journal.dart';

/// Controller to programmatically control a journal widget.
///
/// It can be passed optionally to `Journal3D` (and underlying widgets).
/// If attached, you can call [nextPage] or [previousPage] to trigger
/// the flip animation to the next/previous spread.
class JournalController {
  Future<bool> Function()? _onNext;
  Future<bool> Function()? _onPrevious;
  Future<bool> Function(int index)? _onAnimateTo;
  void Function(SwipeDirection direction, double progress)? _onUpdateProgress;

  /// Framework use only: binds the internal controls.
  /// Do not call this from outside; it is handled by the widget.
  void bindControls({
    required Future<bool> Function() onNext,
    required Future<bool> Function() onPrevious,
    required Future<bool> Function(int index) onAnimateTo,
    void Function(SwipeDirection direction, double progress)? onUpdateProgress,
  }) {
    _onNext = onNext;
    _onPrevious = onPrevious;
    _onAnimateTo = onAnimateTo;
    _onUpdateProgress = onUpdateProgress;
  }

  /// Framework use only: unbinds the internal controls.
  void unbindControls() {
    _onNext = null;
    _onPrevious = null;
    _onAnimateTo = null;
    _onUpdateProgress = null;
  }

  /// Tries to flip to the next spread.
  ///
  /// Returns true if the page was flipped, false otherwise.
  Future<bool> nextPage() async {
    final cb = _onNext;
    if (cb == null) return false;
    final result = await cb.call();
    return result;
  }

  /// Tries to flip to the previous spread.
  ///
  /// Returns true if the page was flipped, false otherwise.
  Future<bool> previousPage() async {
    final cb = _onPrevious;
    if (cb == null) return false;
    final result = await cb.call();
    return result;
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

  /// Animates to the given page index.
  ///
  /// Returns true if the animation has completed, false otherwise.
  Future<bool> animateTo(int index) async {
    final cb = _onAnimateTo;
    if (cb == null) return false;
    final result = await cb.call(index);
    return result;
  }
}
