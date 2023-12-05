import 'package:flutter/material.dart';
import '../../../../config/colors.dart' as app_colors;

class HBatteryLinePainter extends CustomPainter {
  final double strokeWidth;
  final Color hLineColor1;
  final Color? hLineColor2;
  final Color? vLeftLineColor1;
  final Color? vLeftLineColor2;
  final Color? vRightLineColor1;
  final Color? vRightLineColor2;

  HBatteryLinePainter(
      this.strokeWidth,
      this.hLineColor1,
      this.hLineColor2,
      this.vLeftLineColor1,
      this.vLeftLineColor2,
      this.vRightLineColor1,
      this.vRightLineColor2);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..strokeWidth = strokeWidth
      ..color = hLineColor1;

    canvas.drawLine(
      Offset(0, size.height * 1 / 2),
      Offset(size.width * 245 / 100, size.height * 1 / 2),
      paint,
    );

    paint.color = hLineColor2 ?? app_colors.white;
    canvas.drawLine(
      Offset(size.width * 245 / 100, size.height * 1 / 2),
      Offset(size.width * 260 / 100, size.height * 1 / 2),
      paint,
    );

    paint.color = hLineColor1;
    canvas.drawLine(
      Offset(size.width * 260 / 100, size.height * 1 / 2),
      Offset(size.width * 300 / 100, size.height * 1 / 2),
      paint,
    );

    paint.color = vLeftLineColor1 ?? app_colors.white;
    canvas.drawLine(
      Offset(size.width * 140 / 100, size.height * 48 / 100),
      Offset(size.width * 140 / 100, size.height * 46 / 100),
      paint,
    );
    paint.color = vLeftLineColor2 ?? app_colors.white;
    canvas.drawLine(
      Offset(size.width * 140 / 100, size.height * 46 / 100),
      Offset(size.width * 140 / 100, size.height * 25 / 100),
      paint,
    );
    paint.color = vRightLineColor1 ?? app_colors.white;
    canvas.drawLine(
      Offset(size.width * 260 / 100, size.height * 48 / 100),
      Offset(size.width * 260 / 100, size.height * 46 / 100),
      paint,
    );
    paint.color = vRightLineColor2 ?? app_colors.white;
    canvas.drawLine(
      Offset(size.width * 260 / 100, size.height * 46 / 100),
      Offset(size.width * 260 / 100, size.height * 25 / 100),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
