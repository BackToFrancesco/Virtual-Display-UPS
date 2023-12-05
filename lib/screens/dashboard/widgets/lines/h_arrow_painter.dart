import 'package:flutter/material.dart';

class HArrowPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final bool shorter;

  HArrowPainter(this.strokeWidth, this.color, this.shorter);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..strokeWidth = strokeWidth
      ..color = color;

    canvas.drawLine(
      Offset(!shorter ? 0 : size.width * 0.33, size.height * 1 / 2),
      Offset(size.width * 3 / 4, size.height * 1 / 2),
      paint,
    );

    var path = Path();
    path.moveTo(size.width * 75 / 100, size.height * 30 / 100);
    path.lineTo(size.width * 75 / 100, size.height * 70 / 100);
    path.lineTo(size.width, size.height * 50 / 100);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(HArrowPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(HArrowPainter oldDelegate) => false;
}
