import 'dart:math' as math;

import 'package:flutter/material.dart';

class Morpher extends StatefulWidget {
  const Morpher({super.key});

  @override
  State<Morpher> createState() => _MorpherState();
}

class _MorpherState extends State<Morpher> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  bool _isFlower = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Add custom curve to the animation
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic, // You can change this curve
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleShape() {
    if (_isFlower) {
      print('Going from shape 1 to shape 2');
      _controller.forward();
    } else {
      print('Going back from shape 2 to shape 1');
      _controller.reverse();
    }
    setState(() {
      _isFlower = !_isFlower;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleShape,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  final firstSize = 400.0;
                  final secondSize = 300.0;
                  final currentSize =
                      firstSize - (firstSize - secondSize) * _animation.value;

                  print(
                      'currentSize: $currentSize,    animation value: ${_animation.value}');

                  return SizedBox(
                    width: currentSize,
                    height: currentSize,
                    child: CustomPaint(
                      painter: MorphingPainter(
                          _animation.value, Size(currentSize, currentSize)),
                      size: Size(currentSize, currentSize),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _toggleShape,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: Text(_isFlower ? 'Morph to Clover' : 'Morph to Flower'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MorphingPainter extends CustomPainter {
  final double progress;
  final Size size;

  MorphingPainter(this.progress, this.size);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    // Define the two paths
    final path1 = _createFlowerPath(size);
    final path2 = _createCloverPath(size);

    // Create interpolated path with improved algorithm
    final interpolatedPath = _interpolatePaths(path1, path2, progress);

    canvas.drawPath(interpolatedPath, paint);
  }

  Path _createFlowerPath(Size size) {
    final path = Path();
    path.moveTo(0, 0);

    // Top-left petal
    path.quadraticBezierTo(
        size.width * 0.165, 0, size.width * 0.330, size.height * 0.165);
    path.quadraticBezierTo(size.width * 0.500, size.height * 0.330,
        size.width * 0.500, size.height * 0.500);

    // Top-right petal
    path.quadraticBezierTo(size.width * 0.500, size.height * 0.330,
        size.width * 0.663, size.height * 0.175);
    path.quadraticBezierTo(size.width * 0.835, 0, size.width, 0);
    path.quadraticBezierTo(size.width, size.height * 0.165, size.width * 0.835,
        size.height * 0.330);
    path.quadraticBezierTo(size.width * 0.667, size.height * 0.500,
        size.width * 0.500, size.height * 0.500);

    // Bottom-right petal
    path.quadraticBezierTo(size.width * 0.675, size.height * 0.500,
        size.width * 0.850, size.height * 0.675);
    path.quadraticBezierTo(
        size.width, size.height * 0.835, size.width, size.height);
    path.quadraticBezierTo(size.width * 0.835, size.height, size.width * 0.667,
        size.height * 0.833);
    path.quadraticBezierTo(size.width * 0.500, size.height * 0.667,
        size.width * 0.500, size.height * 0.500);

    // Bottom-left petal
    path.quadraticBezierTo(size.width * 0.500, size.height * 0.667,
        size.width * 0.334, size.height * 0.834);
    path.quadraticBezierTo(size.width * 0.165, size.height, 0, size.height);
    path.quadraticBezierTo(
        0, size.height * 0.835, size.width * 0.165, size.height * 0.666);
    path.quadraticBezierTo(size.width * 0.337, size.height * 0.500,
        size.width * 0.500, size.height * 0.500);

    // Complete the shape
    path.quadraticBezierTo(size.width * 0.337, size.height * 0.500,
        size.width * 0.165, size.height * 0.337);
    path.quadraticBezierTo(0, size.height * 0.165, 0, 0);
    path.close();

    return path;
  }

  Path _createCloverPath(Size size) {
    final double w = size.width;
    final double h = size.height;
    final double r = (w < h ? w : h) * 0.25;

    final path = Path();
    path.moveTo(0, r);

    // Top left leaf
    path.quadraticBezierTo(0, 0, r, 0);
    path.lineTo(w * 0.5 - r, 0);
    path.quadraticBezierTo(w * 0.5, 0, w * 0.5, r);
    path.lineTo(w * 0.5, h * 0.5 - r);

    // Top right leaf
    path.quadraticBezierTo(w * 0.5, 0, w * 0.5 + r, 0);
    path.lineTo(w - r, 0);
    path.quadraticBezierTo(w, 0, w, r);
    path.lineTo(w, h * 0.5 - r);
    path.quadraticBezierTo(w, h * 0.5, w - r, h * 0.5);
    path.lineTo(w * 0.5 + r, h * 0.5);

    // Bottom right leaf
    path.quadraticBezierTo(w, h * 0.5, w, h * 0.5 + r);
    path.lineTo(w, h - r);
    path.quadraticBezierTo(w, h, w - r, h);
    path.lineTo(w * 0.5 + r, h);
    path.quadraticBezierTo(w * 0.5, h, w * 0.5, h - r);
    path.lineTo(w * 0.5, h * 0.5 + r);

    // Bottom left leaf
    path.quadraticBezierTo(w * 0.5, h, w * 0.5 - r, h);
    path.lineTo(r, h);
    path.quadraticBezierTo(0, h, 0, h - r);
    path.lineTo(0, h * 0.5 + r);
    path.quadraticBezierTo(0, h * 0.5, r, h * 0.5);
    path.lineTo(w * 0.5 - r, h * 0.5);
    path.quadraticBezierTo(0, h * 0.5, 0, r);
    path.close();

    return path;
  }

  Path _interpolatePaths(Path path1, Path path2, double progress) {
    // Use adaptive sampling based on curve complexity
    final metrics1 = path1.computeMetrics().first;
    final metrics2 = path2.computeMetrics().first;

    // Calculate optimal number of points based on path complexity
    final length1 = metrics1.length;
    final length2 = metrics2.length;
    final maxLength = math.max(length1, length2);
    final numPoints =
        math.max(200, (maxLength / 2).round()); // Adaptive sampling

    final interpolatedPath = Path();
    final points = <Offset>[];

    // Sample points from both paths
    for (int i = 0; i <= numPoints; i++) {
      final t = i / numPoints.toDouble();

      // Get points from both paths at the same relative position
      final pos1 =
          metrics1.getTangentForOffset(length1 * t)?.position ?? Offset.zero;
      final pos2 =
          metrics2.getTangentForOffset(length2 * t)?.position ?? Offset.zero;

      // Use smooth interpolation with easing
      final easedProgress = _easeInOutCubic(progress);
      final interpolatedPoint = Offset.lerp(pos1, pos2, easedProgress)!;
      points.add(interpolatedPoint);
    }

    // Create smooth path using Catmull-Rom spline interpolation
    if (points.isNotEmpty) {
      interpolatedPath.moveTo(points.first.dx, points.first.dy);

      for (int i = 1; i < points.length; i++) {
        final current = points[i];
        final previous = points[i - 1];

        // Use quadratic Bezier for smoother curves
        if (i == 1) {
          // First segment: use lineTo for smooth start
          interpolatedPath.lineTo(current.dx, current.dy);
        } else if (i == points.length - 1) {
          // Last segment: use lineTo for smooth end
          interpolatedPath.lineTo(current.dx, current.dy);
        } else {
          // Calculate control point for smooth curve
          final controlPoint = _calculateControlPoint(
            points[i - 2],
            previous,
            current,
            points[i + 1],
          );

          interpolatedPath.quadraticBezierTo(
            controlPoint.dx,
            controlPoint.dy,
            current.dx,
            current.dy,
          );
        }
      }
    }

    interpolatedPath.close();
    return interpolatedPath;
  }

  // Calculate control point for smooth curve using Catmull-Rom spline
  Offset _calculateControlPoint(Offset p0, Offset p1, Offset p2, Offset p3) {
    // Catmull-Rom spline tension parameter (0.5 for smooth curves)
    const tension = 0.5;

    final dx = (p2.dx - p0.dx) * tension / 6.0;
    final dy = (p2.dy - p0.dy) * tension / 6.0;

    return Offset(p1.dx + dx, p1.dy + dy);
  }

  // Smooth easing function for more natural morphing
  double _easeInOutCubic(double t) {
    if (t < 0.5) {
      return 4 * t * t * t;
    } else {
      return 1 - math.pow(-2 * t + 2, 3) / 2;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
