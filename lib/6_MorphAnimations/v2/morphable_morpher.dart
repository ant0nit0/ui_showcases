import 'package:flutter/material.dart';
import 'package:morphable_shape/morphable_shape.dart';

class Morpher extends StatefulWidget {
  const Morpher({super.key});

  @override
  State<Morpher> createState() => _MorpherState();
}

class _MorpherState extends State<Morpher> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _isFlower = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleShape() {
    if (_isFlower) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() {
      _isFlower = !_isFlower;
    });
  }

  // Helper function to convert quadratic Bezier to cubic Bezier
  // For quadratic Bezier: P0, P1 (control), P2
  // To cubic Bezier: P0, P1, P2, P3 where:
  // P1 = P0 + 2/3 * (P1_quad - P0)
  // P2 = P2 + 2/3 * (P1_quad - P2)
  DynamicNode _quadraticToCubic(
    Offset start,
    Offset control,
    Offset end,
    double w,
    double h,
  ) {
    final p1 = start + (control - start) * (2.0 / 3.0);
    final p2 = end + (control - end) * (2.0 / 3.0);

    return DynamicNode(
      position: end,
      prev: p1,
      next: p2,
    );
  }

  // Create flower shape using DynamicPath with DynamicNode objects
  DynamicPath _createFlowerShape(Size size) {
    final double w = size.width;
    final double h = size.height;

    List<DynamicNode> nodes = [
      // Start at top-left corner
      DynamicNode(position: Offset(0, 0)),

      // Top-left petal: quadraticBezierTo(0.165, 0, 0.330, 0.165)
      _quadraticToCubic(
        Offset(0, 0),
        Offset(w * 0.165, 0),
        Offset(w * 0.330, h * 0.165),
        w,
        h,
      ),

      // Curve to center: quadraticBezierTo(0.500, 0.330, 0.500, 0.500)
      _quadraticToCubic(
        Offset(w * 0.330, h * 0.165),
        Offset(w * 0.500, h * 0.330),
        Offset(w * 0.500, h * 0.500),
        w,
        h,
      ),

      // Top-right petal: quadraticBezierTo(0.500, 0.330, 0.663, 0.175)
      _quadraticToCubic(
        Offset(w * 0.500, h * 0.500),
        Offset(w * 0.500, h * 0.330),
        Offset(w * 0.663, h * 0.175),
        w,
        h,
      ),

      // To top-right corner: quadraticBezierTo(0.835, 0, 1.0, 0)
      _quadraticToCubic(
        Offset(w * 0.663, h * 0.175),
        Offset(w * 0.835, 0),
        Offset(w, 0),
        w,
        h,
      ),

      // Right side: quadraticBezierTo(1.0, 0.165, 0.835, 0.330)
      _quadraticToCubic(
        Offset(w, 0),
        Offset(w, h * 0.165),
        Offset(w * 0.835, h * 0.330),
        w,
        h,
      ),

      // Back to center: quadraticBezierTo(0.667, 0.500, 0.500, 0.500)
      _quadraticToCubic(
        Offset(w * 0.835, h * 0.330),
        Offset(w * 0.667, h * 0.500),
        Offset(w * 0.500, h * 0.500),
        w,
        h,
      ),

      // Bottom-right petal: quadraticBezierTo(0.675, 0.500, 0.850, 0.675)
      _quadraticToCubic(
        Offset(w * 0.500, h * 0.500),
        Offset(w * 0.675, h * 0.500),
        Offset(w * 0.850, h * 0.675),
        w,
        h,
      ),

      // To bottom-right corner: quadraticBezierTo(1.0, 0.835, 1.0, 1.0)
      _quadraticToCubic(
        Offset(w * 0.850, h * 0.675),
        Offset(w, h * 0.835),
        Offset(w, h),
        w,
        h,
      ),

      // Bottom side: quadraticBezierTo(0.835, 1.0, 0.667, 0.833)
      _quadraticToCubic(
        Offset(w, h),
        Offset(w * 0.835, h),
        Offset(w * 0.667, h * 0.833),
        w,
        h,
      ),

      // Back to center: quadraticBezierTo(0.500, 0.667, 0.500, 0.500)
      _quadraticToCubic(
        Offset(w * 0.667, h * 0.833),
        Offset(w * 0.500, h * 0.667),
        Offset(w * 0.500, h * 0.500),
        w,
        h,
      ),

      // Bottom-left petal: quadraticBezierTo(0.500, 0.667, 0.334, 0.834)
      _quadraticToCubic(
        Offset(w * 0.500, h * 0.500),
        Offset(w * 0.500, h * 0.667),
        Offset(w * 0.334, h * 0.834),
        w,
        h,
      ),

      // To bottom-left corner: quadraticBezierTo(0.165, 1.0, 0, 1.0)
      _quadraticToCubic(
        Offset(w * 0.334, h * 0.834),
        Offset(w * 0.165, h),
        Offset(0, h),
        w,
        h,
      ),

      // Left side: quadraticBezierTo(0, 0.835, 0.165, 0.666)
      _quadraticToCubic(
        Offset(0, h),
        Offset(0, h * 0.835),
        Offset(w * 0.165, h * 0.666),
        w,
        h,
      ),

      // Back to center: quadraticBezierTo(0.337, 0.500, 0.500, 0.500)
      _quadraticToCubic(
        Offset(w * 0.165, h * 0.666),
        Offset(w * 0.337, h * 0.500),
        Offset(w * 0.500, h * 0.500),
        w,
        h,
      ),

      // Back to top-left: quadraticBezierTo(0.337, 0.500, 0.165, 0.337)
      _quadraticToCubic(
        Offset(w * 0.500, h * 0.500),
        Offset(w * 0.337, h * 0.500),
        Offset(w * 0.165, h * 0.337),
        w,
        h,
      ),

      // Close the shape: quadraticBezierTo(0, 0.165, 0, 0)
      _quadraticToCubic(
        Offset(w * 0.165, h * 0.337),
        Offset(0, h * 0.165),
        Offset(0, 0),
        w,
        h,
      ),
    ];

    return DynamicPath(size: size, nodes: nodes);
  }

  // Create clover shape using DynamicPath with DynamicNode objects
  DynamicPath _createCloverShape(Size size) {
    final double w = size.width;
    final double h = size.height;
    final double r = (w < h ? w : h) * 0.25;

    List<DynamicNode> nodes = [
      // Top left leaf
      DynamicNode(position: Offset(0, r)),

      // Top left corner: quadraticBezierTo(0, 0, r, 0)
      _quadraticToCubic(
        Offset(0, r),
        Offset(0, 0),
        Offset(r, 0),
        w,
        h,
      ),

      // Top center
      DynamicNode(
        position: Offset(w * 0.5 - r, 0),
        prev: Offset(w * 0.375, 0), // First control point
        next: Offset(w * 0.5 - r, 0), // Second control point
      ),

      // Top right of top left: quadraticBezierTo(0.5, 0, 0.5, r)
      _quadraticToCubic(
        Offset(w * 0.5 - r, 0),
        Offset(w * 0.5, 0),
        Offset(w * 0.5, r),
        w,
        h,
      ),

      // Top center vertical
      DynamicNode(
        position: Offset(w * 0.5, h * 0.5 - r),
        prev: Offset(w * 0.5, h * 0.375), // First control point
        next: Offset(w * 0.5, h * 0.5 - r), // Second control point
      ),

      // Top right leaf: quadraticBezierTo(0.5, 0, 0.5 + r, 0)
      _quadraticToCubic(
        Offset(w * 0.5, h * 0.5 - r),
        Offset(w * 0.5, 0),
        Offset(w * 0.5 + r, 0),
        w,
        h,
      ),

      // Top right
      DynamicNode(
        position: Offset(w - r, 0),
        prev: Offset(w * 0.625, 0), // First control point
        next: Offset(w - r, 0), // Second control point
      ),

      // Top right corner: quadraticBezierTo(w, 0, w, r)
      _quadraticToCubic(
        Offset(w - r, 0),
        Offset(w, 0),
        Offset(w, r),
        w,
        h,
      ),

      // Right side
      DynamicNode(
        position: Offset(w, h * 0.5 - r),
        prev: Offset(w, h * 0.375), // First control point
        next: Offset(w, h * 0.5 - r), // Second control point
      ),

      // Inner right corner: quadraticBezierTo(w, 0.5, w - r, 0.5)
      _quadraticToCubic(
        Offset(w, h * 0.5 - r),
        Offset(w, h * 0.5),
        Offset(w - r, h * 0.5),
        w,
        h,
      ),

      // Bottom right leaf: quadraticBezierTo(w, 0.5, w, 0.5 + r)
      _quadraticToCubic(
        Offset(w - r, h * 0.5),
        Offset(w, h * 0.5),
        Offset(w, h * 0.5 + r),
        w,
        h,
      ),

      // Bottom right
      DynamicNode(
        position: Offset(w, h - r),
        prev: Offset(w, h * 0.625), // First control point
        next: Offset(w, h - r), // Second control point
      ),

      // Bottom right corner: quadraticBezierTo(w, h, w - r, h)
      _quadraticToCubic(
        Offset(w, h - r),
        Offset(w, h),
        Offset(w - r, h),
        w,
        h,
      ),

      // Bottom side
      DynamicNode(
        position: Offset(w * 0.5 + r, h),
        prev: Offset(w * 0.625, h), // First control point
        next: Offset(w * 0.5 + r, h), // Second control point
      ),

      // Inner bottom corner: quadraticBezierTo(0.5, h, 0.5, h - r)
      _quadraticToCubic(
        Offset(w * 0.5 + r, h),
        Offset(w * 0.5, h),
        Offset(w * 0.5, h - r),
        w,
        h,
      ),

      // Bottom left leaf: quadraticBezierTo(0.5, h, 0.5 - r, h)
      _quadraticToCubic(
        Offset(w * 0.5, h - r),
        Offset(w * 0.5, h),
        Offset(w * 0.5 - r, h),
        w,
        h,
      ),

      // Bottom left
      DynamicNode(
        position: Offset(r, h),
        prev: Offset(w * 0.375, h), // First control point
        next: Offset(r, h), // Second control point
      ),

      // Bottom left corner: quadraticBezierTo(0, h, 0, h - r)
      _quadraticToCubic(
        Offset(r, h),
        Offset(0, h),
        Offset(0, h - r),
        w,
        h,
      ),

      // Left side
      DynamicNode(
        position: Offset(0, h * 0.5 + r),
        prev: Offset(0, h * 0.625), // First control point
        next: Offset(0, h * 0.5 + r), // Second control point
      ),

      // Inner left corner: quadraticBezierTo(0, 0.5, r, 0.5)
      _quadraticToCubic(
        Offset(0, h * 0.5 + r),
        Offset(0, h * 0.5),
        Offset(r, h * 0.5),
        w,
        h,
      ),

      // Back to center
      DynamicNode(
        position: Offset(w * 0.5 - r, h * 0.5),
        prev: Offset(w * 0.375, h * 0.5), // First control point
        next: Offset(w * 0.5 - r, h * 0.5), // Second control point
      ),

      // Back to top
      DynamicNode(
        position: Offset(w * 0.5, h * 0.5 - r),
        prev: Offset(w * 0.5 - r, h * 0.5), // First control point
        next: Offset(w * 0.5, h * 0.5 - r), // Second control point
      ),
    ];

    return DynamicPath(size: size, nodes: nodes);
  }

  @override
  Widget build(BuildContext context) {
    final size = Size(200, 200);
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleShape,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  // Create morphing between the two shapes
                  final flowerShape = _createFlowerShape(size);
                  final cloverShape = _createCloverShape(size);

                  // Interpolate between the two shapes using DynamicPathMorph.lerpPaths
                  final interpolatedShape = DynamicPathMorph.lerpPaths(
                    _controller.value,
                    flowerShape,
                    cloverShape,
                  );

                  return Container(
                    width: 200,
                    height: 200,
                    decoration: ShapeDecoration(
                      shape: PathShapeBorder(path: interpolatedShape),
                      color: const Color(0xFF2196F3),
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
