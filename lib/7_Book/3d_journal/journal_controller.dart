import 'package:flutter/material.dart';
import 'package:ui_showcases/7_Book/3d_journal/swipeable_journal.dart';

/// View mode for the journal.
enum JournalViewMode {
  /// Full-page mode: each page is a full spread, split into left/right halves
  fullPage,

  /// Two-page mode: pages are already split into left/right pairs
  twoPages,
}

/// Controller to programmatically control a journal widget.
///
/// This controller manages all state and business logic for the journal.
/// The widget should be a reactive view that listens to this controller.
class JournalController extends ChangeNotifier {
  // Pages management
  List<Widget> _pages;
  List<Widget> get pages => List.unmodifiable(_pages);
  int get totalPages => _pages.length;

  // State
  late int _currentPageIndex;
  int get currentPageIndex => _currentPageIndex;

  double _swipeProgress = 0.0;
  double get swipeProgress => _swipeProgress;

  SwipeDirection? _swipeDirection;
  SwipeDirection? get swipeDirection => _swipeDirection;

  bool _isAnimating = false;
  bool get isAnimating => _isAnimating;

  // Configuration
  final double perspective;
  final double idleTiltDegrees;
  final Duration animationDuration;
  final Curve animationCurve;
  final double flipThreshold;
  final double stackedItemsTranslateFactor;

  // View mode and layout
  JournalViewMode _viewMode;
  JournalViewMode get viewMode => _viewMode;
  double? _spreadWidth;
  double? get spreadWidth => _spreadWidth;

  // Animation controller (provided by widget)
  AnimationController? _animationController;

  // Cache for render pages (doubled pages in full-page mode)
  List<Widget>? _renderPagesCache;

  /// Gets the current animation value (0.0 to 1.0) when animating.
  /// Returns swipeProgress when not animating.
  double get effectiveProgress {
    if (_isAnimating && _animationController != null) {
      return _animationController!.value;
    }
    return _swipeProgress;
  }

  // Callbacks
  Function(int)? onPageChanged;

  JournalController({
    required List<Widget> pages,
    int? initialIndex,
    this.perspective = .001,
    this.idleTiltDegrees = 0.0,
    this.animationDuration = const Duration(milliseconds: 350),
    this.animationCurve = Curves.easeOutCubic,
    this.flipThreshold = 0.33,
    this.stackedItemsTranslateFactor = 10.0,
    JournalViewMode viewMode = JournalViewMode.twoPages,
    double? spreadWidth,
    this.onPageChanged,
  })  : _pages = List.from(pages),
        _viewMode = viewMode,
        _spreadWidth = spreadWidth {
    // Calculate initial index based on view mode
    final renderIndex = initialIndex != null
        ? (viewMode == JournalViewMode.fullPage
            ? initialIndex * 2
            : initialIndex * 2)
        : null;
    final renderPagesLength = viewMode == JournalViewMode.fullPage
        ? (spreadWidth != null ? pages.length * 2 : pages.length)
        : pages.length;
    _currentPageIndex = _validateInitialIndex(renderIndex, renderPagesLength);
  }

  /// Validates the initial index and returns a valid page index.
  ///
  /// If [initialIndex] is null, returns 0.
  /// If [initialIndex] is out of bounds, clamps it to the valid range.
  /// The returned index is always even (0, 2, 4, ...) to ensure proper page display.
  static int _validateInitialIndex(int? initialIndex, int pagesLength) {
    if (initialIndex == null) return 0;

    // Ensure the index is within bounds
    final clampedIndex = initialIndex.clamp(0, pagesLength - 1);

    // Ensure the index is even (0, 2, 4, ...) for proper page display
    // This is because the journal displays pages in pairs
    return (clampedIndex ~/ 2) * 2;
  }

  /// Framework use only: sets the animation controller.
  /// Do not call this from outside; it is handled by the widget.
  void setAnimationController(AnimationController controller) {
    debugPrint('🔗 setAnimationController: $controller');
    _animationController = controller;
  }

