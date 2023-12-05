import 'package:flutter/material.dart';
import '../../../../config/colors.dart' as app_colors;

class ArrowPainter extends CustomPainter {
  static const double xPosition = 15 / 100;
  final double strokeWidth;
  final Color? hLineColor;

  ArrowPainter(this.strokeWidth, [this.hLineColor]);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..strokeWidth = strokeWidth
      ..color = hLineColor ?? app_colors.white;
    canvas.drawLine(Offset(0, size.height * 1 / 2),
        Offset(size.width, size.height * 1 / 2), paint);
    paint.color = app_colors.mediumGrey;
    canvas.drawLine(Offset(size.width * xPosition, size.height * 40 / 100),
        Offset(size.width * xPosition, size.height * 15 / 100), paint);
    canvas.drawLine(Offset(size.width * xPosition, size.height * 15 / 100),
        Offset(size.width * 25 / 100, size.height * 15 / 100), paint);

    var path = Path();
    path.moveTo(size.width * 25 / 100, size.height * 10 / 100);
    path.lineTo(size.width * 25 / 100, size.height * 20 / 100);
    path.lineTo(size.width * 27.5 / 100, size.height * 15 / 100);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(ArrowPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(ArrowPainter oldDelegate) => false;
}
