import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../utils/translator.dart';
import 'bloc/alarms_bloc.dart';
import 'package:sizer/sizer.dart';
import '../../blocs/ups_connection_handler_bloc/ups_connection_handler_bloc.dart';
import '../../config/app_bar.dart';
import '../../repositories/modbus_data_repository/modbus_repository.dart';
import '../../repositories/modbus_data_repository/models/modbus_connection_manager/modbus_connection_manager.dart';
import '../../widgets/dialog/dialog_factory.dart';
import '../../widgets/navigation_drawer/navigation_drawer.dart';
import '../../widgets/status_bar/status_bar.dart';
import '../../../widgets/custom_text/custom_text.dart';
import '../../widgets/ups_connections_status/ups_connection_status.dart';

bool _isMenuOpened = false;

class AlarmsScreen extends StatelessWidget {
  const AlarmsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AlarmsBloc>(
      create: (BuildContext ctx) =>
          AlarmsBloc(modbusDataRepository: context.read<ModbusRepository>())
            ..add(const Init()),
      child: AlarmsPage(),
    );
  }
}

class AlarmsPage extends StatelessWidget {
  AlarmsPage({Key? key}) : super(key: key);

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
                  drawer: NavigationDrawer(pageNumber: 2),
                  appBar: CustomAppBar(
                      title: _translator.translateIfExists("UPS_ALARMS")),
                  body: SafeArea(child: Column(
                    children: [
                      getStatusBar(),
                      const UpsConnectionStatusRealTime(),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              getAlarmsList(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),),
                )));
  }

  Widget getStatusBar() {
    return BlocBuilder<AlarmsBloc, AlarmsState>(
        buildWhen: (previous, current) =>
            previous.upsStatus != current.upsStatus,
        builder: (context, state) {
          if (state.upsStatus != null) {
            return StatusBar(
                context: context,
                description: state.upsStatus!.description,
                color: state.upsStatus!.color);
          }
          return const SizedBox.shrink();
        });
  }

  Widget getAlarmsList() {
    return BlocBuilder<AlarmsBloc, AlarmsState>(
        buildWhen: (previous, current) => previous.alarms != current.alarms,
        builder: (context, state) {
          if (state.alarms != null) {
            return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.alarms!.length,
                itemBuilder: (context, index) {
                  return ListTile(
                      title: CustomText(state.alarms![index], 2.2.h, 2.2.h));
                });
          }
          return const SizedBox.shrink();
        });
  }
}
