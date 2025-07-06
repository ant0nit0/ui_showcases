import 'package:flutter/material.dart';

class RPSCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Layer 1

    Paint paintFill0 = Paint()
      ..color = const Color.fromARGB(0, 0, 255, 255)
      ..style = PaintingStyle.fill
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.butt
      ..strokeJoin = StrokeJoin.miter;

    // Create a new path for the flower shape
    Path path0 = Path();
    path0.moveTo(0, 0); // Start at top-left corner

    // Top-left petal
    path0.quadraticBezierTo(
        size.width * 0.165, 0, size.width * 0.330, size.height * 0.165);
    path0.quadraticBezierTo(size.width * 0.500, size.height * 0.330,
        size.width * 0.500, size.height * 0.500); // Curve to center

    // Top-right petal
    path0.quadraticBezierTo(size.width * 0.500, size.height * 0.330,
        size.width * 0.663, size.height * 0.175);
    path0.quadraticBezierTo(
        size.width * 0.835, 0, size.width, 0); // To top-right corner
    path0.quadraticBezierTo(size.width, size.height * 0.165, size.width * 0.835,
        size.height * 0.330);
    path0.quadraticBezierTo(size.width * 0.667, size.height * 0.500,
        size.width * 0.500, size.height * 0.500); // Back to center

    // Bottom-right petal
    path0.quadraticBezierTo(size.width * 0.675, size.height * 0.500,
        size.width * 0.850, size.height * 0.675);
    path0.quadraticBezierTo(size.width, size.height * 0.835, size.width,
        size.height); // To bottom-right corner
    path0.quadraticBezierTo(size.width * 0.835, size.height, size.width * 0.667,
        size.height * 0.833);
    path0.quadraticBezierTo(size.width * 0.500, size.height * 0.667,
        size.width * 0.500, size.height * 0.500); // Back to center

    // Bottom-left petal
    path0.quadraticBezierTo(size.width * 0.500, size.height * 0.667,
        size.width * 0.334, size.height * 0.834);
    path0.quadraticBezierTo(size.width * 0.165, size.height, 0,
        size.height); // To bottom-left corner
    path0.quadraticBezierTo(
        0, size.height * 0.835, size.width * 0.165, size.height * 0.666);
    path0.quadraticBezierTo(size.width * 0.337, size.height * 0.500,
        size.width * 0.500, size.height * 0.500); // Back to center

    // Complete the shape by returning to starting point
    path0.quadraticBezierTo(size.width * 0.337, size.height * 0.500,
        size.width * 0.165, size.height * 0.337);
    path0.quadraticBezierTo(0, size.height * 0.165, 0, 0);
    path0.close(); // Close the path

    canvas.drawPath(path0, paintFill0);

    // Layer 1

    Paint paint_stroke_0 = Paint()
      ..color = const Color.fromARGB(255, 33, 150, 243)
      ..style = PaintingStyle.fill
      ..strokeWidth = size.width * 0.00
      ..strokeCap = StrokeCap.butt
      ..strokeJoin = StrokeJoin.miter;

    canvas.drawPath(path0, paint_stroke_0);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class CloverShapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = const Color(0xFF2196F3) // Blue color
      ..style = PaintingStyle.fill;

    final Path path = Path();
    final double w = size.width;
    final double h = size.height;
    final double r = (w < h ? w : h) * 0.25; // Radius is 1/4 of min dimension

    // Top Left
    path.moveTo(0, r);
    // Top left top left
    path.quadraticBezierTo(0, 0, r, 0); // only outer top-left corner is sharp
    path.lineTo(w * 0.5 - r, 0);
    // Top right of top left
    path.quadraticBezierTo(
        w * 0.5, 0, w * 0.5, r); // inner corner: fully rounded
    path.lineTo(w * 0.5, h * 0.5 - r);

    // Top Right
    path.quadraticBezierTo(w * 0.5, 0, w * 0.5 + r, 0);
    path.lineTo(w - r, 0);
    path.quadraticBezierTo(w, 0, w, r); // outer corner
    path.lineTo(w, h * 0.5 - r);
    path.quadraticBezierTo(w, h * 0.5, w - r, h * 0.5); // inner corner
    path.lineTo(w * 0.5 + r, h * 0.5);

    // Bottom Right
    path.quadraticBezierTo(w, h * 0.5, w, h * 0.5 + r);
    path.lineTo(w, h - r);
    path.quadraticBezierTo(w, h, w - r, h);
    path.lineTo(w * 0.5 + r, h);
    path.quadraticBezierTo(w * 0.5, h, w * 0.5, h - r); // inner corner
    path.lineTo(w * 0.5, h * 0.5 + r);

    // Bottom Left
    path.quadraticBezierTo(w * 0.5, h, w * 0.5 - r, h);
    path.lineTo(r, h);
    path.quadraticBezierTo(0, h, 0, h - r);
    path.lineTo(0, h * 0.5 + r);
    path.quadraticBezierTo(0, h * 0.5, r, h * 0.5); // inner corner
    // path.lineTo(w * 0.5 - r, h * 0.5);

    // path.lineTo(0, r);
    path.quadraticBezierTo(0, h * 0.5, r, h * 0.5);
    path.lineTo(w * 0.5 - r, h * 0.5);
    path.quadraticBezierTo(0, h * 0.5, 0, r);
    path.close();

    // path.quadraticBezierTo(w * 0.5, h * 0.5, 0, r); // close top-left again

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
