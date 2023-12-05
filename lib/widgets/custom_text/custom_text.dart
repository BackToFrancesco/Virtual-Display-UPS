import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../config/colors.dart' as app_colors;

class CustomText extends StatelessWidget {
  final String text;
  final double? fontSizeMobile;
  final double? fontSizeTablet;
  final bool bold;
  final Color color;
  final TextAlign textAlign;

  const CustomText(this.text, this.fontSizeMobile, this.fontSizeTablet,
      {Key? key,
      this.bold = false,
      this.color = app_colors.black,
      this.textAlign = TextAlign.left})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        textAlign: textAlign,
        style: TextStyle(
            fontSize: SizerUtil.deviceType == DeviceType.mobile
                ? fontSizeMobile
                : fontSizeTablet,
            fontWeight: !bold ? FontWeight.normal : FontWeight.bold,
            color: color));
  }
}
