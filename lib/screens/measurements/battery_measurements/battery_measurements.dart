import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../config/app_bar.dart';
import '../../../repositories/modbus_data_repository/models/modbus_data_manager/component_measurements/battery_measurements.dart';
import '../../../widgets/custom_text/custom_text.dart';
import '../../../widgets/status_bar/status_bar.dart';
import '../../../blocs/ups_connection_handler_bloc/ups_connection_handler_bloc.dart';
import '../../../repositories/modbus_data_repository/modbus_repository.dart';
import '../../../repositories/modbus_data_repository/models/modbus_connection_manager/modbus_connection_manager.dart';
import '../../../utils/translator.dart';
import '../../../widgets/dialog/dialog_factory.dart';
import '../../../widgets/navigation_drawer/navigation_drawer.dart';
import '../../../widgets/ups_connections_status/ups_connection_status.dart';
import '../widgets/thermometer.dart';
import 'bloc/battery_measurements_bloc.dart';

bool _isMenuOpened = false;

class BatteryMeasurementsScreen extends StatelessWidget {
  const BatteryMeasurementsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BatteryMeasurementsBloc>(
      create: (BuildContext ctx) => BatteryMeasurementsBloc(
          modbusDataRepository: context.read<ModbusRepository>())
        ..add(const Init()),
      child: BatteryMeasurementsPage(),
    );
  }
}

