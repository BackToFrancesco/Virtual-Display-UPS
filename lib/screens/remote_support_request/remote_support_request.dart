import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../widgets/dialog/dialog_factory.dart';
import 'package:sizer/sizer.dart';
import '../../blocs/authentication_bloc/authentication_bloc.dart';
import '../../blocs/remote_support_bloc/remote_support_request_bloc.dart';
import '../../blocs/ups_connection_handler_bloc/ups_connection_handler_bloc.dart';
import '../../config/app_bar.dart';
import '../../config/colors.dart' as app_colors;
import '../../repositories/modbus_data_repository/models/modbus_connection_manager/modbus_connection_manager.dart';
import '../../repositories/remote_support_request_repository/managers/remote_support_request_connection_manager.dart';
import '../../utils/translator.dart';
import '../../widgets/custom_text/custom_text.dart';
import '../../widgets/navigation_drawer/navigation_drawer.dart';

class RemoteSupportRequestScreen extends StatelessWidget {
  RemoteSupportRequestScreen({Key? key}) : super(key: key);

  final Translator _translator = Translator();

  bool _isMenuOpened = false;
  bool _serverConnectionInProgress = false;
  bool _disconnectedFromUps = false;
  bool _disconnectedFromServer = false;
  bool _noTechniciansDialog = false;
  bool _waitingDialog = false;
  bool _deleteRequestDialog = false;
  bool _remoteSupportRequestDeleted = false;
  bool _queuedUp = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () {
          if (_isMenuOpened) {
            return Future.value(true);
          } else if (!_serverConnectionInProgress) {
            DialogFactory.showQuitTheAppDialog(context);
            return Future.value(false);
          }
          return Future.value(false);
        },
        child: MultiBlocListener(
            listeners: [
              getUpsConnectionStatusListener(context),
              getRemoteRequestConnectionStatusListener(context)
            ],
            child: Scaffold(
                onDrawerChanged: (isOpened) {
                  _isMenuOpened = isOpened;
                },
                drawer: NavigationDrawer(pageNumber: 8),
                appBar: CustomAppBar(
                    title: _translator.translateIfExists("REMOTE_SUPPORT")),
                body: SafeArea(child: Center(
                    child: SingleChildScrollView(
                      child: Center(child: getContent(context)),
                    ))))));
  }

  BlocListener getUpsConnectionStatusListener(BuildContext context) {
    return BlocListener<UpsConnectionHandlerBloc, UpsConnectionHandlerState>(
        listener: (context, state) {
          if ([
            UpsConnectionStatus.disconnectedDueToIllegalAddress,
            UpsConnectionStatus.disconnectedDueToIllegalFunction,
            UpsConnectionStatus.disconnectedDueToInvalidData,
            UpsConnectionStatus.disconnectedDueToConnectorError,
            UpsConnectionStatus.disconnectedDueToUnknownErrorCode
          ].contains(state.upsConnectionStatus)) {
            _disconnectedFromUps = true;
            if (_queuedUp) {
              _queuedUp = false;
            }
            if (_serverConnectionInProgress) {
              Navigator.pop(context);
              _serverConnectionInProgress = false;
            } else if (_disconnectedFromServer) {
              Navigator.pop(context);
              _disconnectedFromServer = false;
            } else {
              if (_noTechniciansDialog) {
                Navigator.pop(context);
                _noTechniciansDialog = false;
              }
              if (_waitingDialog) {
                Navigator.pop(context);
                _waitingDialog = false;
              }
              if (_deleteRequestDialog) {
                Navigator.pop(context);
                _deleteRequestDialog = false;
              }
            }
            context
                .read<RemoteSupportRequestBloc>()
                .add(const DeleteRemoteSupportRequest());
            DialogFactory.showDisconnectedFromUpsDialog(
                context: context,
                title: state.errorTitle!,
                description: state.errorDescription!);
          }
        });
  }

  BlocListener getRemoteRequestConnectionStatusListener(BuildContext context) {
    return BlocListener<RemoteSupportRequestBloc, RemoteSupportRequestState>(
        listener: (context, state) {
          if (!_disconnectedFromUps) {
            if ([
              RemoteSupportRequestStatus.serverUnreachable,
              RemoteSupportRequestStatus.connectTimeout,
            ].contains(state.requestStatus)) {
              _queuedUp = false;
              _serverConnectionInProgress = false;
              _waitingDialog = false;
              Navigator.pop(context);
              showRemoteSupportRequestFailedDialog(
                  context: context,
                  title: state.errorTitle!,
                  description: state.errorDescription!);
            } else if (state.requestStatus ==
                RemoteSupportRequestStatus.disconnectedFromServer &&
                !_remoteSupportRequestDeleted) {
              _queuedUp = false;
              if (_noTechniciansDialog) {
                Navigator.pop(context);
                _noTechniciansDialog = false;
              }
              if (_waitingDialog) {
                Navigator.pop(context);
                _waitingDialog = false;
              }
              if (_deleteRequestDialog) {
                Navigator.pop(context);
                _waitingDialog = false;
                _deleteRequestDialog = false;
              }
              _disconnectedFromServer = true;
              showRemoteSupportRequestFailedDialog(
                  context: context,
                  title: state.errorTitle!,
                  description: state.errorDescription!);
            } else if (state.requestStatus ==
                RemoteSupportRequestStatus.connectedToServer) {
              _queuedUp = false;
              if (!_waitingDialog) {
                _serverConnectionInProgress = false;
                Navigator.pop(context);
                showWaitingForTechnicianDialog(context);
              }
            } else if (state.requestStatus ==
                RemoteSupportRequestStatus.noTechniciansAvailable) {
              showNoTechniciansDialog(context);
            } else if (state.requestStatus ==
                RemoteSupportRequestStatus.connectedToTechnician) {
              _waitingDialog = false;
              Navigator.of(context).pushNamedAndRemoveUntil(
                  "remoteSupportCall", (Route<dynamic> route) => false);
            }
          }
        });
  }

  Widget getContent(BuildContext context) {
    return Column(
      children: [
        if (MediaQuery.of(context).orientation == Orientation.landscape)
          const SizedBox(height: 20),
        getImage(context),
        SizedBox(
            height: MediaQuery.of(context).orientation == Orientation.portrait
                ? 5.0.h
                : 2.5.h),
        getButton(context),
        SizedBox(
            height: MediaQuery.of(context).orientation == Orientation.portrait
                ? 2.0.h
                : 1.0.h),
        CustomText(_translator.translateIfExists('Queue up and talk'), 14.0.sp,
            14.0.sp,
            bold: true),
        CustomText(
            _translator.translateIfExists('to the first available technician',
                capitalize: false),
            14.0.sp,
            14.0.sp,
            bold: true),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget getImage(BuildContext context) {
    return SvgPicture.asset(
      'assets/images/remote_support_request/waiting_screen.svg',
      height: MediaQuery.of(context).orientation == Orientation.portrait
          ? (SizerUtil.deviceType == DeviceType.mobile ? 60.0.w : 50.0.w)
          : 35.0.w,
      width: MediaQuery.of(context).orientation == Orientation.portrait
          ? (SizerUtil.deviceType == DeviceType.mobile ? 60.0.w : 50.0.w)
          : 35.0.w,
    );
  }

  Widget getButton(BuildContext context) {
    return BlocBuilder<RemoteSupportRequestBloc, RemoteSupportRequestState>(
        buildWhen: (previous, current) =>
        previous.requestStatus != current.requestStatus,
        builder: (context, state) {
          return ElevatedButton(
              style: ElevatedButton.styleFrom(primary: app_colors.socomecBlue),
              onPressed: state.requestStatus !=
                  RemoteSupportRequestStatus.connectedToServer &&
                  state.requestStatus !=
                      RemoteSupportRequestStatus.connectingToServer
                  ? () {
                if (context.read<AuthenticationBloc>().logged &&
                    !_queuedUp) {
                  _queuedUp = true;
                  _remoteSupportRequestDeleted = false;
                  _serverConnectionInProgress = true;
                  DialogFactory.showProgressDialog(context);
                  context
                      .read<RemoteSupportRequestBloc>()
                      .add(const QueueUp());
                } else {
                  DialogFactory.showGoToLoginDialog(context);
                }
              }
                  : null,
              child: CustomText(
                  _translator.translateIfExists('QUEUE_UP'), null, 11.0.sp,
                  color: app_colors.white));
        });
  }

  void showRemoteSupportRequestFailedDialog(
      {required BuildContext context,
        required String title,
        required String description,
        VoidCallback? onButtonClicked}) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return WillPopScope(
              onWillPop: () async => false,
              child: DialogFactory.getDialog(
                  context: context,
                  dialogType: DialogType.error,
                  title: title,
                  description: description,
                  onButtonClicked: onButtonClicked ??
                          () {
                        Navigator.pop(context);
                      }));
        });
  }

  void showNoTechniciansDialog(BuildContext context) {
    _noTechniciansDialog = true;
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return DialogFactory.getDialog(
              context: context,
              dialogType: DialogType.info,
              title: Translator().translateIfExists('No technicians available'),
              description:
              'There are no technicians available in this moment. Wait for the first available or try later');
        }).then((value) => _noTechniciansDialog = false);
  }

  void showWaitingForTechnicianDialog(BuildContext context) {
    _waitingDialog = true;
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return WillPopScope(
              onWillPop: () async => false,
              child: DialogFactory.getDialog(
                  context: context,
                  dialogType: DialogType.waitingForTechnician,
                  title: context.select(
                          (RemoteSupportRequestBloc bloc) => bloc.state.stopwatch),
                  description: 'Waiting for the first available technician' +
                      context.select((RemoteSupportRequestBloc bloc) =>
                      bloc.state.waitingDots),
                  onButtonClicked: () {
                    showDeleteRemoteSupportRequestDialog(context);
                  }));
        });
  }

  void showDeleteRemoteSupportRequestDialog(BuildContext context) {
    _deleteRequestDialog = true;
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return DialogFactory.getDialog(
              context: context,
              dialogType: DialogType.confirmation,
              title: 'Delete request',
              description:
              'Are you sure you want to delete the request for remote support?',
              onButtonClicked: () {
                _queuedUp = false;
                _remoteSupportRequestDeleted = true;
                context
                    .read<RemoteSupportRequestBloc>()
                    .add(const DeleteRemoteSupportRequest());
                Navigator.pop(context);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: CustomText(
                      Translator()
                          .translateIfExists("REMOTE_SUPPORT_REQUEST_DELETED"),
                      13.0.sp,
                      13.0.sp,
                      textAlign: TextAlign.center,
                      color: app_colors.white),
                  backgroundColor: app_colors.yellow,
                  duration: const Duration(seconds: 1),
                ));
              });
        }).then((value) {
      _waitingDialog = false;
      _deleteRequestDialog = false;
    });
  }
}
