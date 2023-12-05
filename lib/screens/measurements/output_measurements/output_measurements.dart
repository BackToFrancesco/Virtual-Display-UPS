import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../config/app_bar.dart';
import '../../../repositories/modbus_data_repository/models/modbus_data_manager/component_measurements/output_measurements.dart';
import '../../../widgets/status_bar/status_bar.dart';
import '../../../blocs/ups_connection_handler_bloc/ups_connection_handler_bloc.dart';
import '../../../config/colors.dart' as app_colors;
import '../../../repositories/modbus_data_repository/modbus_repository.dart';
import '../../../repositories/modbus_data_repository/models/modbus_connection_manager/modbus_connection_manager.dart';
import '../../../utils/translator.dart';
import '../../../widgets/dialog/dialog_factory.dart';
import '../../../widgets/navigation_drawer/navigation_drawer.dart';
import '../../../widgets/ups_connections_status/ups_connection_status.dart';
import '../widgets/table_cell.dart';
import '../widgets/table_header.dart';
import 'bloc/output_measurements_bloc.dart';

bool _isMenuOpened = false;

class OutputMeasurementsScreen extends StatelessWidget {
  const OutputMeasurementsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OutputMeasurementsBloc>(
      create: (BuildContext ctx) => OutputMeasurementsBloc(
          modbusDataRepository: context.read<ModbusRepository>())
        ..add(const Init()),
      child: OutputMeasurementsPage(),
    );
  }
}