  /// Framework use only: removes the animation controller.
  void removeAnimationController() {
    debugPrint('🔗 removeAnimationController called');
    _animationController = null;
  }

  /// Sets the view mode for the journal.
  void setViewMode(JournalViewMode mode, {double? spreadWidth}) {
    if (_viewMode != mode || _spreadWidth != spreadWidth) {
      _viewMode = mode;
      _spreadWidth = spreadWidth;
      _renderPagesCache = null; // Invalidate cache
      notifyListeners();
    }
  }

  /// Gets the pages formatted for rendering (doubled in full-page mode).
  List<Widget> get renderPages {
    if (_viewMode == JournalViewMode.twoPages) {
      return _pages;
    }

    // Full-page mode: double the pages
    if (_renderPagesCache != null &&
        _renderPagesCache!.length == _pages.length * 2) {
      return _renderPagesCache!;
    }

    if (_spreadWidth == null) {
      debugPrint(
          'Warning: spreadWidth is null in full-page mode, using pages as-is');
      return _pages;
    }

    _renderPagesCache = _createDoubledPages(_pages, _spreadWidth!);
    return _renderPagesCache!;
  }

  /// Creates doubled pages for full-page mode.
  List<Widget> _createDoubledPages(
      List<Widget> originalPages, double spreadWidth) {
    final List<Widget> doubled = <Widget>[];
    for (final page in originalPages) {
      doubled.add(_SpreadHalf(
        side: _SpreadSide.left,
        spreadWidth: spreadWidth,
        child: page,
      ));
      doubled.add(_SpreadHalf(
        side: _SpreadSide.right,
        spreadWidth: spreadWidth,
        child: page,
      ));
    }
    return doubled;
  }

  /// Checks if swiping in the given direction is allowed.
  bool canSwipe(SwipeDirection dir) {
    final renderPagesLength = renderPages.length;
    if (dir == SwipeDirection.rightToLeft) {
      return _currentPageIndex + 2 < renderPagesLength;
    } else {
      return _currentPageIndex - 2 >= 0;
    }
  }

  /// Starts an animation to flip the page.
  Future<void> startAnimation({
    required bool commit,
    required SwipeDirection direction,
    required double from,
  }) async {
    if (_animationController == null) {
      debugPrint(
          'AnimationController not set : ${_animationController?.value}');
      return;
    }

    _isAnimating = true;
    notifyListeners();

    _animationController!.stop();
    _animationController!.value = from.clamp(0.0, 1.0);

    final double remaining = (commit
            ? 1.0 - _animationController!.value
            : _animationController!.value)
        .clamp(0.0, 1.0);
    final int millis =
        (animationDuration.inMilliseconds * remaining).clamp(80, 450).toInt();

    if (commit) {
      await _animationController!
          .animateTo(
        1.0,
        duration: Duration(milliseconds: millis),
        curve: animationCurve,
      )
          .whenComplete(() async {
        _isAnimating = false;
        _swipeProgress = 0.0;
        final dir = _swipeDirection ?? direction;
        _swipeDirection = null;

        final renderPagesLength = renderPages.length;
        if (dir == SwipeDirection.rightToLeft &&
            _currentPageIndex + 2 < renderPagesLength) {
          _currentPageIndex += 2;
        } else if (dir == SwipeDirection.leftToRight &&
            _currentPageIndex - 2 >= 0) {
          _currentPageIndex -= 2;
        }
        _animationController!.value = 0.0;
        notifyListeners();
        // Call callback with original page index
        final originalIndex = _viewMode == JournalViewMode.fullPage
            ? _currentPageIndex ~/ 2
            : _currentPageIndex ~/ 2;
        await onPageChanged?.call(originalIndex);
      });
    } else {
      await _animationController!
          .animateBack(
        0.0,
        duration: Duration(milliseconds: millis),
        curve: animationCurve,
      )
          .whenComplete(() async {
        _isAnimating = false;
        _swipeProgress = 0.0;
        _swipeDirection = null;
        _animationController!.value = 0.0;
        notifyListeners();
        // Call callback with original page index
        final originalIndex = _viewMode == JournalViewMode.fullPage
            ? _currentPageIndex ~/ 2
            : _currentPageIndex ~/ 2;
        await onPageChanged?.call(originalIndex);
      });
    }
  }

