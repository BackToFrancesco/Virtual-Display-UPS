import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../widgets/custom_text/custom_text.dart';

class StatusBar extends StatelessWidget {
  final BuildContext context;
  final String description;
  final Color color;

  const StatusBar(
      {Key? key,
      required this.context,
      required this.description,
      required this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(6),
        color: color,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FittedBox(
                fit: BoxFit.fitWidth,
                child: CustomText(description, 2.4.h, 2.5.h, bold: true))
          ],
        ));
  }
}
