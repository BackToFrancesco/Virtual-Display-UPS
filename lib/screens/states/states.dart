import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import '../../blocs/ups_connection_handler_bloc/ups_connection_handler_bloc.dart';
import '../../config/app_bar.dart';
import '../../repositories/modbus_data_repository/modbus_repository.dart';
import '../../repositories/modbus_data_repository/models/modbus_connection_manager/modbus_connection_manager.dart';
import '../../utils/translator.dart';
import '../../../widgets/navigation_drawer/navigation_drawer.dart';
import '../../../widgets/status_bar/status_bar.dart';
import '../../../widgets/custom_text/custom_text.dart';
import '../../../widgets/ups_connections_status/ups_connection_status.dart';
import '../../widgets/dialog/dialog_factory.dart';
import 'bloc/states_bloc.dart';

bool _isMenuOpened = false;

class StatesScreen extends StatelessWidget {
  const StatesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<StatesBloc>(
      create: (BuildContext ctx) =>
          StatesBloc(modbusDataRepository: context.read<ModbusRepository>())
            ..add(const Init()),
      child: StatesPage(),
    );
  }
}

class StatesPage extends StatelessWidget {
  StatesPage({Key? key}) : super(key: key);

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
                  drawer: NavigationDrawer(pageNumber: 1),
                  appBar: CustomAppBar(
                      title: _translator.translateIfExists("UPS_STATES")),
                  body: SafeArea(child: Column(
                    children: [
                      getStatusBar(),
                      const UpsConnectionStatusRealTime(),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              getStatesList(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),),
                )));
  }

  Widget getStatusBar() {
    return BlocBuilder<StatesBloc, StatesState>(
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

  Widget getStatesList() {
    return BlocBuilder<StatesBloc, StatesState>(
        buildWhen: (previous, current) => previous.states != current.states,
        builder: (context, state) {
          if (state.states != null) {
            return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.states!.length,
                itemBuilder: (context, index) {
                  if (index != 0) {
                    return ListTile(
                        title: CustomText(state.states![index], 2.2.h, 2.2.h));
                  }else{
                    return Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: ListTile(
                          title: CustomText(state.states![index], 2.2.h, 2.2.h)),
                    );
                  }
                });
          }
          return const SizedBox.shrink();
        });
  }
}