  /// Tries to flip to the next spread.
  ///
  /// Returns true if the page was flipped, false otherwise.
  Future<bool> nextPage() async {
    debugPrint('🔥 nextPage');
    if (_isAnimating) {
      debugPrint('🔥 nextPage - is already animating - aborting \n');
      return false;
    }
    if (!canSwipe(SwipeDirection.rightToLeft)) {
      debugPrint('🔥 nextPage - can\'t swipe - aborting \n');
      return false;
    }
    _swipeDirection = SwipeDirection.rightToLeft;
    await startAnimation(
      commit: true,
      direction: SwipeDirection.rightToLeft,
      from: 0.0,
    );
    return true;
  }

  /// Tries to flip to the previous spread.
  ///
  /// Returns true if the page was flipped, false otherwise.
  Future<bool> previousPage() async {
    if (_isAnimating) return false;
    if (!canSwipe(SwipeDirection.leftToRight)) return false;
    _swipeDirection = SwipeDirection.leftToRight;
    await startAnimation(
      commit: true,
      direction: SwipeDirection.leftToRight,
      from: 0.0,
    );
    return true;
  }

  /// Updates the swipe progress programmatically.
  ///
  /// [direction] specifies the swipe direction (leftToRight or rightToLeft).
  /// [progress] should be a value between 0.0 and 1.0 representing the swipe progress.
  void updateProgress(SwipeDirection direction, double progress) {
    if (_isAnimating) {
      debugPrint('animating - updateProgress - abort');
      return;
    }
    if (!canSwipe(direction)) {
      debugPrint("Can't swipe - updateProgress - abort");
      return;
    }

    _swipeDirection = direction;
    _swipeProgress = progress.clamp(0.0, 1.0);
    notifyListeners();
  }

  /// Animates to the given page index.
  ///
  /// In two-page mode, [index] refers to the page index.
  /// In full-page mode, [index] refers to the spread index (which becomes index * 2 in render pages).
  ///
  /// Returns true if the animation has completed, false otherwise.
  Future<bool> animateTo(int index) async {
    if (_isAnimating) return false;
    if (index < 0 || index >= _pages.length) return false;

    // Convert to render page index
    final renderIndex =
        _viewMode == JournalViewMode.fullPage ? index * 2 : index * 2;
    final renderPagesLength = renderPages.length;

    if (renderIndex >= renderPagesLength) return false;

    final forward = renderIndex > _currentPageIndex;
    do {
      if (forward) {
        await nextPage();
      } else {
        await previousPage();
      }
    } while (_currentPageIndex != renderIndex);

    return true;
  }

  /// Jumps to the given page index without animation.
  ///
  /// In two-page mode, [index] refers to the page index.
  /// In full-page mode, [index] refers to the spread index (which becomes index * 2 in render pages).
  ///
  /// Returns true if the jump was successful, false otherwise.
  bool jumpTo(int index) {
    if (_isAnimating) return false;
    if (index < 0 || index >= _pages.length) return false;

    // Convert to render page index
    final renderIndex =
        _viewMode == JournalViewMode.fullPage ? index * 2 : index * 2;
    final renderPagesLength = renderPages.length;

    if (renderIndex >= renderPagesLength) return false;

    final validatedIndex =
        _validateInitialIndex(renderIndex, renderPagesLength);
    _currentPageIndex = validatedIndex;
    _swipeProgress = 0.0;
    _swipeDirection = null;
    notifyListeners();
    // Call callback with original page index
    final originalIndex = _viewMode == JournalViewMode.fullPage
        ? _currentPageIndex ~/ 2
        : _currentPageIndex ~/ 2;
    onPageChanged?.call(originalIndex);
    return true;
  }

