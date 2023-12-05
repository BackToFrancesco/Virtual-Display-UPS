import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:formz/formz.dart';
import '../../blocs/ups_connection_handler_bloc/ups_connection_handler_bloc.dart';
import '../../repositories/modbus_data_repository/models/modbus_connection_manager/modbus_connection_manager.dart';
import '../../widgets/custom_text/custom_text.dart';
import 'package:sizer/sizer.dart';
import '../../config/app_bar.dart';
import '../../config/colors.dart' as app_colors;
import '../../utils/translator.dart';
import '../../widgets/dialog/dialog_factory.dart';
import 'bloc/ups_connection_bloc.dart';

bool _connectionInProgress = false;

class UpsConnectionScreen extends StatelessWidget {
  const UpsConnectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UpsConnectionBloc>(
        create: (BuildContext context) => UpsConnectionBloc(
            upsConnectionHandlerBloc:
                BlocProvider.of<UpsConnectionHandlerBloc>(context)),
        child: UpsConnectionPage());
  }
}

class UpsConnectionPage extends StatelessWidget {
  final Translator _translator = Translator();
  final TextEditingController ipAddressController = TextEditingController();
  final TextEditingController portController = TextEditingController();
  final TextEditingController slaveIdController = TextEditingController();

  UpsConnectionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          if (!_connectionInProgress) {
            return Future.value(true);
          }
          return Future.value(false);
        },
        child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: Scaffold(
              appBar: CustomAppBar(
                  title: _translator.translateIfExists("Connect_to_an_UPS",
                      capitalize: false)),
              body: SafeArea(child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    getConnectionForm(context),
                    const SizedBox(height: 10),
                    getSeeRecentConnections(context),
                    SizedBox(height: 5.0.h),
                    getImage(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),),
            )));
  }

  Widget getSeeRecentConnections(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomText(
            _translator.translateIfExists("Or see") + " ", 11.0.sp, 1.6.h),
        GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
            DialogFactory.showSelectRecentUpsConnectionDialog(context)
                .then((index) {
              if (index != null) {
                _connectionInProgress = true;
                context
                    .read<UpsConnectionBloc>()
                    .add(SubmittedFromRecentConnections(index));
              }
            });
          },
          child: CustomText(
              _translator.translateIfExists("recent connections",
                  capitalize: false),
              10.5.sp,
              1.5.h,
              bold: true,
              color: app_colors.socomecBlue),
        )
      ],
    );
  }

  Widget getImage() {
    return SvgPicture.asset(
      'assets/images/ups_connection/ups_connection.svg',
      height: (SizerUtil.deviceType == DeviceType.mobile ? 35.0.w : 30.0.w),
      width: (SizerUtil.deviceType == DeviceType.mobile ? 35.0.w : 30.0.w),
    );
  }

  Widget getConnectionForm(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<UpsConnectionHandlerBloc, UpsConnectionHandlerState>(
            listener: (context, state) {
          if (state.upsConnectionStatus == UpsConnectionStatus.connected) {
            _connectionInProgress = false;
            context.read<UpsConnectionBloc>().add(const SubmissionSuccess());
            handleConnectionSuccess(context);
          } else {
            _connectionInProgress = false;
            Navigator.of(context).pop();
            context.read<UpsConnectionBloc>().add(const SubmissionFailure());
            DialogFactory.showCannotConnectToUpsDialog(
                context: context,
                title: state.errorTitle!,
                description: state.errorDescription!);
          }
        }),
        BlocListener<UpsConnectionBloc, UpsConnectionState>(
          listenWhen: (previous, current) =>
              current.status == FormzStatus.submissionInProgress,
          listener: (context, state) {
            DialogFactory.showProgressDialog(context);
            if (state.fromRecentConnections) {
              ipAddressController.text = state.ipAddress.value;
              portController.text = state.port.value;
              slaveIdController.text = state.slaveId.value;
            }
          },
        ),
      ],
      child: Form(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          decoration: BoxDecoration(
            border: Border.all(
              color: app_colors.lightGrey,
            ),
            borderRadius: BorderRadius.circular(20.0),
          ),
          margin: (MediaQuery.of(context).orientation == Orientation.portrait
              ? (SizerUtil.deviceType == DeviceType.mobile
                  ? EdgeInsets.fromLTRB(15.0.w, 5.0.h, 15.0.w, 0.0.h)
                  : EdgeInsets.fromLTRB(25.0.w, 5.0.h, 25.0.w, 0.0.h))
              : EdgeInsets.fromLTRB(40.0.w, 5.0.h, 40.0.w, 0.0.h)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                  padding: const EdgeInsets.fromLTRB(7, 0, 0, 5),
                  child: CustomText(_translator.translateIfExists("IP_ADDRESS"),
                      14.0.sp, 2.0.h,
                      bold: true)),
              getIpAddressInput(),
              Container(
                  padding: const EdgeInsets.fromLTRB(7, 12, 0, 5),
                  child: CustomText(
                      _translator.translateIfExists("PORT"), 14.0.sp, 2.0.h,
                      bold: true)),
              getPortInput(),
              Container(
                  padding: const EdgeInsets.fromLTRB(7, 12, 0, 5),
                  child: CustomText(
                      _translator.translateIfExists("SLAVE_NUMBER"),
                      14.0.sp,
                      2.0.h,
                      bold: true)),
              getSlaveIdInput(),
              SizedBox(height: 2.0.h),
              Align(
                child: getConnectionButton(),
              ),
              SizedBox(
                  height:
                      SizerUtil.deviceType == DeviceType.mobile ? null : 0.5.h),
            ],
          ),
        ),
      ),
    );
  }

  void handleConnectionSuccess(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: CustomText(
          _translator.translateIfExists("Connection successful"),
          13.0.sp,
          13.0.sp,
          textAlign: TextAlign.center,
          color: app_colors.white),
      backgroundColor: app_colors.green,
      duration: const Duration(milliseconds: 400),
    ));
    Future.delayed(
        const Duration(milliseconds: 600),
        () => Navigator.of(context).pushNamedAndRemoveUntil(
            "dashboard", (Route<dynamic> route) => false));
  }

  Widget getIpAddressInput() {
    return BlocBuilder<UpsConnectionBloc, UpsConnectionState>(
        buildWhen: (previous, current) =>
            (previous.ipAddress != current.ipAddress),
        builder: (context, state) {
          return TextField(
            controller: ipAddressController,
            style: TextStyle(
                fontSize: (SizerUtil.deviceType == DeviceType.mobile
                    ? 12.0.sp
                    : 2.0.h)),
            onChanged: (ipAddress) => context
                .read<UpsConnectionBloc>()
                .add(IpAddressChanged(ipAddress)),
            decoration: InputDecoration(
                errorStyle: TextStyle(
                    fontSize: (SizerUtil.deviceType == DeviceType.mobile
                        ? 10.0.sp
                        : 1.5.h)),
                errorText:
                    state.ipAddress.invalid ? 'Invalid ip address' : null,
                contentPadding: const EdgeInsets.fromLTRB(10, 3, 10, 6),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: app_colors.lightLightGrey),
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                )),
          );
        });
  }

  Widget getPortInput() {
    return BlocBuilder<UpsConnectionBloc, UpsConnectionState>(
        buildWhen: (previous, current) => (previous.port != current.port),
        builder: (context, state) {
          return TextField(
            controller: portController,
            style: TextStyle(
                fontSize: (SizerUtil.deviceType == DeviceType.mobile
                    ? 12.0.sp
                    : 2.0.h)),
            onChanged: (port) =>
                context.read<UpsConnectionBloc>().add(PortChanged(port)),
            decoration: InputDecoration(
                errorStyle: TextStyle(
                    fontSize: (SizerUtil.deviceType == DeviceType.mobile
                        ? 10.0.sp
                        : 1.5.h)),
                errorText: state.port.invalid ? 'Invalid port' : null,
                contentPadding: const EdgeInsets.fromLTRB(10, 3, 10, 6),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: app_colors.lightLightGrey),
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                )),
          );
        });
  }

  Widget getSlaveIdInput() {
    return BlocBuilder<UpsConnectionBloc, UpsConnectionState>(
        buildWhen: (previous, current) => (previous.slaveId != current.slaveId),
        builder: (context, state) {
          return TextField(
            controller: slaveIdController,
            style: TextStyle(
                fontSize: (SizerUtil.deviceType == DeviceType.mobile
                    ? 12.0.sp
                    : 2.0.h)),
            onChanged: (slaveId) =>
                context.read<UpsConnectionBloc>().add(SlaveIdChanged(slaveId)),
            decoration: InputDecoration(
                errorStyle: TextStyle(
                    fontSize: (SizerUtil.deviceType == DeviceType.mobile
                        ? 10.0.sp
                        : 1.5.h)),
                errorText: state.slaveId.invalid ? 'Invalid slave id' : null,
                contentPadding: const EdgeInsets.fromLTRB(10, 3, 10, 6),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: app_colors.lightLightGrey),
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                )),
          );
        });
  }

  Widget getConnectionButton() {
    return BlocBuilder<UpsConnectionBloc, UpsConnectionState>(
        buildWhen: (previous, current) => previous.status != current.status,
        builder: (context, state) {
          return ElevatedButton(
            child: CustomText(
                _translator.translateIfExists("Connect"), null, 9.0.sp,
                color: app_colors.white),
            style: ElevatedButton.styleFrom(primary: app_colors.socomecBlue),
            onPressed: state.status.isValidated &&
                    !state.status.isSubmissionInProgress &&
                    !state.status.isSubmissionSuccess
                ? () {
                    _connectionInProgress = true;
                    FocusManager.instance.primaryFocus?.unfocus();
                    context.read<UpsConnectionBloc>().add(const Submitted());
                  }
                : null,
          );
        });
  }
}
