import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sizer/sizer.dart';
import '../../config/colors.dart' as app_colors;
import '../../utils/translator.dart';
import '../../widgets/dialog/dialog_factory.dart';
import '../../../widgets/custom_text/custom_text.dart';
import 'bloc/get_started_bloc.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => GetStartedBloc()..add(const Init()),
      child: GetStartedPage(),
    );
  }
}

class GetStartedPage extends StatelessWidget {
  final Translator _translator = Translator();

  GetStartedPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: app_colors.white,
        body: SafeArea(child: Center(
            child: SingleChildScrollView(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
              const SizedBox(height: 20),
              getImage(context),
              SizedBox(height: 3.0.h),
              getContent(),
              const SizedBox(height: 20),
            ])))));
  }

  Widget getContent() {
    return BlocBuilder<GetStartedBloc, GetStartedState>(
        buildWhen: (previous, current) => previous.language != current.language,
        builder: (context, state) {
          return Column(
            children: [
              CustomText(
                  _translator
                      .translateIfExists('The greatest human-UPS interaction'),
                  14.0.sp,
                  14.0.sp,
                  bold: true),
              SizedBox(height: 1.0.h),
              CustomText(_translator.translateIfExists('TITLE_LANGUAGE') + ":",
                  14.0.sp, 12.0.sp),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    getLanguageInfoIcon(context),
                    getLanguageSelection(context, state.language),
                  ]),
              SizedBox(height: 1.5.h),
              getButton(context),
              SizedBox(
                  height: MediaQuery.of(context).orientation == Orientation.portrait
                      ? 5.0.h
                      : 0.0.h)
            ],
          );
        });
  }

  Widget getLanguageInfoIcon(BuildContext context) {
    return IconButton(
      iconSize: 15.0.sp,
      icon: const Icon(Icons.info, color: app_colors.socomecBlueLight),
      onPressed: () {
        DialogFactory.showLanguageInfoDialog(
            context,
            _translator.translateIfExists('TITLE_LANGUAGE'),
            'Choose the language for information regarding the UPS');
      },
    );
  }

  Widget getImage(BuildContext context) {
    return SvgPicture.asset(
      'assets/images/get_started/home_page.svg',
      height: MediaQuery.of(context).orientation == Orientation.portrait
          ? (SizerUtil.deviceType == DeviceType.mobile ? 60.0.w : 50.0.w)
          : 50.0.w,
      width: MediaQuery.of(context).orientation == Orientation.portrait
          ? (SizerUtil.deviceType == DeviceType.mobile ? 60.0.w : 50.0.w)
          : 50.0.w,
    );
  }

  Widget getButton(BuildContext context) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(primary: app_colors.socomecBlue),
        onPressed: () {
          Navigator.of(context).pushNamed('upsConnection');
        },
        child: CustomText(
            _translator.translateIfExists('Get started'), null, 11.0.sp,
            color: app_colors.white));
  }

  Widget getLanguageSelection(BuildContext context, String? language) {
    return GestureDetector(
        onTap: () {
          DialogFactory.showSelectLanguageDialog(context).then((index) {
            if (index != null) {
              context
                  .read<GetStartedBloc>()
                  .add(LanguageChanged(_translator.getLanguages()[index]));
            }
          });
        },
        child: Row(children: [
          if (language != null) CustomText(language, 11.0.sp, 11.0.sp),
          Icon(Icons.arrow_drop_down,
              size: SizerUtil.deviceType == DeviceType.mobile ? null : 3.0.h)
        ]));
  }
}
