import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import '../utils/translator.dart';
import '../widgets/custom_text/custom_text.dart';
import 'colors.dart' as app_colors;

class CustomAppBar extends StatelessWidget with PreferredSizeWidget {
  final String title;

  const CustomAppBar({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 100.0.h,
      iconTheme: IconThemeData(
          color: app_colors.white,
          size: (SizerUtil.deviceType == DeviceType.mobile ? 3.8.h : 3.8.h)),
      title: FittedBox(
          fit: BoxFit.fitWidth,
          child: CustomText(Translator().translateIfExists(title), 3.5.h, 3.5.h,
              color: app_colors.white)),
      centerTitle: true,
      backgroundColor: app_colors.socomecBlueLight,
      systemOverlayStyle:
          const SystemUiOverlayStyle(statusBarColor: app_colors.socomecBlue),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(7.0.h);
}
