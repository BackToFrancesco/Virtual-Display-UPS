import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../widgets/custom_text/custom_text.dart';

class THeader extends StatelessWidget {
  const THeader({Key? key, required this.text, required this.color})
      : super(key: key);
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
            margin: const EdgeInsets.only(top:5),
            child:
                CustomText(text, 15.0.sp, 13.0.sp, color: color, bold: true)));
  }
}
