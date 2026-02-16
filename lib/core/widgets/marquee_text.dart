import 'package:flutter/material.dart';

class MarqueeText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final ScrollPhysics physics;
  final Duration scrollDuration;
  final Duration pauseDuration;

  const MarqueeText({
    super.key,
    required this.text,
    required this.style,
    this.physics = const NeverScrollableScrollPhysics(),
    this.scrollDuration = const Duration(
      seconds: 2,
    ), // Faster: 3s instead of 5s
    this.pauseDuration = const Duration(
      milliseconds: 500,
    ), // Faster: 1s instead of 1.5s
  });

  @override
  State<MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<MarqueeText>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;
  double _textWidth = 0;
  final double _gap = 40.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController =
        AnimationController(vsync: this, duration: widget.scrollDuration)
          ..addListener(() {
            if (_scrollController.hasClients && _textWidth > 0) {
              _scrollController.jumpTo(
                _animationController.value * (_textWidth + _gap),
              );
            }
          });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _calculateWidth(BoxConstraints constraints) {
    final textPainter = TextPainter(
      text: TextSpan(text: widget.text, style: widget.style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();

    final width = textPainter.width;

    // Only scroll if text is wider than available space
    if (width > constraints.maxWidth) {
      if (_textWidth != width) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _textWidth = width;
              _animationController.repeat();
            });
          }
        });
      }
    } else {
      if (_textWidth != 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _textWidth = 0;
              _animationController.stop();
              _scrollController.jumpTo(0);
            });
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _calculateWidth(constraints);

        return SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: Row(
            children: [
              Text(widget.text, style: widget.style),
              if (_textWidth > 0) ...[
                SizedBox(width: _gap),
                Text(widget.text, style: widget.style),
                SizedBox(width: _gap), // Buffer for seamless loop
              ],
            ],
          ),
        );
      },
    );
  }
}
