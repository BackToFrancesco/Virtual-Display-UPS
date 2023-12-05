import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../config/app_bar.dart';
import '../../../repositories/modbus_data_repository/models/modbus_data_manager/component_measurements/bypass_measurements.dart';
import '../../../widgets/status_bar/status_bar.dart';
import '../../../blocs/ups_connection_handler_bloc/ups_connection_handler_bloc.dart';
import '../../../config/colors.dart' as app_colors;
import '../../../repositories/modbus_data_repository/modbus_repository.dart';
import '../../../repositories/modbus_data_repository/models/modbus_connection_manager/modbus_connection_manager.dart';
import '../../../utils/translator.dart';
import '../../../widgets/dialog/dialog_factory.dart';
import '../../../widgets/navigation_drawer/navigation_drawer.dart';
import '../../../widgets/ups_connections_status/ups_connection_status.dart';
import '../../../widgets/custom_text/custom_text.dart';
import '../widgets/linear_indicator.dart';
import '../widgets/table_cell.dart';
import '../widgets/table_header.dart';
import 'bloc/bypass_measurements_bloc.dart';

bool _isMenuOpened = false;

class BypassMeasurementsScreen extends StatelessWidget {
  const BypassMeasurementsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BypassMeasurementsBloc>(
      create: (BuildContext ctx) => BypassMeasurementsBloc(
          modbusDataRepository: context.read<ModbusRepository>())
        ..add(const Init()),
      child: BypassMeasurementsPage(),
    );
  }
}

