import 'package:flutter/material.dart';
import '../../../../config/colors.dart' as app_colors;

class VDLinePainter extends CustomPainter {
  final double strokeWidth;
  final Color line1;
  final Color? line2;

  VDLinePainter(this.strokeWidth, this.line1, this.line2);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = strokeWidth
      ..color = line1;

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

    paint.color = line2 ?? app_colors.white;
    canvas.drawLine(
      Offset(size.width, size.height * 10 / 100),
      Offset(size.width, 0),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
