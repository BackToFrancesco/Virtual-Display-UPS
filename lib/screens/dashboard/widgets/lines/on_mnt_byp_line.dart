import 'package:flutter/material.dart';

class OnMntBypLine extends CustomPainter {
  final double strokeWidth;
  final Color line;

  OnMntBypLine(this.strokeWidth, this.line);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = strokeWidth
      ..color = line;

    canvas.drawLine(
      Offset(0, size.height * 1 / 2),
      Offset(size.width, size.height * 1 / 2),
      paint,
    );

    canvas.drawLine(
      Offset(size.width, size.height * 1 / 2),
      Offset(size.width, size.height * 10 / 100),
      paint,
    );

    canvas.drawLine(
      Offset(size.width, size.height * 10 / 100),
      Offset(6.6 * size.width, size.height * 10 / 100),
      paint,
    );

    canvas.drawLine(
      Offset(6.6 * size.width, size.height * 10 / 100),
      Offset(6.6 * size.width, size.height * 1.38),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