  // Pages management methods

  /// Adds a page just after the current one.
  ///
  /// If [animate] is true (default), automatically animates to the newly added page.
  Future<void> addPage(Widget page, {bool animate = true}) async {
    // Get current page index in original pages space
    final currentOriginalIndex = _viewMode == JournalViewMode.fullPage
        ? _currentPageIndex ~/ 2
        : _currentPageIndex ~/ 2;

    // Insert the page right after the current one
    final insertIndex = currentOriginalIndex + 1;
    _pages.insert(insertIndex, page);
    _renderPagesCache = null; // Invalidate cache

    // Adjust current page index if needed (in render pages space)
    final renderIndex = _viewMode == JournalViewMode.fullPage
        ? insertIndex * 2
        : insertIndex * 2;
    final wasBeforeCurrent = renderIndex <= _currentPageIndex;
    if (wasBeforeCurrent) {
      _currentPageIndex += 2; // Add 2 because we're in render pages space
    }
    notifyListeners();

    if (animate && !_isAnimating) {
      // Animate to the newly added page
      await animateTo(insertIndex);
    }
  }

  /// Inserts a page at the specified index.
  ///
  /// If [animate] is true (default), automatically animates to the newly inserted page.
  Future<void> insertPage(int index, Widget page, {bool animate = true}) async {
    if (index < 0 || index > _pages.length) {
      debugPrint('Invalid index for insertPage: $index');
      return;
    }
    _pages.insert(index, page);
    _renderPagesCache = null; // Invalidate cache
    // Adjust current page index if needed (in render pages space)
    final renderIndex =
        _viewMode == JournalViewMode.fullPage ? index * 2 : index * 2;
    final wasBeforeCurrent = renderIndex <= _currentPageIndex;
    if (wasBeforeCurrent) {
      _currentPageIndex += 2; // Add 2 because we're in render pages space
    }
    notifyListeners();

    if (animate && !_isAnimating) {
      // Animate to the newly inserted page
      await animateTo(index);
    }
  }

  /// Removes a page at the specified index.
  ///
  /// If [animate] is true (default), first animates away from the page to be removed,
  /// then removes it. This ensures coherent visual states.
  Future<void> removePage(int index, {bool animate = true}) async {
    if (index < 0 || index >= _pages.length) {
      debugPrint('Invalid index for removePage: $index');
      return;
    }

    if (_pages.isEmpty) {
      return;
    }

    // Get current page index in original pages space
    final currentOriginalIndex = _viewMode == JournalViewMode.fullPage
        ? _currentPageIndex ~/ 2
        : _currentPageIndex ~/ 2;

    // Check if we're removing the current page
    final renderIndex =
        _viewMode == JournalViewMode.fullPage ? index * 2 : index * 2;
    final wasCurrentPage = renderIndex == _currentPageIndex;
    final wasBeforeCurrent = renderIndex < _currentPageIndex;

    // Track which page we animate to (if any)
    int? animatedToIndex;

    // If removing the current page, animate away first
    if (animate && !_isAnimating && wasCurrentPage) {
      // Try to animate forward first, otherwise backward
      if (currentOriginalIndex + 1 < _pages.length) {
        animatedToIndex = currentOriginalIndex + 1;
        await animateTo(animatedToIndex);
      } else if (currentOriginalIndex > 0) {
        animatedToIndex = currentOriginalIndex - 1;
        await animateTo(animatedToIndex);
      }
      // If neither is possible, it's the only page, so we'll just remove it
    }

    // Now remove the page
    _pages.removeAt(index);
    _renderPagesCache = null; // Invalidate cache

    // Adjust current page index after removal
    // Recalculate render pages length after removal
    final renderPagesLength = renderPages.length;

    // If we animated to a page, we need to account for the index shift
    if (animatedToIndex != null) {
      // The page we animated to will have shifted down by 1 if it was after the removed page
      if (animatedToIndex > index) {
        // The page we're on shifted down by 1
        final newIndex = animatedToIndex - 1;
        final newRenderIndex =
            _viewMode == JournalViewMode.fullPage ? newIndex * 2 : newIndex * 2;
        _currentPageIndex =
            _validateInitialIndex(newRenderIndex, renderPagesLength);
      } else {
        // The page we're on didn't shift (it was before the removed page)
        // Current index is already correct from the animation, just validate it
        if (_currentPageIndex >= renderPagesLength) {
          _currentPageIndex =
              _validateInitialIndex(renderPagesLength - 1, renderPagesLength);
        }
      }
    } else {
      // No animation happened, adjust based on position relative to removed page
      if (wasBeforeCurrent) {
        _currentPageIndex -=
            2; // Subtract 2 because we're in render pages space
      } else if (wasCurrentPage || _currentPageIndex >= renderPagesLength) {
        // If we removed the current page without animating, go to the last valid page
        _currentPageIndex =
            _validateInitialIndex(renderPagesLength - 1, renderPagesLength);
      }
      // Ensure current page index is valid
      if (_currentPageIndex >= renderPagesLength) {
        _currentPageIndex =
            _validateInitialIndex(renderPagesLength - 1, renderPagesLength);
      }
    }
    notifyListeners();
  }

