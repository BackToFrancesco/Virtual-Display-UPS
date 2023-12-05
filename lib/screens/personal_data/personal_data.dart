import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../config/app_bar.dart';
import '../../../widgets/custom_text/custom_text.dart';
import '../../../blocs/ups_connection_handler_bloc/ups_connection_handler_bloc.dart';
import '../../../repositories/modbus_data_repository/models/modbus_connection_manager/modbus_connection_manager.dart';
import '../../../utils/translator.dart';
import '../../../widgets/dialog/dialog_factory.dart';
import '../../../widgets/navigation_drawer/navigation_drawer.dart';
import '../../blocs/authentication_bloc/authentication_bloc.dart';
import '../../repositories/authentication_repository/models/user.dart';

bool _isMenuOpened = false;

class PersonalDataScreen extends StatelessWidget {
  PersonalDataScreen({Key? key}) : super(key: key);

  final Translator _translator = Translator();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          if (_isMenuOpened) {
            return Future.value(true);
          } else {
            DialogFactory.showQuitTheAppDialog(context);
            return Future.value(false);
          }
        },
        child:
            BlocListener<UpsConnectionHandlerBloc, UpsConnectionHandlerState>(
                listener: (context, state) {
                  if ([
                    UpsConnectionStatus.disconnectedDueToIllegalAddress,
                    UpsConnectionStatus.disconnectedDueToIllegalFunction,
                    UpsConnectionStatus.disconnectedDueToInvalidData,
                    UpsConnectionStatus.disconnectedDueToConnectorError,
                    UpsConnectionStatus.disconnectedDueToUnknownErrorCode
                  ].contains(state.upsConnectionStatus)) {
                    DialogFactory.showDisconnectedFromUpsDialog(
                        context: context,
                        title: state.errorTitle!,
                        description: state.errorDescription!);
                  }
                },
                child: Scaffold(
                  onDrawerChanged: (isOpened) {
                    _isMenuOpened = isOpened;
                  },
                  drawer: NavigationDrawer(pageNumber: 13),
                  appBar: CustomAppBar(
                      title: _translator.translateIfExists("PERSONAL_DATA")),
                  body: SafeArea(child: SingleChildScrollView(
                    child: Center(
                        child: Column(
                      children: [
                        const SizedBox(height: 25),
                        personalDataList(context),
                        SizedBox(
                          height: 5.0.h,
                        ),
                        getImage(),
                        const SizedBox(height: 25),
                      ],
                    )),
                  ),),
                )));
  }

  Widget getImage() {
    return SvgPicture.asset(
      'assets/images/personal_data/personal_data.svg',
      height: (SizerUtil.deviceType == DeviceType.mobile ? 27.0.h : 27.0.h),
      width: (SizerUtil.deviceType == DeviceType.mobile ? 27.0.h : 27.0.h),
    );
  }

  Widget personalDataList(BuildContext context) {
    final User? user = context.read<AuthenticationBloc>().user;
    return Column(
      children: [
        labelText(_translator.translateIfExists("NAME")),
        const SizedBox(height: 15),
        text(user!.name),
        SizedBox(
          height: 4.0.h,
        ),
        labelText(_translator.translateIfExists("SURNAME")),
        const SizedBox(height: 15),
        text(user.surname),
        SizedBox(
          height: 4.0.h,
        ),
        labelText(_translator.translateIfExists("EMAIL")),
        const SizedBox(height: 15),
        text(user.email),
        SizedBox(
          height: 4.0.h,
        ),
        labelText(_translator.translateIfExists("PHONE_NUMBER")),
        const SizedBox(height: 15),
        text(user.phoneNumber),
      ],
    );
  }

  Widget labelText(String text) {
    return CustomText(text, 15.0.sp, 13.0.sp, bold: true);
  }

  Widget text(String text) {
    return CustomText(text, 14.0.sp, 12.0.sp);
  }
}