class OutputMeasurementsPage extends StatelessWidget {
  OutputMeasurementsPage({Key? key}) : super(key: key);

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
                  drawer: NavigationDrawer(pageNumber: 7),
                  appBar: CustomAppBar(
                      title: _translator.translateIfExists("OUTPUT_MEASURES")),
                  body: SafeArea(child: Column(
                    children: [
                      getStatusBar(),
                      const UpsConnectionStatusRealTime(),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              contentBuilder(context),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),),
                )));
  }

  Widget getStatusBar() {
    return BlocBuilder<OutputMeasurementsBloc, OutputMeasurementsState>(
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

  Widget contentBuilder(BuildContext context) {
    return BlocBuilder<OutputMeasurementsBloc, OutputMeasurementsState>(
        buildWhen: (previous, current) =>
            previous.outputMeasurements != current.outputMeasurements,
        builder: (context, state) {
          if (state.outputMeasurements != null) {
            return getContentWidget(context, state.outputMeasurements);
          }
          return const SizedBox.shrink();
        });
  }

  Widget getContentWidget(BuildContext context, OutputMeasurements? outputMeasurements) {
    return Container(
        margin: MediaQuery.of(context).orientation == Orientation.portrait
            ? SizerUtil.deviceType == DeviceType.mobile
                ? const EdgeInsets.all(20)
                : EdgeInsets.fromLTRB(5.0.h, 20, 5.0.h, 20)
            : EdgeInsets.fromLTRB(15.0.h, 20, 15.0.h, 20),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          getFirstTable(outputMeasurements),
          const SizedBox(height: 50),
          getSecondTable(outputMeasurements)
        ]));
  }

  Widget getFirstTable(OutputMeasurements? outputMeasurements) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Table(
          columnWidths: const <int, TableColumnWidth>{
            0: FlexColumnWidth(1),
            1: FlexColumnWidth(2),
            2: FlexColumnWidth(2),
            3: FlexColumnWidth(2),
            4: FlexColumnWidth(2),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: <TableRow>[
            TableRow(children: [
              const SizedBox(),
              THeader(
                  text: _translator.translateIfExists("MEAS_S_KVA"),
                  color: app_colors.black),
              THeader(
                  text: _translator.translateIfExists("MEAS_P_KW"),
                  color: app_colors.black),
              THeader(
                  text: _translator.translateIfExists("MEAS_I_A"),
                  color: app_colors.black),
              THeader(
                  text: _translator.translateIfExists("MEAS_LR_PERC"),
                  color: app_colors.black),
            ]),
            TableRow(children: [
              THeader(
                  text: _translator.translateIfExists("DIAG_L1"),
                  color: app_colors.mediumYellow),
              TCell(
                  text: outputMeasurements!.m048,
                  color: app_colors.mediumYellow),
              TCell(
                  text: outputMeasurements.m051,
                  color: app_colors.mediumYellow),
              TCell(
                  text: outputMeasurements.m006,
                  color: app_colors.mediumYellow),
              TCell(
                  text: outputMeasurements.m001,
                  color: app_colors.mediumYellow),
            ]),
            TableRow(children: [
              THeader(
                  text: _translator.translateIfExists("DIAG_L2"),
                  color: app_colors.blue),
              TCell(text: outputMeasurements.m049, color: app_colors.blue),
              TCell(text: outputMeasurements.m052, color: app_colors.blue),
              TCell(text: outputMeasurements.m007, color: app_colors.blue),
              TCell(text: outputMeasurements.m002, color: app_colors.blue),
            ]),
            TableRow(children: [
              THeader(
                  text: _translator.translateIfExists("DIAG_L3"),
                  color: app_colors.purple),
              TCell(text: outputMeasurements.m050, color: app_colors.purple),
              TCell(text: outputMeasurements.m053, color: app_colors.purple),
              TCell(text: outputMeasurements.m008, color: app_colors.purple),
              TCell(text: outputMeasurements.m003, color: app_colors.purple),
            ]),
            TableRow(children: [
              THeader(
                  text: _translator.translateIfExists("N"),
                  color: app_colors.mediumGreen),
              const SizedBox(),
              const SizedBox(),
              TCell(
                  text: outputMeasurements.m009, color: app_colors.mediumGreen),
              TCell(
                  text: outputMeasurements.m046, color: app_colors.mediumGreen),
            ]),
            const TableRow(children: [
              SizedBox(),
              Divider(color: app_colors.grey),
              Divider(color: app_colors.grey),
              Divider(color: app_colors.grey),
              Divider(color: app_colors.grey),
            ]),
            TableRow(children: [
              THeader(
                  text: _translator.translateIfExists("SIGMA"),
                  color: app_colors.black),
              TCell(text: outputMeasurements.m004, color: app_colors.black),
              TCell(text: outputMeasurements.m005, color: app_colors.black),
              const SizedBox(),
              TCell(text: outputMeasurements.m000, color: app_colors.black),
            ]),
          ]),
    ]);
  }

  Widget getSecondTable(OutputMeasurements? outputMeasurements) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Table(
          columnWidths: const <int, TableColumnWidth>{
            0: FlexColumnWidth(1),
            1: FlexColumnWidth(2),
            2: FlexColumnWidth(2),
            3: FlexColumnWidth(2),
            4: FlexColumnWidth(2),
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
                  text: _translator.translateIfExists("MEAS_CF"),
                  color: app_colors.black),
              THeader(
                  text: _translator.translateIfExists("MEAS_PF"),
                  color: app_colors.black),
            ]),
            TableRow(children: [
              THeader(
                  text: _translator.translateIfExists("DIAG_L1"),
                  color: app_colors.mediumYellow),
              TCell(
                  text: outputMeasurements!.m054,
                  color: app_colors.mediumYellow),
              TCell(
                  text: outputMeasurements.m010,
                  color: app_colors.mediumYellow),
              TCell(
                  text: outputMeasurements.m060,
                  color: app_colors.mediumYellow),
              TCell(
                  text: outputMeasurements.m057,
                  color: app_colors.mediumYellow),
            ]),
            TableRow(children: [
              THeader(
                  text: _translator.translateIfExists("DIAG_L2"),
                  color: app_colors.blue),
              TCell(text: outputMeasurements.m055, color: app_colors.blue),
              TCell(text: outputMeasurements.m011, color: app_colors.blue),
              TCell(text: outputMeasurements.m061, color: app_colors.blue),
              TCell(text: outputMeasurements.m058, color: app_colors.blue),
            ]),
            TableRow(children: [
              THeader(
                  text: _translator.translateIfExists("DIAG_L3"),
                  color: app_colors.purple),
              TCell(text: outputMeasurements.m056, color: app_colors.purple),
              TCell(text: outputMeasurements.m012, color: app_colors.purple),
              TCell(text: outputMeasurements.m062, color: app_colors.purple),
              TCell(text: outputMeasurements.m059, color: app_colors.purple),
            ]),
            TableRow(children: [
              THeader(
                  text: _translator.translateIfExists("N"),
                  color: app_colors.mediumGreen),
              const SizedBox(),
              const SizedBox(),
              TCell(
                  text: outputMeasurements.m014, color: app_colors.mediumGreen),
              const SizedBox(),
            ]),
            const TableRow(children: [
              SizedBox(),
              Divider(color: app_colors.grey),
              Divider(color: app_colors.grey),
              Divider(color: app_colors.grey),
              Divider(color: app_colors.grey),
            ]),
          ]),
      Table(
          columnWidths: const <int, TableColumnWidth>{
            0: FlexColumnWidth(1),
            1: FlexColumnWidth(8),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: <TableRow>[
            TableRow(children: [
              THeader(
                  text: _translator.translateIfExists("FR"),
                  color: app_colors.black),
              TCell(text: outputMeasurements.m013, color: app_colors.black),
            ]),
          ]),
    ]);
  }
}
