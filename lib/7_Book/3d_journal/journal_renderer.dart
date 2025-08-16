import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:ui_showcases/7_Book/3d_journal/models/journal_shadows_configuration.dart';
import 'package:ui_showcases/7_Book/3d_journal/swipeable_journal.dart';

class _Book3DParentData extends ContainerBoxParentData<RenderBox> {}

class JournalRenderer extends MultiChildRenderObjectWidget {
  final double perspective;
  final double idleTiltRadians;
  final int currentPageIndex;
  final double swipeProgress;
  final SwipeDirection? swipeDirection;
  final double stackedItemsTranslateFactor;
  final JournalShadowsConfiguration shadowsConfiguration;

  const JournalRenderer({
    required this.perspective,
    required this.idleTiltRadians,
    required this.currentPageIndex,
    required this.swipeProgress,
    required this.swipeDirection,
    this.stackedItemsTranslateFactor = 0.0,
    required this.shadowsConfiguration,
    required super.children,
    super.key,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderBook3D(
      perspective: perspective,
      idleTiltRadians: idleTiltRadians,
      currentPageIndex: currentPageIndex,
      swipeProgress: swipeProgress,
      swipeDirection: swipeDirection,
      stackedItemsTranslateFactor: stackedItemsTranslateFactor,
      shadowsConfiguration: shadowsConfiguration,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderBook3D renderObject,
  ) {
    renderObject.perspective = perspective;
    renderObject.idleTiltRadians = idleTiltRadians;
    renderObject.currentPageIndex = currentPageIndex;
    renderObject.swipeProgress = swipeProgress;
    renderObject.swipeDirection = swipeDirection;
    renderObject.stackedItemsTranslateFactor = stackedItemsTranslateFactor;
    renderObject.shadowsConfiguration = shadowsConfiguration;
  }
}

class RenderBook3D extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _Book3DParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _Book3DParentData> {
  RenderBook3D({
    required double perspective,
    required double idleTiltRadians,
    required int currentPageIndex,
    required double swipeProgress,
    required SwipeDirection? swipeDirection,
    required double stackedItemsTranslateFactor,
    required JournalShadowsConfiguration shadowsConfiguration,
  })  : _perspective = perspective,
        _idleTiltRadians = idleTiltRadians,
        _currentPageIndex = currentPageIndex,
        _swipeProgress = swipeProgress,
        _swipeDirection = swipeDirection,
        _stackedItemsTranslateFactor = stackedItemsTranslateFactor,
        _shadowsConfiguration = shadowsConfiguration;

  double _perspective;
  double get perspective => _perspective;
  set perspective(double value) {
    if (_perspective == value) return;
    _perspective = value;
    markNeedsPaint();
  }

  double _idleTiltRadians;
  double get idleTiltRadians => _idleTiltRadians;
  set idleTiltRadians(double value) {
    if (_idleTiltRadians == value) return;
    _idleTiltRadians = value;
    markNeedsPaint();
  }

  int _currentPageIndex;
  int get currentPageIndex => _currentPageIndex;
  set currentPageIndex(int value) {
    if (_currentPageIndex == value) return;
    _currentPageIndex = value;
    markNeedsLayout();
  }

  double _swipeProgress;
  double get swipeProgress => _swipeProgress;
  set swipeProgress(double value) {
    if (_swipeProgress == value) return;
    _swipeProgress = value;
    markNeedsPaint();
  }

  SwipeDirection? _swipeDirection;
  SwipeDirection? get swipeDirection => _swipeDirection;
  set swipeDirection(SwipeDirection? value) {
    if (_swipeDirection == value) return;
    _swipeDirection = value;
    markNeedsPaint();
  }

  double _stackedItemsTranslateFactor;
  double get stackedItemsTranslateFactor => _stackedItemsTranslateFactor;
  set stackedItemsTranslateFactor(double value) {
    if (_stackedItemsTranslateFactor == value) return;
    _stackedItemsTranslateFactor = value;
    markNeedsPaint();
  }

  JournalShadowsConfiguration _shadowsConfiguration;
  JournalShadowsConfiguration get shadowsConfiguration => _shadowsConfiguration;
  set shadowsConfiguration(JournalShadowsConfiguration value) {
    if (_shadowsConfiguration == value) return;
    _shadowsConfiguration = value;
    markNeedsPaint();
  }

  double _convertRadiusToSigma(double radius) {
    if (radius <= 0) return 0;
    return radius * 0.57735 + 0.5;
  }

  double _shadowClipOutset() {
    final JournalShadowsConfiguration cfg = _shadowsConfiguration;
    // Inflate by spread + a factor of blur + some allowance for offset
    final double sigma = _convertRadiusToSigma(cfg.blurRadius);
    return cfg.spreadRadius + (sigma * 3.0) + cfg.offset.distance;
  }

  Path _shadowClipPathFor(
    Rect contentClip, {
    required bool isLeftSide,
    required Offset baseOffset,
    required Offset childTopLeft,
    required Size childSize,
  }) {
    final Rect inflated = contentClip.inflate(_shadowClipOutset());
    final double centerX = baseOffset.dx + size.width / 2.0;
    // Widen the exclusion band near the spine to ensure rotating shadows
    // never bleed across to the opposite static page in the middle area.
    final double sigma = _convertRadiusToSigma(
      _shadowsConfiguration.blurRadius,
    );
    final double exclusion = math.max(
      2.0,
      (_shadowsConfiguration.spreadRadius) +
          (sigma * 4.0) +
          _shadowsConfiguration.offset.dx.abs() +
          1.0,
    );
    final double pageTop = childTopLeft.dy;
    final double pageBottom = childTopLeft.dy + childSize.height;
    final Path path = Path();
    // Top band: allow shadow across the spine above the page top
    if (pageTop > inflated.top) {
      path.addRect(
        Rect.fromLTRB(inflated.left, inflated.top, inflated.right, pageTop),
      );
    }
    // Middle band: restrict near spine on the relevant side only (between page top and bottom)
    final double middleTop = math.max(inflated.top, pageTop);
    final double middleBottom = math.min(inflated.bottom, pageBottom);
    if (middleBottom > middleTop) {
      if (isLeftSide) {
        final double right = math.min(inflated.right, centerX - exclusion);
        if (right > inflated.left) {
          path.addRect(
            Rect.fromLTRB(inflated.left, middleTop, right, middleBottom),
          );
        }
      } else {
        final double left = math.max(inflated.left, centerX + exclusion);
        if (left < inflated.right) {
          path.addRect(
            Rect.fromLTRB(left, middleTop, inflated.right, middleBottom),
          );
        }
      }
    }
    // Bottom band: allow shadow across the spine below the page bottom
    if (inflated.bottom > pageBottom) {
      path.addRect(
        Rect.fromLTRB(
          inflated.left,
          pageBottom,
          inflated.right,
          inflated.bottom,
        ),
      );
    }
    return path;
  }

  void _paintShadowForChild(
    PaintingContext ctx,
    Offset childTopLeft,
    Size childSize,
  ) {
    final JournalShadowsConfiguration cfg = _shadowsConfiguration;
    if (!cfg.enabled) return;

    final double spread = cfg.spreadRadius;
    final Rect rect = Rect.fromLTWH(
      childTopLeft.dx + cfg.offset.dx - spread,
      childTopLeft.dy + cfg.offset.dy - spread,
      childSize.width + 2 * spread,
      childSize.height + 2 * spread,
    );

    final Paint paint = Paint()
      ..color = cfg.color
      ..maskFilter = ui.MaskFilter.blur(
        ui.BlurStyle.normal,
        _convertRadiusToSigma(cfg.blurRadius),
      );

    // Slight rounding to avoid overly harsh box look
    ctx.canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(1)),
      paint,
    );
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _Book3DParentData) {
      child.parentData = _Book3DParentData();
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return hitTestSelf(position);
  }