class BypassMeasurementsPage extends StatelessWidget {
  BypassMeasurementsPage({Key? key}) : super(key: key);

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
                  drawer: NavigationDrawer(pageNumber: 3),
                  appBar: CustomAppBar(
                      title: _translator.translateIfExists("BYPASS_MEASURES")),
                  body: SafeArea(child: Column(
                    children: [
                      getStatusBar(),
                      const UpsConnectionStatusRealTime(),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [MediaQuery.of(context).orientation == Orientation.portrait
                                ? contentBuilderPortrait()
                                : contentBuilderLandscape()],
                          ),
                        ),
                      ),
                    ],
                  ),),
                )));
  }

  Widget getStatusBar() {
    return BlocBuilder<BypassMeasurementsBloc, BypassMeasurementsState>(
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

  Widget contentBuilderPortrait() {
    return BlocBuilder<BypassMeasurementsBloc, BypassMeasurementsState>(
        buildWhen: (previous, current) =>
            previous.bypassMeasurements != current.bypassMeasurements,
        builder: (context, state) {
          if (state.bypassMeasurements != null) {
            if (!state.bypassMeasurements!.noBypass) {
              return portraitWidget(state.bypassMeasurements);
            }
            return Center(
                child: CustomText(_translator.translateIfExists("NO_BYPASS"),
                    15.0.sp, 13.0.sp));
          }
          return const SizedBox.shrink();
        });
  }

  Widget contentBuilderLandscape() {
    return BlocBuilder<BypassMeasurementsBloc, BypassMeasurementsState>(
        buildWhen: (previous, current) =>
        previous.bypassMeasurements != current.bypassMeasurements,
        builder: (context, state) {
          if (state.bypassMeasurements != null) {
            if (!state.bypassMeasurements!.noBypass) {
              return landscapeWidget(state.bypassMeasurements);
            }
            return Center(
                child: CustomText(_translator.translateIfExists("NO_BYPASS"),
                    15.0.sp, 13.0.sp));
          }
          return const SizedBox.shrink();
        });
  }

  Widget portraitWidget(BypassMeasurements? bypassMeasurements) {
    return Container(
        margin: const EdgeInsets.fromLTRB(20, 50, 20, 0),
        child: getTable(bypassMeasurements, false));
  }

  Widget landscapeWidget(BypassMeasurements? bypassMeasurements) {
    return Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 40, 0),
        child: getTable(bypassMeasurements, true));
  }

  Widget getTable(BypassMeasurements? bypassMeasurements, bool extended) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Table(
          columnWidths: <int, TableColumnWidth>{
            0: const FlexColumnWidth(1),
            1: const FlexColumnWidth(2),
            2: const FlexColumnWidth(2),
            3: const FlexColumnWidth(2),
            4: const FlexColumnWidth(2),
            if (extended) 5: const FlexColumnWidth(3)
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: <TableRow>[
            TableRow(children: [
              const SizedBox(),
              THeader(
                  text: _translator.translateIfExists("MEAS_V_V"),
                  color: app_colors.black),
              THeader(
                  text: _translator.translateIfExists("MEAS_U_V"),
                  color: app_colors.black),
              THeader(
                  text: _translator.translateIfExists("MEAS_P_KW"),
                  color: app_colors.black),
              THeader(
                  text: _translator.translateIfExists("MEAS_I_A"),
                  color: app_colors.black),
              if (extended) const SizedBox(),
            ]),
            TableRow(children: [
              THeader(
                  text: _translator.translateIfExists("DIAG_L1"),
                  color: app_colors.mediumYellow),
              TCell(
                  text: bypassMeasurements!.m039,
                  color: app_colors.mediumYellow),
              TCell(
                  text: bypassMeasurements.m043,
                  color: app_colors.mediumYellow),
              TCell(
                  text: bypassMeasurements.m073,
                  color: app_colors.mediumYellow),
              TCell(
                  text: bypassMeasurements.m070,
                  color: app_colors.mediumYellow),
              if (extended && bypassMeasurements.m070 != null)
                LinearIndicator(
                    maximum: 100000,
                    value: double.parse(bypassMeasurements.m070!),
                    color: app_colors.mediumYellow),
            ]),
            TableRow(children: [
              THeader(
                  text: _translator.translateIfExists("DIAG_L2"),
                  color: app_colors.blue),
              TCell(text: bypassMeasurements.m040, color: app_colors.blue),
              TCell(text: bypassMeasurements.m044, color: app_colors.blue),
              TCell(text: bypassMeasurements.m074, color: app_colors.blue),
              TCell(text: bypassMeasurements.m071, color: app_colors.blue),
              if (extended && bypassMeasurements.m071 != null)
                LinearIndicator(
                    maximum: 100000,
                    value: double.parse(bypassMeasurements.m071!),
                    color: app_colors.blue),
            ]),
            TableRow(children: [
              THeader(
                  text: _translator.translateIfExists("DIAG_L3"),
                  color: app_colors.purple),
              TCell(text: bypassMeasurements.m041, color: app_colors.purple),
              TCell(text: bypassMeasurements.m045, color: app_colors.purple),
              TCell(text: bypassMeasurements.m075, color: app_colors.purple),
              TCell(text: bypassMeasurements.m072, color: app_colors.purple),
              if (extended && bypassMeasurements.m072 != null)
                LinearIndicator(
                    maximum: 100000,
                    value: double.parse(bypassMeasurements.m072!),
                    color: app_colors.purple),
            ]),
            TableRow(children: [
              const SizedBox(),
              const Divider(color: app_colors.grey),
              const Divider(color: app_colors.grey),
              const Divider(color: app_colors.grey),
              const Divider(color: app_colors.grey),
              if (extended) const SizedBox()
            ]),
          ]),
      Table(
          columnWidths: <int, TableColumnWidth>{
            0: const FlexColumnWidth(1),
            1: const FlexColumnWidth(8),
            if (extended) 2: const FlexColumnWidth(3),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: <TableRow>[
            TableRow(children: [
              THeader(
                  text: _translator.translateIfExists("FR"),
                  color: app_colors.black),
              TCell(text: bypassMeasurements.m042, color: app_colors.black),
              if (extended) const SizedBox(),
            ]),
          ]),
    ]);
  }
}
