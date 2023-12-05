import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../config/app_bar.dart';
import '../../../widgets/status_bar/status_bar.dart';
import '../../../blocs/ups_connection_handler_bloc/ups_connection_handler_bloc.dart';
import '../../../config/colors.dart' as app_colors;
import '../../../repositories/modbus_data_repository/modbus_repository.dart';
import '../../../repositories/modbus_data_repository/models/modbus_connection_manager/modbus_connection_manager.dart';
import '../../../repositories/modbus_data_repository/models/modbus_data_manager/component_measurements/input_measurements.dart';
import '../../../utils/translator.dart';
import '../../../widgets/dialog/dialog_factory.dart';
import '../../../widgets/navigation_drawer/navigation_drawer.dart';
import '../../../widgets/ups_connections_status/ups_connection_status.dart';
import '../widgets/linear_indicator.dart';
import '../widgets/table_cell.dart';
import '../widgets/table_header.dart';
import 'bloc/input_measurements_bloc.dart';

bool _isMenuOpened = false;

class InputMeasurementsScreen extends StatelessWidget {
  const InputMeasurementsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<InputMeasurementsBloc>(
      create: (BuildContext ctx) => InputMeasurementsBloc(
          modbusDataRepository: context.read<ModbusRepository>())
        ..add(const Init()),
      child: InputMeasurementsPage(),
    );
  }
}

class InputMeasurementsPage extends StatelessWidget {
  InputMeasurementsPage({Key? key}) : super(key: key);

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
                  drawer: NavigationDrawer(pageNumber: 4),
                  appBar: CustomAppBar(
                      title: _translator.translateIfExists("INPUT_MEASURES")),
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
    return BlocBuilder<InputMeasurementsBloc, InputMeasurementsState>(
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
    return BlocBuilder<InputMeasurementsBloc, InputMeasurementsState>(
        buildWhen: (previous, current) =>
            previous.inputMeasurements != current.inputMeasurements,
        builder: (context, state) {
          if (state.inputMeasurements != null) {
            return portraitWidget(state.inputMeasurements);
          }
          return const SizedBox.shrink();
        });
  }

  Widget contentBuilderLandscape() {
    return BlocBuilder<InputMeasurementsBloc, InputMeasurementsState>(
        buildWhen: (previous, current) =>
            previous.inputMeasurements != current.inputMeasurements,
        builder: (context, state) {
          if (state.inputMeasurements != null) {
            return landscapeWidget(state.inputMeasurements);
          }
          return const SizedBox.shrink();
        });
  }

  Widget landscapeWidget(InputMeasurements? inputMeasurements) {
    return Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 40, 0),
        child: getTable(inputMeasurements, true));
  }

  Widget portraitWidget(InputMeasurements? inputMeasurements) {
    return Container(
        margin: const EdgeInsets.fromLTRB(20, 50, 20, 0),
        child: getTable(inputMeasurements, false));
  }

  Widget getTable(InputMeasurements? inputMeasurements, bool extended) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Table(
          columnWidths: <int, TableColumnWidth>{
            0: const FlexColumnWidth(1),
            1: const FlexColumnWidth(2),
            2: const FlexColumnWidth(2),
            3: const FlexColumnWidth(2),
            4: const FlexColumnWidth(2),
            if (extended) 5: const FlexColumnWidth(3),
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
                  text: inputMeasurements!.m032,
                  color: app_colors.mediumYellow),
              TCell(
                  text: inputMeasurements.m036, color: app_colors.mediumYellow),
              TCell(
                  text: inputMeasurements.m067, color: app_colors.mediumYellow),
              TCell(
                  text: inputMeasurements.m064, color: app_colors.mediumYellow),
              if (extended && inputMeasurements.m064 != null)
                LinearIndicator(
                    maximum: 100000,
                    value: double.parse(inputMeasurements.m064!),
                    color: app_colors.mediumYellow),
            ]),
            TableRow(children: [
              THeader(
                  text: _translator.translateIfExists("DIAG_L2"),
                  color: app_colors.blue),
              TCell(text: inputMeasurements.m033, color: app_colors.blue),
              TCell(text: inputMeasurements.m037, color: app_colors.blue),
              TCell(text: inputMeasurements.m068, color: app_colors.blue),
              TCell(text: inputMeasurements.m065, color: app_colors.blue),
              if (extended && inputMeasurements.m065 != null)
                LinearIndicator(
                    maximum: 100000,
                    value: double.parse(inputMeasurements.m065!),
                    color: app_colors.blue),
            ]),
            TableRow(children: [
              THeader(
                  text: _translator.translateIfExists("DIAG_L3"),
                  color: app_colors.purple),
              TCell(text: inputMeasurements.m034, color: app_colors.purple),
              TCell(text: inputMeasurements.m038, color: app_colors.purple),
              TCell(text: inputMeasurements.m069, color: app_colors.purple),
              TCell(text: inputMeasurements.m066, color: app_colors.purple),
              if (extended && inputMeasurements.m066 != null)
                LinearIndicator(
                    maximum: 100000,
                    value: double.parse(inputMeasurements.m066!),
                    color: app_colors.purple),
            ]),
            TableRow(children: [
              const SizedBox(),
              const Divider(color: app_colors.grey),
              const Divider(color: app_colors.grey),
              const Divider(color: app_colors.grey),
              const Divider(color: app_colors.grey),
              if (extended) const SizedBox()
            ])
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
              TCell(text: inputMeasurements.m035, color: app_colors.black),
              if (extended) const SizedBox(),
            ]),
          ]),
    ]);
  }
}
