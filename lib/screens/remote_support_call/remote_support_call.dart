import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:sizer/sizer.dart';
import '../../blocs/remote_support_bloc/remote_support_request_bloc.dart';
import '../../blocs/ups_connection_handler_bloc/ups_connection_handler_bloc.dart';
import '../../config/app_bar.dart';
import '../../config/colors.dart' as app_colors;
import '../../repositories/modbus_data_repository/models/modbus_connection_manager/modbus_connection_manager.dart';
import '../../repositories/remote_support_request_repository/managers/remote_support_request_connection_manager.dart';
import '../../utils/translator.dart';
import '../../widgets/custom_text/custom_text.dart';
import '../../widgets/dialog/dialog_factory.dart';
import '../../widgets/ups_connections_status/ups_connection_status.dart';

bool _callClosed = false;

class RemoteSupportCallScreen extends StatelessWidget {
  RemoteSupportCallScreen({Key? key}) : super(key: key);

  final Translator _translator = Translator();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          showCloseCallDialog(context);
          return Future.value(false);
        },
        child: MultiBlocListener(
            listeners: [
              getUpsConnectionStatusListener(context),
              getRemoteRequestConnectionStatusListener(context)
            ],
            child: Scaffold(
              body: SafeArea(
                child: Column(
                  children: [
                    MediaQuery.of(context).orientation == Orientation.portrait
                        ? headerPortraitView(context)
                        : headerLandscapeView(context),
                    MediaQuery.of(context).orientation == Orientation.portrait
                        ? videoRendersPortraitView(context)
                        : videoRendersLandscapeView(context),
                  ],
                ),
              ),
            )));
  }

  BlocListener getUpsConnectionStatusListener(BuildContext context) {
    return BlocListener<UpsConnectionHandlerBloc, UpsConnectionHandlerState>(
        listener: (context, state) {
      if ([
        UpsConnectionStatus.disconnectedDueToIllegalAddress,
        UpsConnectionStatus.disconnectedDueToIllegalFunction,
        UpsConnectionStatus.disconnectedDueToInvalidData,
        UpsConnectionStatus.disconnectedDueToConnectorError,
        UpsConnectionStatus.disconnectedDueToUnknownErrorCode,
        UpsConnectionStatus.unableToVerifyTheSlaveId,
        UpsConnectionStatus.unableToCommunicate,
        UpsConnectionStatus.unableToConnect
      ].contains(state.upsConnectionStatus)) {
        showDisconnectedFromUpsOrUnableToConnectDialog(
            context: context,
            title: state.errorTitle!,
            description: state.errorDescription!);
      }
    });
  }

  BlocListener getRemoteRequestConnectionStatusListener(BuildContext context) {
    return BlocListener<RemoteSupportRequestBloc, RemoteSupportRequestState>(
        listener: (context, state) {
      if (state.requestStatus ==
          RemoteSupportRequestStatus.callClosedByTechnician) {
        Navigator.of(context).pushNamedAndRemoveUntil(
            context.read<UpsConnectionHandlerBloc>().connected
                ? "remoteSupportRequest"
                : "upsConnection",
            (Route<dynamic> route) => false);
        showCallClosedByTechnicianDialog(context: context);
      } else if (state.requestStatus ==
              RemoteSupportRequestStatus.disconnectedFromServer &&
          !_callClosed) {
        Navigator.of(context).pushNamedAndRemoveUntil(
            context.read<UpsConnectionHandlerBloc>().connected
                ? "remoteSupportRequest"
                : "upsConnection",
            (Route<dynamic> route) => false);
        showDisconnectedFromServerDialog(
            context: context,
            title: state.errorTitle!,
            description: state.errorDescription!);
      }
    });
  }

  Widget headerPortraitView(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        upsConnectionStatus(context),
        technicianConnectionStatus(context),
      ]),
      Container(
          padding: const EdgeInsets.only(right: 14),
          child: CustomText(
              context.select(
                  (RemoteSupportRequestBloc bloc) => bloc.state.stopwatch),
              2.5.h,
              2.5.h))
    ]);
  }

  Widget headerLandscapeView(BuildContext context) {
    return Stack(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: upsConnectionStatus(context),
          ),
          technicianConnectionStatus(context),
        ]),
        Center(
          child: Container(
              padding: const EdgeInsets.only(top: 14),
              child: CustomText(
                  context.select(
                      (RemoteSupportRequestBloc bloc) => bloc.state.stopwatch),
                  2.5.h,
                  2.5.h)),
        ),
      ],
    );
  }

  Widget technicianConnectionStatus(BuildContext context) {
    return Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Row(children: [
          Icon(
            Icons.circle,
            color: app_colors.lightGreen,
            size: 2.2.h,
          ),
          const SizedBox(width: 5),
          CustomText(
              _translator.translateIfExists('TECHNICIAN', capitalize: false) +
                  ' #${context.read<RemoteSupportRequestBloc>().technician?.id ?? ""}',
              2.2.h,
              2.2.h,
              bold: true),
        ]));
  }

  Widget upsConnectionStatus(BuildContext context) {
    return Row(children: [
      const UpsConnectionStatusRealTime(),
      SizedBox(width: 1.0.h),
      BlocBuilder<UpsConnectionHandlerBloc, UpsConnectionHandlerState>(
          buildWhen: (previous, current) =>
              previous.upsConnectionStatus != current.upsConnectionStatus,
          builder: (context, state) {
            if ([
              UpsConnectionStatus.disconnectedDueToIllegalAddress,
              UpsConnectionStatus.disconnectedDueToIllegalFunction,
              UpsConnectionStatus.disconnectedDueToInvalidData,
              UpsConnectionStatus.disconnectedDueToConnectorError,
              UpsConnectionStatus.disconnectedDueToUnknownErrorCode,
              UpsConnectionStatus.unableToVerifyTheSlaveId,
              UpsConnectionStatus.unableToCommunicate,
              UpsConnectionStatus.unableToConnect
            ].contains(state.upsConnectionStatus)) {
              return GestureDetector(
                  onTap: () {
                    context
                        .read<UpsConnectionHandlerBloc>()
                        .add(const ReconnectToUps());
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(children: [
                      Icon(Icons.autorenew,
                          color: app_colors.lightRed, size: 3.0.h),
                      CustomText(
                          _translator.translateIfExists('RECONNECT',
                              capitalize: false),
                          2.2.h,
                          2.2.h,
                          bold: true,
                          color: app_colors.lightRed)
                    ]),
                  ));
            } else {
              return const SizedBox.shrink();
            }
          }),
    ]);
  }

  Widget getFABs(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(bottom: 1.5.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            getSwitchCameraFAB(context),
            const SizedBox(width: 20),
            getMicFAB(context),
            const SizedBox(width: 20),
            getVideoFAB(context),
            const SizedBox(width: 20),
            getCloseCallFAB(context),
            SizedBox(width: 1.5.h)
          ],
        ));
  }

  Widget getSwitchCameraFAB(BuildContext context) {
    return getFAB(
        width: 13.0.w,
        height: 13.0.w,
        icon: Icons.switch_camera,
        color: app_colors.socomecBlue,
        onClicked: () {
          context.read<RemoteSupportRequestBloc>().add(const SwitchCamera());
        });
  }

  Widget getMicFAB(BuildContext context) {
    return BlocBuilder<RemoteSupportRequestBloc, RemoteSupportRequestState>(
        buildWhen: (previous, current) =>
            previous.micEnabled != current.micEnabled,
        builder: (context, state) {
          return getFAB(
              width: 13.0.w,
              height: 13.0.w,
              icon: state.micEnabled ? Icons.mic : Icons.mic_off,
              color: app_colors.socomecBlue,
              onClicked: () {
                context
                    .read<RemoteSupportRequestBloc>()
                    .add(const EnableOrDisableMic());
              });
        });
  }

  Widget getVideoFAB(BuildContext context) {
    return BlocBuilder<RemoteSupportRequestBloc, RemoteSupportRequestState>(
        buildWhen: (previous, current) =>
            previous.videoEnabled != current.videoEnabled,
        builder: (context, state) {
          return getFAB(
              width: 13.0.w,
              height: 13.0.w,
              icon: state.videoEnabled ? Icons.videocam : Icons.videocam_off,
              color: app_colors.socomecBlue,
              onClicked: () {
                context
                    .read<RemoteSupportRequestBloc>()
                    .add(const EnableOrDisableVideo());
              });
        });
  }

  Widget getCloseCallFAB(BuildContext context) {
    return getFAB(
        width: 16.0.w,
        height: 16.0.w,
        icon: Icons.call_end,
        color: app_colors.red,
        onClicked: () {
          _callClosed = true;
          context.read<RemoteSupportRequestBloc>().add(const CloseCall());
          Navigator.of(context).pushNamedAndRemoveUntil(
              context.read<UpsConnectionHandlerBloc>().connected
                  ? "remoteSupportRequest"
                  : "upsConnection",
              (Route<dynamic> route) => false);
        });
  }

  Widget getFAB(
      {required double width,
      required double height,
      required IconData icon,
      required Color color,
      required VoidCallback onClicked}) {
    return SizedBox(
      width: width,
      height: height,
      child: FittedBox(
        child: FloatingActionButton(
          heroTag: null,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20))),
          backgroundColor: color,
          onPressed: onClicked,
          child: Icon(icon),
        ),
      ),
    );
  }

  Widget videoRendersPortraitView(BuildContext context) {
    return Expanded(
        child: Column(children: [
      Expanded(flex: 1, child: getRemoteVideoView(context)),
      Expanded(flex: 1, child: getLocalVideoView(context))
    ]));
  }

  Widget videoRendersLandscapeView(BuildContext context) {
    return Expanded(
        child: Row(children: [
      Expanded(flex: 1, child: getRemoteVideoView(context)),
      Expanded(flex: 1, child: getLocalVideoView(context))
    ]));
  }

  Widget getLocalVideoView(BuildContext context) {
    return BlocBuilder<RemoteSupportRequestBloc, RemoteSupportRequestState>(
        buildWhen: (previous, current) =>
            previous.videoEnabled != current.videoEnabled,
        builder: (context, state) {
          return Stack(children: [
            Container(
              width: MediaQuery.of(context).orientation == Orientation.portrait
                  ? null
                  : 50.0.h,
              margin: MediaQuery.of(context).orientation == Orientation.portrait
                  ? const EdgeInsets.fromLTRB(10, 5, 10, 10)
                  : const EdgeInsets.fromLTRB(5, 0, 10, 10),
              constraints: const BoxConstraints.expand(),
              decoration: state.videoEnabled
                  ? null
                  : BoxDecoration(
                      color: app_colors.lightGrey,
                      border: Border.all(
                        color: app_colors.lightGrey,
                      ),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
              child: state.videoEnabled
                  ? RTCVideoView(
                      context.read<RemoteSupportRequestBloc>().localRenderer,
                      objectFit:
                          RTCVideoViewObjectFit.RTCVideoViewObjectFitCover)
                  : Center(child: Icon(Icons.videocam_off, size: 13.0.w)),
            ),
            Container(
                margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [getFABs(context)]))
          ]);
        });
  }

  Widget getRemoteVideoView(BuildContext context) {
    return BlocBuilder<RemoteSupportRequestBloc, RemoteSupportRequestState>(
        buildWhen: (previous, current) =>
            previous.technicianMicEnabled != current.technicianMicEnabled ||
            previous.technicianVideoEnabled != current.technicianVideoEnabled,
        builder: (context, state) {
          return Container(
              width: MediaQuery.of(context).orientation == Orientation.portrait
                  ? null
                  : 50.0.h,
              margin: MediaQuery.of(context).orientation == Orientation.portrait
                  ? const EdgeInsets.fromLTRB(10, 0, 10, 5)
                  : const EdgeInsets.fromLTRB(10, 0, 5, 10),
              constraints: const BoxConstraints.expand(),
              decoration: state.technicianVideoEnabled
                  ? null
                  : BoxDecoration(
                      color: app_colors.lightGrey,
                      border: Border.all(
                        color: app_colors.lightGrey,
                      ),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
              child: Stack(children: [
                Center(
                    child: state.technicianVideoEnabled
                        ? RTCVideoView(
                            context
                                .read<RemoteSupportRequestBloc>()
                                .remoteRenderer,
                            objectFit: RTCVideoViewObjectFit
                                .RTCVideoViewObjectFitCover)
                        : Center(
                            child: Icon(Icons.videocam_off, size: 13.0.w))),
                if (!state.technicianMicEnabled)
                  Container(
                      margin: const EdgeInsets.fromLTRB(0, 10, 10, 0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(
                              Icons.mic_off,
                              size: 10.0.w,
                            )
                          ])),
              ]));
        });
  }

  void showDisconnectedFromUpsOrUnableToConnectDialog(
      {required BuildContext context,
      required String title,
      required String description}) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return DialogFactory.getDialog(
              context: context,
              dialogType: DialogType.error,
              title: title,
              description: description,
              onButtonClicked: () {
                Navigator.pop(context);
              });
        });
  }

  void showCloseCallDialog(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return DialogFactory.getDialog(
              context: context,
              dialogType: DialogType.confirmation,
              title: 'Close call',
              description:
                  'Are you sure you want to close the call with the technician?',
              onButtonClicked: () {
                _callClosed = true;
                Navigator.of(context).pushNamedAndRemoveUntil(
                    !context.read<UpsConnectionHandlerBloc>().connected
                        ? "remoteSupportRequest"
                        : "upsConnection",
                    (Route<dynamic> route) => false);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: CustomText(
                      _translator.translateIfExists("CALL_CLOSED"),
                      13.0.sp,
                      13.0.sp,
                      textAlign: TextAlign.center,
                      color: app_colors.white),
                  backgroundColor: app_colors.yellow,
                  duration: const Duration(seconds: 1),
                ));
              });
        });
  }

  void showCallClosedByTechnicianDialog({required BuildContext context}) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return DialogFactory.getDialog(
              context: context,
              dialogType: DialogType.error,
              title: "Call closed",
              description: "The call was closed by the technician",
              onButtonClicked: () {
                Navigator.pop(context);
              });
        });
  }

  void showDisconnectedFromServerDialog(
      {required BuildContext context,
      required String title,
      required String description}) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return DialogFactory.getDialog(
              context: context,
              dialogType: DialogType.error,
              title: title,
              description: description,
              onButtonClicked: () {
                Navigator.pop(context);
              });
        });
  }
}
