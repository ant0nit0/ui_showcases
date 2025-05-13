import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class AnimatedText extends StatefulWidget {
  final String text;
  final double speed; // pixels per second
  final double width;
  final TextStyle? textStyle;

  const AnimatedText({
    super.key,
    required this.text,
    this.speed = 30.0,
    this.width = 300,
    this.textStyle,
  });

  @override
  State<AnimatedText> createState() => _AnimatedTextState();
}

class _AnimatedTextState extends State<AnimatedText>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  double _textWidth = 0;
  double _position = 0;
  late DateTime _lastTick;

  @override
  void initState() {
    super.initState();
    _lastTick = DateTime.now();
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    final now = DateTime.now();
    final dt = now.difference(_lastTick).inMilliseconds / 1000;
    _lastTick = now;

    setState(() {
      _position -= widget.speed * dt;
      if (_textWidth != 0 && _position <= -_textWidth) {
        _position += _textWidth;
      }
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  double _calculateTextWidth(BuildContext context) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: widget.text,
        style: widget.textStyle ?? DefaultTextStyle.of(context).style,
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    return textPainter.width;
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _textWidth =
            _calculateTextWidth(context) + 30; // Extra space between repeats
      });
    });

    return SizedBox(
      width: widget.width,
      height: 20,
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          return const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Colors.transparent,
              Colors.black,
              Colors.black,
              Colors.transparent,
            ],
            stops: [0.0, 0.05, 0.95, 1.0],
          ).createShader(bounds);
        },
        blendMode: BlendMode.dstIn,
        child: ClipRRect(
          child: Transform.translate(
            offset: Offset(_position, 0),
            child: OverflowBox(
              maxWidth: double.infinity,
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(widget.text, style: widget.textStyle),
                  const SizedBox(width: 30),
                  Text(widget.text, style: widget.textStyle),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
