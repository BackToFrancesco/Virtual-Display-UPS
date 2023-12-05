import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import '../../blocs/ups_connection_handler_bloc/ups_connection_handler_bloc.dart';
import '../../config/app_bar.dart';
import 'config/screen_size.dart';
import '../../repositories/modbus_data_repository/modbus_repository.dart';
import '../../repositories/modbus_data_repository/models/modbus_connection_manager/modbus_connection_manager.dart';
import '../../utils/translator.dart';
import '../../widgets/dialog/dialog_factory.dart';
import '../../widgets/navigation_drawer/navigation_drawer.dart';
import '../../widgets/status_bar/status_bar.dart';
import '../../widgets/ups_connections_status/ups_connection_status.dart';
import 'bloc/dashboard_bloc.dart';
import 'widgets/synoptic.dart' as synoptic;

bool _isMenuOpened = false;

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DashboardBloc>(
      create: (BuildContext context) =>
          DashboardBloc(modbusDataRepository: context.read<ModbusRepository>()),
      child: _DashboardPage(),
    );
  }
}

class _DashboardPage extends StatelessWidget {
  _DashboardPage({Key? key}) : super(key: key);

  final Translator _translator = Translator();

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
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
                  drawer: NavigationDrawer(pageNumber: 0),
                  appBar: CustomAppBar(
                      title: _translator.translateIfExists("DASHBOARD")),
                  body: SafeArea(child: Column(
                    children: [
                      _getStatusBar(),
                      const UpsConnectionStatusRealTime(),
                      Expanded(
                        child: SingleChildScrollView(child: _contentBuilder()),
                      ),
                    ],
                  ),),
                )));
  }

  Widget _contentBuilder() {
    return BlocBuilder<DashboardBloc, DashboardState>(
        buildWhen: (previous, current) => previous.synoptic != current.synoptic,
        builder: (context, state) {
          if (state.synoptic != null) {
            return MediaQuery.of(context).orientation == Orientation.portrait
                ? synoptic.getSynopticPortrait(context, state.synoptic!)
                : synoptic.getSynopticLandscape(state.synoptic!);
          }
          return const SizedBox.shrink();
        });
  }

  Widget _getStatusBar() {
    return BlocBuilder<DashboardBloc, DashboardState>(
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
}
