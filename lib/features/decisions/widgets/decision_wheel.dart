import 'dart:math';

import 'package:flutter/material.dart';

const wheelColors = [
  Color(0xff7958d6),
  Color(0xffe9729e),
  Color(0xffecae53),
  Color(0xff56b6a5),
  Color(0xff589ad4),
  Color(0xffb77cdb),
];

class DecisionWheel extends StatelessWidget {
  final List<String> options;
  final double rotation;
  const DecisionWheel({
    super.key,
    required this.options,
    required this.rotation,
  });
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Decision wheel with ${options.length} equal segments',
    child: AspectRatio(
      aspectRatio: 1,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Transform.rotate(
              angle: rotation,
              child: CustomPaint(
                painter: WheelPainter(options, Directionality.of(context)),
                size: const Size.square(500),
              ),
            ),
          ),
          const Positioned(
            top: 0,
            child: Icon(
              Icons.arrow_drop_down_rounded,
              size: 56,
              color: Color(0xff34245d),
            ),
          ),
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 10),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Color(0xff7958d6),
              size: 29,
            ),
          ),
        ],
      ),
    ),
  );
}

class WheelPainter extends CustomPainter {
  final List<String> options;
  final TextDirection direction;
  WheelPainter(this.options, this.direction);
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    final sweep = 2 * pi / options.length;
    for (var i = 0; i < options.length; i++) {
      final start = -pi / 2 + i * sweep;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep,
        true,
        Paint()..color = wheelColors[i % wheelColors.length],
      );
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(start + sweep / 2);
      final p = TextPainter(
        text: TextSpan(
          text: options[i],
          style: TextStyle(
            color: i % wheelColors.length == 2 || i % wheelColors.length == 3
                ? const Color(0xff20182e)
                : Colors.white,
            fontSize: options.length > 12 ? 10 : 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: direction,
        maxLines: 1,
        ellipsis: '…',
      )..layout(maxWidth: radius * .55);
      p.paint(canvas, Offset(radius * .39, -p.height / 2));
      canvas.restore();
    }
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white.withValues(alpha: .8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5,
    );
  }

  @override
  bool shouldRepaint(WheelPainter old) =>
      old.options != options || old.direction != direction;
}
