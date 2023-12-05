import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import '../../../repositories/modbus_data_repository/models/modbus_data_manager/component_measurements/inverter_measurements.dart';
import '../../../utils/translator.dart';
import '../../../widgets/status_bar/status_bar.dart';
import '../../../blocs/ups_connection_handler_bloc/ups_connection_handler_bloc.dart';
import '../../../config/app_bar.dart';
import '../../../config/colors.dart' as app_colors;
import '../../../repositories/modbus_data_repository/modbus_repository.dart';
import '../../../repositories/modbus_data_repository/models/modbus_connection_manager/modbus_connection_manager.dart';
import '../../../widgets/dialog/dialog_factory.dart';
import '../../../widgets/navigation_drawer/navigation_drawer.dart';
import '../../../widgets/ups_connections_status/ups_connection_status.dart';
import '../widgets/table_cell.dart';
import '../widgets/table_header.dart';
import '../widgets/thermometer.dart';
import 'bloc/inverter_measurements_bloc.dart';

bool _isMenuOpened = false;

class InverterMeasurementsScreen extends StatelessWidget {
  const InverterMeasurementsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<InverterMeasurementsBloc>(
      create: (BuildContext ctx) => InverterMeasurementsBloc(
          modbusDataRepository: context.read<ModbusRepository>())
        ..add(const Init()),
      child: InverterMeasurementsPage(),
    );
  }
}

class InverterMeasurementsPage extends StatelessWidget {
  InverterMeasurementsPage({Key? key}) : super(key: key);

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
                  drawer: NavigationDrawer(pageNumber: 6),
                  appBar: CustomAppBar(
                      title: _translator.translateIfExists("MEAS_INVERTER")),
                  body: SafeArea(child: Column(
                    children: [
                      getStatusBar(),
                      const UpsConnectionStatusRealTime(),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              MediaQuery.of(context).orientation == Orientation.portrait
                                  ? contentBuilderPortrait()
                                  : contentBuilderLandscape()
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),),
                )));
  }

  Widget getStatusBar() {
    return BlocBuilder<InverterMeasurementsBloc, InverterMeasurementsState>(
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
    return BlocBuilder<InverterMeasurementsBloc, InverterMeasurementsState>(
        buildWhen: (previous, current) =>
            previous.inverterMeasurements != current.inverterMeasurements,
        builder: (context, state) {
          if (state.inverterMeasurements != null) {
            return _portraitWidget(state.inverterMeasurements);
          }
          return const SizedBox.shrink();
        });
  }

  Widget contentBuilderLandscape() {
    return BlocBuilder<InverterMeasurementsBloc, InverterMeasurementsState>(
        buildWhen: (previous, current) =>
            previous.inverterMeasurements != current.inverterMeasurements,
        builder: (context, state) {
          if (state.inverterMeasurements != null) {
            return landscapeWidget(state.inverterMeasurements);
          }
          return const SizedBox.shrink();
        });
  }

  Widget _portraitWidget(InverterMeasurements? inverterMeasurements) {
    return Column(children: [
      Container(
          margin: SizerUtil.deviceType == DeviceType.mobile
              ? const EdgeInsets.all(20)
              : EdgeInsets.fromLTRB(5.0.h, 20, 5.0.h, 20),
          child: getTable(inverterMeasurements)),
      const SizedBox(height: 20),
      Center(
          child: SizedBox(
              height: 35.h, child: getThermometer(inverterMeasurements!.m015)))
    ]);
  }

  Widget landscapeWidget(InverterMeasurements? inverterMeasurements) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 50.w,
          child: Column(children: [
            getTable(inverterMeasurements),
          ]),
        ),
        SizedBox(
          width: 50.w,
          child: Column(
            children: [
              SizedBox(
                height: 60.w,
                child: getThermometer(inverterMeasurements!.m015),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget getTable(InverterMeasurements? inverterMeasurements) {
    return Column(mainAxisAlignment: MainAxisAlignment.start, children: [
      Table(
          columnWidths: const <int, TableColumnWidth>{
            0: FlexColumnWidth(1),
            1: FlexColumnWidth(2),
            2: FlexColumnWidth(2),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: <TableRow>[
            TableRow(children: [
              const SizedBox(),
              THeader(
                  text: _translator.translateIfExists('MEAS_U_V'),
                  color: app_colors.black),
              THeader(
                  text: _translator.translateIfExists('MEAS_V_V'),
                  color: app_colors.black),
            ]),
            TableRow(children: [
              THeader(
                  text: _translator.translateIfExists("DIAG_L1"),
                  color: app_colors.mediumYellow),
              TCell(
                  text: inverterMeasurements!.m054,
                  color: app_colors.mediumYellow),
              TCell(
                  text: inverterMeasurements.m010,
                  color: app_colors.mediumYellow),
            ]),
            TableRow(children: [
              THeader(
                  text: _translator.translateIfExists("DIAG_L2"),
                  color: app_colors.blue),
              TCell(text: inverterMeasurements.m055, color: app_colors.blue),
              TCell(text: inverterMeasurements.m011, color: app_colors.blue),
            ]),
            TableRow(children: [
              THeader(
                  text: _translator.translateIfExists("DIAG_L3"),
                  color: app_colors.purple),
              TCell(text: inverterMeasurements.m056, color: app_colors.purple),
              TCell(text: inverterMeasurements.m012, color: app_colors.purple),
            ]),
            const TableRow(children: [
              SizedBox(),
              Divider(color: app_colors.grey),
              Divider(color: app_colors.grey),
            ]),
          ]),
      Table(
          columnWidths: const <int, TableColumnWidth>{
            0: FlexColumnWidth(1),
            1: FlexColumnWidth(4),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: <TableRow>[
            TableRow(children: [
              THeader(
                  text: _translator.translateIfExists("FR"),
                  color: app_colors.black),
              TCell(text: inverterMeasurements.m013, color: app_colors.black),
            ]),
          ])
    ]);
  }

  Widget getThermometer(String? temperatureText) {
    return temperatureText != null
        ? Thermometer(
            title: _translator.translateIfExists('MEAS_AMB_TEMP'),
            maximum: 70,
            temperatureValue: double.parse(
                temperatureText.substring(0, temperatureText.indexOf(" "))),
            temperatureText: temperatureText)
        : const SizedBox.shrink();
  }
}
