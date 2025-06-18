import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class WaveAnimator extends StatefulWidget {
  final Widget child;
  final double waveSpeed;
  final double waveIntensity;
  final double waveFrequency;
  final double pixelRatio;

  const WaveAnimator({
    super.key,
    required this.child,
    this.waveSpeed = 2.0,
    this.waveIntensity = 0.005,
    this.waveFrequency = 1.0,
    this.pixelRatio = 3,
  });

  @override
  State<WaveAnimator> createState() => _WaveAnimatorState();
}

class _WaveAnimatorState extends State<WaveAnimator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  ui.FragmentProgram? _program;
  ui.Image? _cachedImage;
  final GlobalKey _repaintKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (widget.waveSpeed * 1000).toInt()),
      animationBehavior: AnimationBehavior.preserve,
    )..repeat();
    _loadShader();
  }

  Future<void> _loadShader() async {
    try {
      _program = await ui.FragmentProgram.fromAsset('shaders/flag_effect.frag');
      setState(() {});
    } catch (e) {
      if (kDebugMode) {
        print('Error loading shader: $e');
      }
    }
  }

  Future<void> _captureImage() async {
    final boundary = _repaintKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null) return;

    final image = await boundary.toImage(pixelRatio: widget.pixelRatio);
    setState(() => _cachedImage = image);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // We add a little delay to ensure each widget in the child widget as been renderer
      // (For example Svgs that are not rendered in the first frame)
      Future.delayed(const Duration(milliseconds: 100), () {
        _captureImage();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: _repaintKey,
      child: _program == null || _cachedImage == null
          ? widget.child
          : AnimatedBuilder(
              animation: _controller,
              builder: (context, child) => CustomPaint(
                size: Size.infinite,
                painter: _FlagPainter(
                  image: _cachedImage!,
                  program: _program!,
                  progress: _controller.value,
                  waveSpeed: widget.waveSpeed,
                  waveIntensity: widget.waveIntensity,
                  waveFrequency: widget.waveFrequency,
                ),
                child: Opacity(
                  opacity: 0,
                  child: widget.child,
                ),
              ),
            ),
    );
  }
}

class _FlagPainter extends CustomPainter {
  final ui.Image image;
  final ui.FragmentProgram program;
  final double progress;
  final double waveSpeed;
  final double waveIntensity;
  final double waveFrequency;

  _FlagPainter({
    required this.image,
    required this.program,
    required this.progress,
    required this.waveSpeed,
    required this.waveIntensity,
    required this.waveFrequency,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final shader = program.fragmentShader()
      ..setFloat(0, progress)
      ..setFloat(1, size.width)
      ..setFloat(2, size.height)
      ..setFloat(3, waveSpeed)
      ..setFloat(4, waveIntensity)
      ..setImageSampler(0, image)
      ..setFloat(5, waveFrequency);

    final paint = Paint()..shader = shader;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _FlagPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.image != image ||
        oldDelegate.program != program ||
        oldDelegate.waveSpeed != waveSpeed ||
        oldDelegate.waveIntensity != waveIntensity ||
        oldDelegate.waveFrequency != waveFrequency;
  }
}
