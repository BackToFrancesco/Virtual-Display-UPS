import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../widgets/custom_text/custom_text.dart';

class TCell extends StatelessWidget {
  const TCell({Key? key, this.text, required this.color}) : super(key: key);
  final String? text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return text != null
        ? Center(
            child: Container(
                margin: const EdgeInsets.only(top:5),
                child: Align(
                    child: CustomText(text!, 14.0.sp, 12.0.sp, color: color))),
          )
        : const SizedBox.shrink();
  }
}