class BatteryMeasurementsPage extends StatelessWidget {
  BatteryMeasurementsPage({Key? key}) : super(key: key);

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
                  drawer: NavigationDrawer(pageNumber: 5),
                  appBar: CustomAppBar(
                      title:
                          _translator.translateIfExists("BATTERIES_MEASURES")),
                  body: Column(
                    children: [
                      getStatusBar(),
                      const UpsConnectionStatusRealTime(),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              MediaQuery.of(context).orientation == Orientation.portrait ? contentBuilderPortrait()
                                  : contentBuilderLandscape()
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )));
  }

  Widget getStatusBar() {
    return BlocBuilder<BatteryMeasurementsBloc, BatteryMeasurementsState>(
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
    return BlocBuilder<BatteryMeasurementsBloc, BatteryMeasurementsState>(
        buildWhen: (previous, current) =>
            previous.batteryMeasurements != current.batteryMeasurements,
        builder: (context, state) {
          if (state.batteryMeasurements != null) {
            if (state.batteryMeasurements!.batPresent) {
              return portraitWidget(state.batteryMeasurements);
            }
            return Center(
                child: CustomText(
                    _translator.translateIfExists("BATTERY_NOT_PRESENT"),
                    15.0.sp,
                    13.0.sp));
          }
          return const SizedBox.shrink();
        });
  }

  Widget contentBuilderLandscape() {
    return BlocBuilder<BatteryMeasurementsBloc, BatteryMeasurementsState>(
        buildWhen: (previous, current) =>
            previous.batteryMeasurements != current.batteryMeasurements,
        builder: (context, state) {
          if (state.batteryMeasurements != null) {
            if (state.batteryMeasurements!.batPresent) {
              return landscapeWidget(state.batteryMeasurements);
            }
            return Center(
                child: CustomText(
                    _translator.translateIfExists("BATTERY_NOT_PRESENT"),
                    15.0.sp,
                    13.0.sp));
          }
          return const SizedBox.shrink();
        });
  }

  Widget portraitWidget(BatteryMeasurements? batteryMeasurements) {
    return Container(
        margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
        child: Column(children: [
          Row(children: [
            SizedBox(
                width: 30.0.w, child: getFirstColumn(batteryMeasurements)),
            SizedBox(
                width: 70.0.w, child: getSecondColumn(batteryMeasurements)),
          ]),
          SizedBox(height: 2.0.h),
          Row(children: [
            SizedBox(
                width: 50.0.w,
                height: 50.0.w,
                child: getThermometer(
                    _translator.translateIfExists("MEAS_BATTERY_TEMP_INST"),
                    batteryMeasurements!.m026)),
            SizedBox(
                width: 50.0.w,
                height: 50.0.w,
                child: getThermometer(
                    _translator.translateIfExists("MEAS_BATTERY_TEMP_AVG"),
                    batteryMeasurements.m027)),
          ])
        ]));
  }

  Widget landscapeWidget(BatteryMeasurements? batteryMeasurements) {
    return Container(
        margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            SizedBox(
                width: 15.0.w, child: getFirstColumn(batteryMeasurements)),
            SizedBox(
                width: 45.0.w, child: getSecondColumn(batteryMeasurements)),
            SizedBox(
                width: 40.0.w,
                child: Column(children: [
                  SizedBox(
                      width: 40.0.w,
                      height: 40.0.w,
                      child: getThermometer(
                          _translator
                              .translateIfExists("MEAS_BATTERY_TEMP_INST"),
                          batteryMeasurements!.m026)),
                  SizedBox(
                      width: 40.0.w,
                      height: 40.0.w,
                      child: getThermometer(
                          _translator
                              .translateIfExists("MEAS_BATTERY_TEMP_AVG"),
                          batteryMeasurements.m027)),
                ]))
          ]),
        ]));
  }

  Widget getFirstColumn(BatteryMeasurements? batteryMeasurements) {
    return Column(children: [
      labelText(_translator.translateIfExists('MEAS_BATTERY_BAT_PLUS')),
      valueText(batteryMeasurements!.m016),
      const SizedBox(height: 15),
      labelText(_translator.translateIfExists('MEAS_BATTERY_BAT_MINUS')),
      valueText(batteryMeasurements.m017),
      const SizedBox(height: 15),
      labelText(_translator.translateIfExists('MEAS_BATTERY_BAT_PLUS')),
      valueText(batteryMeasurements.m018),
      const SizedBox(height: 15),
      labelText(_translator.translateIfExists('MEAS_BATTERY_BAT_MINUS')),
      valueText(batteryMeasurements.m019),
    ]);
  }

  Widget getSecondColumn(BatteryMeasurements? batteryMeasurements) {
    return Column(children: [
      labelText(_translator.translateIfExists('MEAS_BATTERY_BACKUPTIME')),
      valueText(batteryMeasurements!.m024),
      const SizedBox(height: 15),
      labelText(_translator.translateIfExists('MEAS_CAPACITY')),
      valueText((batteryMeasurements.m022 ?? "") +
          "   " +
          (batteryMeasurements.m023 ?? "")),
      Container(
        width: 23.0.w,
        height: 9.0.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          image:
              DecorationImage(image: getBatteryImage(55), fit: BoxFit.contain),
        ),
      ),
      const SizedBox(height: 15),
      labelText(_translator.translateIfExists('MEAS_BATTERY_TIMEONBAT')),
      valueText(batteryMeasurements.m025),
    ]);
  }

  Widget getThermometer(String title, String? temperatureText) {
    return temperatureText != null
        ? Thermometer(
            title: title,
            maximum: 70,
            interval: 10,
            temperatureValue: double.parse(
                temperatureText.substring(0, temperatureText.indexOf(" "))),
            temperatureText: temperatureText)
        : const SizedBox.shrink();
  }

  Widget labelText(String text) {
    return CustomText(text, 15.0.sp, 13.0.sp, bold: true);
  }

  Widget valueText(String? text) {
    return text != null
        ? CustomText(text, 14.0.sp, 12.0.sp)
        : const SizedBox.shrink();
  }

  AssetImage getBatteryImage(int percentValue) {
    if (percentValue <= 0) {
      return const AssetImage(
          "assets/images/dashboard/synoptic/battery/BAT_NORMAL.png");
    }
    if (percentValue > 0 && percentValue <= 5) {
      return const AssetImage("assets/images/dashboard/synoptic/battery/5.png");
    }
    if (percentValue > 5 && percentValue <= 10) {
      return const AssetImage(
          "assets/images/dashboard/synoptic/battery/10.png");
    }
    if (percentValue > 10 && percentValue <= 15) {
      return const AssetImage(
          "assets/images/dashboard/synoptic/battery/15.png");
    }
    if (percentValue > 15 && percentValue <= 20) {
      return const AssetImage(
          "assets/images/dashboard/synoptic/battery/20.png");
    }
    if (percentValue > 20 && percentValue <= 25) {
      return const AssetImage(
          "assets/images/dashboard/synoptic/battery/25.png");
    }
    if (percentValue > 25 && percentValue <= 30) {
      return const AssetImage(
          "assets/images/dashboard/synoptic/battery/30.png");
    }
    if (percentValue > 30 && percentValue <= 35) {
      return const AssetImage(
          "assets/images/dashboard/synoptic/battery/35.png");
    }
    if (percentValue > 35 && percentValue <= 40) {
      return const AssetImage(
          "assets/images/dashboard/synoptic/battery/40.png");
    }
    if (percentValue > 40 && percentValue <= 45) {
      return const AssetImage(
          "assets/images/dashboard/synoptic/battery/45.png");
    }
    if (percentValue > 45 && percentValue <= 50) {
      return const AssetImage(
          "assets/images/dashboard/synoptic/battery/50.png");
    }
    if (percentValue > 50 && percentValue <= 55) {
      return const AssetImage(
          "assets/images/dashboard/synoptic/battery/55.png");
    }
    if (percentValue > 55 && percentValue <= 60) {
      return const AssetImage(
          "assets/images/dashboard/synoptic/battery/60.png");
    }
    if (percentValue > 60 && percentValue <= 65) {
      return const AssetImage(
          "assets/images/dashboard/synoptic/battery/65.png");
    }
    if (percentValue > 65 && percentValue <= 70) {
      return const AssetImage(
          "assets/images/dashboard/synoptic/battery/70.png");
    }
    if (percentValue > 70 && percentValue <= 75) {
      return const AssetImage(
          "assets/images/dashboard/synoptic/battery/75.png");
    }
    if (percentValue > 75 && percentValue <= 80) {
      return const AssetImage(
          "assets/images/dashboard/synoptic/battery/80.png");
    }
    if (percentValue > 80 && percentValue <= 85) {
      return const AssetImage(
          "assets/images/dashboard/synoptic/battery/85.png");
    }
    if (percentValue > 85 && percentValue <= 90) {
      return const AssetImage(
          "assets/images/dashboard/synoptic/battery/90.png");
    }
    if (percentValue > 90 && percentValue <= 95) {
      return const AssetImage(
          "assets/images/dashboard/synoptic/battery/95.png");
    }
    return const AssetImage("assets/images/dashboard/synoptic/battery/100.png");
  }
}