  /// Removes the current page.
  ///
  /// If [animate] is true (default), first animates away from the current page,
  /// then removes it. This ensures coherent visual states.
  Future<void> removeCurrentPage({bool animate = true}) async {
    if (_pages.isEmpty) {
      debugPrint('Cannot remove current page: journal is empty');
      return;
    }

    // Get the current page index in original pages space
    final currentOriginalIndex = _viewMode == JournalViewMode.fullPage
        ? _currentPageIndex ~/ 2
        : _currentPageIndex ~/ 2;

    if (currentOriginalIndex < 0 || currentOriginalIndex >= _pages.length) {
      debugPrint('Current page index is out of bounds');
      return;
    }

    // Delegate to removePage with the current page index
    await removePage(currentOriginalIndex, animate: animate);
  }

  /// Replaces a page at the specified index.
  void replacePage(int index, Widget page) {
    if (index < 0 || index >= _pages.length) {
      debugPrint('Invalid index for replacePage: $index');
      return;
    }
    _pages[index] = page;
    _renderPagesCache = null; // Invalidate cache
    notifyListeners();
  }

  /// Replaces all pages with a new list.
  void setPages(List<Widget> pages) {
    _pages = List.from(pages);
    _renderPagesCache = null; // Invalidate cache
    // Ensure current page index is valid
    final renderPagesLength = renderPages.length;
    _currentPageIndex =
        _validateInitialIndex(_currentPageIndex, renderPagesLength);
    notifyListeners();
  }

  /// Gets the current page widget (left page of the spread).
  Widget? get currentPage {
    if (_currentPageIndex >= 0 && _currentPageIndex < _pages.length) {
      return _pages[_currentPageIndex];
    }
    return null;
  }

  /// Gets the next page widget (right page of the spread).
  Widget? get nextPageWidget {
    final nextIndex = _currentPageIndex + 1;
    if (nextIndex >= 0 && nextIndex < _pages.length) {
      return _pages[nextIndex];
    }
    return null;
  }

  @override
  void dispose() {
    _animationController = null;
    _renderPagesCache = null;
    super.dispose();
  }
}

// Internal helper class for spread halves
enum _SpreadSide { left, right }

class _SpreadHalf extends StatelessWidget {
  final Widget child;
  final _SpreadSide side;
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
        final Alignment alignment = side == _SpreadSide.left
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