  RenderBox? _childAt(int index) {
    if (index < 0) return null;
    int i = 0;
    RenderBox? child = firstChild;
    while (child != null) {
      if (i == index) return child;
      final _Book3DParentData pd = child.parentData! as _Book3DParentData;
      child = pd.nextSibling;
      i++;
    }
    return null;
  }

  bool _isLeftStackIndex(int index) {
    // Left stack: even indices less than currentIndex
    return index.isEven && index < _currentPageIndex;
  }

  bool _isRightStackIndex(int index, int childCount) {
    // Right stack: odd indices greater than currentIndex + 1
    return index.isOdd && index > _currentPageIndex + 1 && index < childCount;
  }

  int get _childCount {
    int c = 0;
    RenderBox? child = firstChild;
    while (child != null) {
      c++;
      final _Book3DParentData pd = child.parentData! as _Book3DParentData;
      child = pd.nextSibling;
    }
    return c;
  }

  @override
  void performLayout() {
    final int count = _childCount;
    if (constraints.hasBoundedWidth && constraints.hasBoundedHeight) {
      size = constraints.biggest;
      final double pageWidth = size.width / 2.0;
      final BoxConstraints pageConstraints = BoxConstraints.tightFor(
        width: pageWidth,
        height: size.height,
      );

      int index = 0;
      RenderBox? child = firstChild;
      while (child != null) {
        final _Book3DParentData pd = child.parentData! as _Book3DParentData;
        child.layout(pageConstraints, parentUsesSize: true);

        if (index == _currentPageIndex) {
          pd.offset = Offset.zero;
        } else if (index == _currentPageIndex + 1) {
          pd.offset = Offset(pageWidth, 0);
        } else if (_isLeftStackIndex(index)) {
          pd.offset = Offset.zero;
        } else if (_isRightStackIndex(index, count)) {
          pd.offset = Offset(pageWidth, 0);
        } else {
          pd.offset = Offset(size.width * 2, 0);
        }

        child = pd.nextSibling;
        index++;
      }
      return;
    }

    final RenderBox? childLeft = _childAt(currentPageIndex);
    final RenderBox? childRight = _childAt(currentPageIndex + 1);
    if (childLeft == null || childRight == null) {
      size = constraints.constrain(Size.zero);
      return;
    }

    final BoxConstraints loose = BoxConstraints(
      maxWidth: constraints.maxWidth.isFinite
          ? constraints.maxWidth
          : double.infinity,
      maxHeight: constraints.maxHeight.isFinite
          ? constraints.maxHeight
          : double.infinity,
    );

    childLeft.layout(loose, parentUsesSize: true);
    childRight.layout(loose, parentUsesSize: true);

    final double composedWidth = childLeft.size.width + childRight.size.width;
    final double composedHeight = math.max(
      childLeft.size.height,
      childRight.size.height,
    );
    size = constraints.constrain(Size(composedWidth, composedHeight));

    final _Book3DParentData leftPd = childLeft.parentData! as _Book3DParentData;
    final _Book3DParentData rightPd =
        childRight.parentData! as _Book3DParentData;
    leftPd.offset = Offset.zero;
    rightPd.offset = Offset(childLeft.size.width, 0);

    final double pageWidth = size.width / 2.0;
    int index = 0;
    RenderBox? child = firstChild;
    while (child != null) {
      final _Book3DParentData pd = child.parentData! as _Book3DParentData;
      if (child != childLeft && child != childRight) {
        child.layout(loose, parentUsesSize: true);
        if (_isLeftStackIndex(index)) {
          pd.offset = Offset.zero;
        } else if (_isRightStackIndex(index, count)) {
          pd.offset = Offset(pageWidth, 0);
        } else {
          pd.offset = Offset(size.width * 2, 0);
        }
      }
      child = pd.nextSibling;
      index++;
    }
  }

