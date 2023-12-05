import 'package:flutter/material.dart';
import '../../../../../config/colors.dart' as app_colors;

class HLinePainter extends CustomPainter {
  final Color? color;
  final double strokeWidth;

  HLinePainter(
    this.strokeWidth,
    this.color,
  );

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..strokeWidth = strokeWidth
      ..color = color ?? app_colors.white;

    canvas.drawLine(
      Offset(0, size.height * 1 / 2),
      Offset(size.width, size.height * 1 / 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