  // Slightly overlap clips across the spine to avoid visible gap when idle tilt is applied
  Rect _leftPageRectWithSpineOverlap(Offset base, double overlapPx) =>
      Rect.fromLTWH(
        base.dx,
        base.dy,
        size.width / 2.0 + overlapPx,
        size.height,
      );

  Rect _rightPageRectWithSpineOverlap(Offset base, double overlapPx) =>
      Rect.fromLTWH(
        base.dx + size.width / 2.0 - overlapPx,
        base.dy,
        size.width / 2.0 + overlapPx,
        size.height,
      );

  Rect _leftPageRectWithVerticalMargin(Offset base, double margin) =>
      Rect.fromLTWH(
        base.dx,
        base.dy - margin,
        size.width / 2.0,
        size.height + margin * 2.0,
      );

  Rect _rightPageRectWithVerticalMargin(Offset base, double margin) =>
      Rect.fromLTWH(
        base.dx + size.width / 2.0,
        base.dy - margin,
        size.width / 2.0,
        size.height + margin * 2.0,
      );

  Matrix4 _basePerspective() {
    final Matrix4 m = Matrix4.identity();
    m.setEntry(3, 2, -_perspective);
    return m;
  }

  Matrix4 _idleTiltMatrix({required bool isLeft, required Offset baseOffset}) {
    final double pageWidth = size.width / 2.0;
    final double pageHeight = size.height;
    final double pivotX =
        baseOffset.dx + pageWidth; // tilt around spine in world space
    final double pivotY = baseOffset.dy + pageHeight / 2.0;
    final double signedAngle = isLeft ? _idleTiltRadians : -_idleTiltRadians;
    return _basePerspective()
      ..translate(pivotX, pivotY)
      ..rotateY(signedAngle)
      ..translate(-pivotX, -pivotY);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final int count = _childCount;

    final RenderBox? childLeft = _childAt(currentPageIndex);
    final RenderBox? childRight = _childAt(currentPageIndex + 1);
    if (childLeft == null || childRight == null) {
      return;
    }

    final _Book3DParentData leftPd = childLeft.parentData! as _Book3DParentData;
    final _Book3DParentData rightPd =
        childRight.parentData! as _Book3DParentData;

    final Offset leftOrigin = leftPd.offset + offset;
    final Offset rightOrigin = rightPd.offset + offset;

    final double pageWidth = size.width / 2.0;
    final double pageHeight = size.height;
    final double minClamp = idleTiltRadians / math.pi;
    final double clampedProgress = _swipeProgress.abs().clamp(
          minClamp,
          1.0 - minClamp,
        );
    // Normalize progress so that 0.0 maps to truly idle (no translation),
    // and 1.0 maps to end-of-flip, removing the bias introduced by idle tilt.
    final double normalizedProgress =
        ((clampedProgress - minClamp) / (1.0 - 2.0 * minClamp)).clamp(0.0, 1.0);
    final double angle = clampedProgress * math.pi;

    const double halfRotation = math.pi / 2.0;
    // FIXME: This is a hack to correct the visual crossing asymmetry.
    // This is changing according to book size
    final double halfThreshold = _swipeDirection == SwipeDirection.leftToRight
        ? halfRotation - 6.0 * math.pi / 180.0
        : halfRotation + 6.0 * math.pi / 180.0;

    final List<int> leftStack = <int>[];
    final List<int> rightStack = <int>[];

    for (int i = 0; i < count; i++) {
      if (i == _currentPageIndex || i == _currentPageIndex + 1) {
        continue;
      }
      if (_isLeftStackIndex(i)) {
        leftStack.add(i);
      } else if (_isRightStackIndex(i, count)) {
        rightStack.add(i);
      }
    }

    void paintLeftStack() {
      if (leftStack.isEmpty) return;
      final double overlap = 1.0 + (_idleTiltRadians * 10.0);
      // order stack indexes so that lower indexes are painted first
      leftStack.sort((a, b) => a.compareTo(b));
      int iteration = leftStack.length;
      for (final i in leftStack) {
        final RenderBox? c = _childAt(i);
        if (c == null) continue;
        final _Book3DParentData pd = c.parentData! as _Book3DParentData;
        final Matrix4 subtle = _idleTiltMatrix(
          isLeft: true,
          baseOffset: offset,
        );

        // When not swiping, avoid any animated offset on stacks
        final double f = swipeDirection == null
            ? 0.0
            : (swipeDirection == SwipeDirection.leftToRight ? 1.0 : -1.0);
        const double stackProgressScale = 2.05; // ensure no gap near the spine

        final double dx = -(iteration * _stackedItemsTranslateFactor) +
            (_stackedItemsTranslateFactor *
                (math.min(1.0, normalizedProgress * stackProgressScale) * f));

        final Rect clipRect = _leftPageRectWithSpineOverlap(
          offset,
          overlap,
        ).translate(dx, 0);

        context.pushTransform(true, Offset.zero, subtle, (ctx, _) {
          // Larger clip for shadow so blur/spread isn't cut off
          final Path shadowClip = _shadowClipPathFor(
            clipRect,
            isLeftSide: true,
            baseOffset: offset,
            childTopLeft: pd.offset + offset + Offset(dx, 0),
            childSize: c.size,
          );
          ctx.canvas.save();
          ctx.canvas.clipPath(shadowClip);
          _paintShadowForChild(
            ctx,
            pd.offset + offset + Offset(dx, 0),
            c.size,
          );
          ctx.canvas.restore();
          // Tight clip for the actual page content
          ctx.pushClipRect(true, Offset.zero, clipRect, (ctx2, _) {
            c.paint(ctx2, pd.offset + offset + Offset(dx, 0));
          });
        });
        iteration--;
      }
    }

    void paintRightStack() {
      if (rightStack.isEmpty) return;
      final double overlap = 1.0 + (_idleTiltRadians * 10.0);
      final double f = swipeDirection == null
          ? 0.0
          : (swipeDirection == SwipeDirection.leftToRight ? 1.0 : -1.0);
      const double stackProgressScale = 2.05; // ensure no gap near the spine
      // order stack indexes so that higher indexes are painted first
      rightStack.sort((a, b) => b.compareTo(a));
      int iteration = rightStack.length;
      for (final i in rightStack) {
        final RenderBox? c = _childAt(i);
        if (c == null) continue;
        final _Book3DParentData pd = c.parentData! as _Book3DParentData;
        final Matrix4 subtle = _idleTiltMatrix(
          isLeft: false,
          baseOffset: offset,
        );

        final double dx = (_stackedItemsTranslateFactor * iteration) +
            (_stackedItemsTranslateFactor *
                // Keep slight overdrive to avoid gap near center during flip
                (math.min(1.0, normalizedProgress * stackProgressScale) * f));

        final Rect clipRect = _rightPageRectWithSpineOverlap(
          offset,
          overlap,
        ).translate(dx, 0);

        context.pushTransform(true, Offset.zero, subtle, (ctx, _) {
          final Path shadowClip = _shadowClipPathFor(
            clipRect,
            isLeftSide: false,
            baseOffset: offset,
            childTopLeft: pd.offset + offset + Offset(dx, 0),
            childSize: c.size,
          );
          ctx.canvas.save();
          ctx.canvas.clipPath(shadowClip);
          _paintShadowForChild(
            ctx,
            pd.offset + offset + Offset(dx, 0),
            c.size,
          );
          ctx.canvas.restore();
          ctx.pushClipRect(true, Offset.zero, clipRect, (ctx2, _) {
            c.paint(ctx2, pd.offset + offset + Offset(dx, 0));
          });
        });
        iteration--;
      }
    }

    void paintStaticLeft() {
      final double overlap = 1.0 + (_idleTiltRadians * 10.0);
      final double dx = -(_stackedItemsTranslateFactor *
          math.max(0.0, normalizedProgress - 0.5) *
          2.0);
      final Rect clipRect = _leftPageRectWithSpineOverlap(
        offset,
        overlap,
      ).translate(dx, 0);
      final Matrix4 tilt = _idleTiltMatrix(isLeft: true, baseOffset: offset);
      context.pushTransform(true, Offset.zero, tilt, (ctx, _) {
        final Path shadowClip = _shadowClipPathFor(
          clipRect,
          isLeftSide: true,
          baseOffset: offset,
          childTopLeft: leftOrigin + Offset(dx, 0),
          childSize: childLeft.size,
        );
        ctx.canvas.save();
        ctx.canvas.clipPath(shadowClip);
        _paintShadowForChild(
          ctx,
          leftOrigin + Offset(dx, 0),
          childLeft.size,
        );
        ctx.canvas.restore();
        ctx.pushClipRect(true, Offset.zero, clipRect, (ctx2, _) {
          childLeft.paint(ctx2, leftOrigin + Offset(dx, 0));
        });
      });
    }

    void paintStaticRight() {
      final double overlap = 1.0 + (_idleTiltRadians * 10.0);
      final double dx = _stackedItemsTranslateFactor *
          math.max(0.0, normalizedProgress - 0.5) *
          2.0;
      final Rect clipRect = _rightPageRectWithSpineOverlap(
        offset,
        overlap,
      ).translate(dx, 0);
      final Matrix4 tilt = _idleTiltMatrix(isLeft: false, baseOffset: offset);
      context.pushTransform(true, Offset.zero, tilt, (ctx, _) {
        final Path shadowClip = _shadowClipPathFor(
          clipRect,
          isLeftSide: false,
          baseOffset: offset,
          childTopLeft: rightOrigin + Offset(dx, 0),
          childSize: childRight.size,
        );
        ctx.canvas.save();
        ctx.canvas.clipPath(shadowClip);
        _paintShadowForChild(
          ctx,
          rightOrigin + Offset(dx, 0),
          childRight.size,
        );
        ctx.canvas.restore();
        ctx.pushClipRect(true, Offset.zero, clipRect, (ctx2, _) {
          childRight.paint(ctx2, rightOrigin + Offset(dx, 0));
        });
      });
    }

    final double pivotX = offset.dx + pageWidth;
    final double pivotY = offset.dy + pageHeight / 2.0;

    void paintRotatedLeft({
      bool paintShadows = true,
      bool paintContent = true,
    }) {
      // Before half rotation, the left page remains on the left side.
      // After half rotation, it crosses the spine and should be clipped to the right side.
      // We also expand the vertical clip to account for perspective scaling that can
      // expand the apparent bounds vertically during rotation.
      final double extra = pageHeight; // generous vertical margin
      final Rect clipRect = angle <= halfThreshold
          ? _leftPageRectWithVerticalMargin(offset, extra)
          : _rightPageRectWithVerticalMargin(offset, extra);
      final Matrix4 m = _basePerspective()
        ..translate(pivotX, pivotY)
        ..rotateY(angle)
        ..translate(-pivotX, -pivotY);

      final bool frontIsLeft = angle <= halfThreshold;
      final Path frontShadowClip = _shadowClipPathFor(
        clipRect,
        isLeftSide: frontIsLeft,
        baseOffset: offset,
        childTopLeft: leftOrigin,
        childSize: childLeft.size,
      );
      final Path backShadowClip = _shadowClipPathFor(
        clipRect,
        isLeftSide: !frontIsLeft,
        baseOffset: offset,
        childTopLeft: leftOrigin,
        childSize: childLeft.size,
      );

      // Back-face shadow clipped to the opposite side
      final RenderBox backChild = _childAt(_currentPageIndex - 1) ?? childLeft;
      final double cx = leftOrigin.dx + pageWidth / 2.0;
      final double cy = leftOrigin.dy + pageHeight / 2.0;
      final Matrix4 m2 = Matrix4.identity()
        ..translate(cx, cy)
        ..rotateY(math.pi)
        ..translate(-cx, -cy);

      if (paintShadows) {
        context.pushClipRect(
          true,
          Offset.zero,
          clipRect.inflate(_shadowClipOutset()),
          (ctxShadowClip, _) {
            if (angle <= halfThreshold) {
              // Front-face shadow clipped to the current front side
              ctxShadowClip.canvas.save();
              ctxShadowClip.canvas.clipPath(frontShadowClip);
              ctxShadowClip.pushTransform(true, Offset.zero, m, (ctxFront, _) {
                _paintShadowForChild(ctxFront, leftOrigin, childLeft.size);
              });
              ctxShadowClip.canvas.restore();
            } else {
              ctxShadowClip.canvas.save();
              ctxShadowClip.canvas.clipPath(backShadowClip);
              ctxShadowClip.pushTransform(true, Offset.zero, m, (
                ctxBackWorld,
                _,
              ) {
                ctxBackWorld.pushTransform(true, Offset.zero, m2, (ctxBack, _) {
                  _paintShadowForChild(ctxBack, leftOrigin, backChild.size);
                });
              });
              ctxShadowClip.canvas.restore();
            }
          },
        );
      }
      if (paintContent) {
        context.pushClipRect(true, Offset.zero, clipRect, (ctxClip, _) {
          ctxClip.pushTransform(true, Offset.zero, m, (ctx, _) {
            if (angle <= halfThreshold) {
              childLeft.paint(ctx, leftOrigin);
            } else {
              ctx.pushTransform(true, Offset.zero, m2, (ctx2, _) {
                backChild.paint(ctx2, leftOrigin);
              });
            }
          });
        });
      }
    }

    void paintRotatedRight({
      bool paintShadows = true,
      bool paintContent = true,
    }) {
      // Symmetric to left: before half rotation, the right page is on the right.
      // After half rotation, it should be clipped to the left side. Expand vertically to avoid cropping.
      final double extra = pageHeight; // generous vertical margin
      final Rect clipRect = angle <= halfThreshold
          ? _rightPageRectWithVerticalMargin(offset, extra)
          : _leftPageRectWithVerticalMargin(offset, extra);
      final Matrix4 m = _basePerspective()
        ..translate(pivotX, pivotY)
        ..rotateY(-angle)
        ..translate(-pivotX, -pivotY);

      final bool frontIsRight = angle <= halfThreshold;
      final Path frontShadowClip = _shadowClipPathFor(
        clipRect,
        isLeftSide: !frontIsRight,
        baseOffset: offset,
        childTopLeft: rightOrigin,
        childSize: childRight.size,
      );
      final Path backShadowClip = _shadowClipPathFor(
        clipRect,
        isLeftSide: frontIsRight,
        baseOffset: offset,
        childTopLeft: rightOrigin,
        childSize: childRight.size,
      );

      // Back-face shadow clipped to the opposite side
      final RenderBox backChild = _childAt(_currentPageIndex + 2) ?? childRight;
      final double cx = rightOrigin.dx + pageWidth / 2.0;
      final double cy = rightOrigin.dy + pageHeight / 2.0;
      final Matrix4 m2 = Matrix4.identity()
        ..translate(cx, cy)
        ..rotateY(-math.pi)
        ..translate(-cx, -cy);

      if (paintShadows) {
        context.pushClipRect(
          true,
          Offset.zero,
          clipRect.inflate(_shadowClipOutset()),
          (ctxShadowClip, _) {
            if (angle <= halfThreshold) {
              // Front-face shadow clipped to the current front side
              ctxShadowClip.canvas.save();
              ctxShadowClip.canvas.clipPath(frontShadowClip);
              ctxShadowClip.pushTransform(true, Offset.zero, m, (ctxFront, _) {
                _paintShadowForChild(ctxFront, rightOrigin, childRight.size);
              });
              ctxShadowClip.canvas.restore();
            } else {
              ctxShadowClip.canvas.save();
              ctxShadowClip.canvas.clipPath(backShadowClip);
              ctxShadowClip.pushTransform(true, Offset.zero, m, (
                ctxBackWorld,
                _,
              ) {
                ctxBackWorld.pushTransform(true, Offset.zero, m2, (ctxBack, _) {
                  _paintShadowForChild(ctxBack, rightOrigin, backChild.size);
                });
              });
              ctxShadowClip.canvas.restore();
            }
          },
        );
      }
      if (paintContent) {
        context.pushClipRect(true, Offset.zero, clipRect, (ctxClip, _) {
          ctxClip.pushTransform(true, Offset.zero, m, (ctx, _) {
            if (angle <= halfThreshold) {
              childRight.paint(ctx, rightOrigin);
            } else {
              ctx.pushTransform(true, Offset.zero, m2, (ctx2, _) {
                backChild.paint(ctx2, rightOrigin);
              });
            }
          });
        });
      }
    }

    // This part is a bit messy / tricky, but this is some logic in order to display children and shadows in the right order.
    // We would not need that much calculations without shadows.
    // This allow us to have continous shadows transitions

    if (_swipeDirection == SwipeDirection.rightToLeft) {
      if (angle <= halfThreshold) {
        paintLeftStack();
        paintRightStack();
        paintRotatedRight(paintContent: false);
        paintStaticLeft();
        paintRotatedRight(paintShadows: false);
      } else {
        paintLeftStack();
        paintStaticLeft();
        paintRotatedRight(paintContent: false);
        paintRightStack();
        paintRotatedRight(paintShadows: false);
      }
    } else if (_swipeDirection == SwipeDirection.leftToRight) {
      if (angle <= halfThreshold) {
        paintLeftStack();
        paintRotatedLeft(paintContent: false);
        paintRightStack();
        paintStaticRight();
        paintRotatedLeft(paintShadows: false);
      } else {
        paintRightStack();
        paintStaticRight();
        paintRotatedLeft(paintContent: false);
        paintLeftStack();
        paintRotatedLeft(paintShadows: false);
      }
    } else {
      paintLeftStack();
      paintRightStack();
      paintStaticLeft();
      paintStaticRight();
    }
  }
}
