import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../config/colors.dart' as app_colors;
import '../../../repositories/modbus_data_repository/models/modbus_data_manager/synoptic/synoptic.dart';
import '../../../utils/translator.dart';
import '../config/screen_size.dart';
import '../../../widgets/custom_text/custom_text.dart';
import '../../measurements/widgets/thermometer.dart';
import 'lines/h_line_painter.dart';
import 'lines/arrow_painter.dart';
import 'lines/h_arrow_painter.dart';
import 'lines/h_battery_painter.dart';
import 'lines/on_mnt_byp_line.dart';
import 'lines/vd_line_painter.dart';
import 'lines/vu_line_painter.dart';

const double _strokeWidth = 3;

Translator _translator = Translator();

Widget getSynopticPortrait(BuildContext context, Synoptic synoptic) {
  return Container(
      margin: EdgeInsets.only(top: 5.0.h),
      child: Row(children: [
        SizedBox(
            width: 50.0.w,
            child: Column(children: [
              _getBatteryOrBackupTime(
                  synoptic.battery, synoptic.m022, synoptic.m024),
              SizedBox(height: 5.0.h),
              _getUpsTemperature(context, synoptic.m015)
            ])),
        SizedBox(
          width: 1.0.w,
          height: 80.0.w,
          child: const VerticalDivider(
            color: app_colors.lightGrey,
          ),
        ),
        SizedBox(
            width: 49.0.w,
            child: Column(children: [
              _getLoad(synoptic.load, synoptic.m000, synoptic.m005)
            ]))
      ]));
}

Widget _getLoad(AssetImage? load, String? outputLoadRate, String? outputKV) {
  return load != null
      ? Column(children: [
          _labelText(_translator.translateIfExists("LOAD", capitalize: false)),
          const SizedBox(height: 10),
          Container(
            width: 35.0.w,
            height: 30.0.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              image: DecorationImage(image: load, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(height: 10),
          if (outputLoadRate != null)
            CustomText(outputLoadRate, 13.0.sp, 11.0.sp),
          const SizedBox(height: 5),
          if (outputKV != null) CustomText(outputKV, 13.0.sp, 11.0.sp)
        ])
      : const SizedBox.shrink();
}

Widget _getBatteryOrBackupTime(
    AssetImage? battery, String? batteryCapacity, String? batteryBackupTime) {
  return battery != null
      ? batteryBackupTime != null
          ? Column(children: [
              _labelText(_translator.translateIfExists("BATTERY_BACKUP_TIME",
                  capitalize: false)),
              const SizedBox(height: 10),
              CustomText(batteryBackupTime, 20.0.sp, 18.0.sp),
              const SizedBox(height: 10),
              CustomText(
                  _translator.translateIfExists("REMAINING_TIME",
                      capitalize: false),
                  13.0.sp,
                  11.0.sp)
            ])
          : Column(children: [
              _labelText(_translator.translateIfExists("BATTERY_CAPACITY",
                  capitalize: false)),
              if (SizerUtil.deviceType == DeviceType.tablet)
                const SizedBox(height: 10),
              Container(
                width: 23.0.w,
                height: 9.0.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  image: DecorationImage(image: battery, fit: BoxFit.contain),
                ),
              ),
              if (SizerUtil.deviceType == DeviceType.tablet)
                const SizedBox(height: 10),
              if (batteryCapacity != null)
                CustomText(batteryCapacity, 13.0.sp, 11.0.sp)
            ])
      : const SizedBox.shrink();
}

Widget _labelText(String text) {
  return CustomText(text, 12.0.sp, 10.0.sp, bold: true);
}

Widget _getUpsTemperature(BuildContext context, String? temperature) {
  return temperature != null
      ? SizedBox(
          height: 50.0.w,
          child: Thermometer(
              title: _translator.translateIfExists("UPS_TEMPERATURE",
                  capitalize: false),
              maximum: 70,
              interval: 10,
              temperatureValue: double.parse(
                  temperature.substring(0, temperature.indexOf(" "))),
              temperatureText: temperature,
              titleFontSize: MediaQuery.of(context).orientation == Orientation.portrait
                  ? 12.0.sp
                  : 10.0.sp))
      : const SizedBox.shrink();
}

Widget getSynopticLandscape(Synoptic synoptic) {
  return Stack(children: [
    if (synoptic.maint != null)
      Container(
        margin: const EdgeInsets.only(left: 50),
        width: 12.0.w,
        height: 5.0.h,
        decoration: BoxDecoration(
          image: DecorationImage(image: synoptic.maint!, fit: BoxFit.fitWidth),
        ),
      ),
    Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: _getTopLine(synoptic),
              ),
              Container(
                child: _getBottomLine(synoptic),
              ),
            ]),
        SizedBox(
          height: SizeConfig.safeBlockVertical * 5,
          width: SizeConfig.safeVBlocHorizontal * 6,
          child: CustomPaint(
            foregroundPainter: HArrowPainter(
                _strokeWidth,
                synoptic.onMntByp == null
                    ? synoptic.output
                    : synoptic.onMntByp!,
                synoptic.onMntByp == null ? false : true),
          ),
        ),
        if (synoptic.load != null)
          Container(
            width: SizeConfig.safeVBlocHorizontal * 8,
            height: SizeConfig.safeBlockVertical * 40,
            decoration: BoxDecoration(
              image: DecorationImage(image: synoptic.load!, fit: BoxFit.fill),
            ),
          ),
        if (synoptic.m000 != null)
          CustomText(synoptic.m000!, 13.0.sp, 13.0.sp, bold: true),
      ],
    )
  ]);
}

Widget _getTopLine(Synoptic synoptic) {
  return Row(
    mainAxisSize: MainAxisSize.max,
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      if (synoptic.noBypass)
        SizedBox(height: SizeConfig.safeBlockVertical * 33, child: null),

      if (!synoptic.noBypass)
        Container(
          height: SizeConfig.safeBlockVertical * 4,
          width: SizeConfig.safeVBlocHorizontal * 3,
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage(
                    "assets/images/dashboard/synoptic/input_output/INPUT.png"),
                fit: BoxFit.fill),
          ),
        ),

      //noMntByp = false && noBypass = false
      if (!synoptic.noBypass && synoptic.onMntByp != null)
        SizedBox(
          width: SizeConfig.safeVBlocHorizontal * 10,
          height: SizeConfig.safeBlockVertical * 20,
          child: CustomPaint(
            foregroundPainter: OnMntBypLine(_strokeWidth, synoptic.onMntByp!),
          ),
        ),
      if (!synoptic.noBypass && synoptic.onMntByp != null)
        SizedBox(
            width: SizeConfig.safeVBlocHorizontal * 40,
            height: SizeConfig.safeBlockVertical * 20,
            child: CustomPaint(
              foregroundPainter: HLinePainter(_strokeWidth, synoptic.bypInput),
            )),
      if (!synoptic.noBypass &&
          synoptic.onMntByp != null &&
          synoptic.bypass != null)
        Container(
          height: SizeConfig.safeBlockVertical * 4,
          width: SizeConfig.safeVBlocHorizontal * 8,
          decoration: BoxDecoration(
            image: DecorationImage(image: synoptic.bypass!, fit: BoxFit.fill),
          ),
        ),
      if (!synoptic.noBypass && synoptic.onMntByp != null)
        SizedBox(
            width: SizeConfig.safeVBlocHorizontal * 6,
            height: SizeConfig.safeBlockVertical * 35,
            child: CustomPaint(
              foregroundPainter: VULinePainter(
                  _strokeWidth,
                  synoptic.bypOutput,
                  synoptic.bypOutput == app_colors.mediumGrey
                      ? null
                      : synoptic.bypOutput),
            )),

      //noMntByp = true && noBypass = false
      if (!synoptic.noBypass && synoptic.onMntByp == null)
        SizedBox(
          width: SizeConfig.safeVBlocHorizontal * 50,
          height: SizeConfig.safeBlockVertical * 20,
          child: CustomPaint(
            foregroundPainter: ArrowPainter(_strokeWidth, synoptic.bypInput),
          ),
        ),
      if (!synoptic.noBypass && synoptic.onMntByp == null)
        Container(
          height: SizeConfig.safeBlockVertical * 4,
          width: SizeConfig.safeVBlocHorizontal * 8,
          decoration: BoxDecoration(
            image: synoptic.bypass != null
                ? DecorationImage(image: synoptic.bypass!, fit: BoxFit.fill)
                : null,
          ),
        ),
      if (!synoptic.noBypass && synoptic.onMntByp == null)
        SizedBox(
          width: SizeConfig.safeVBlocHorizontal * 6,
          height: SizeConfig.safeBlockVertical * 35,
          child: CustomPaint(
            foregroundPainter: VULinePainter(
                _strokeWidth,
                synoptic.bypOutput,
                synoptic.bypOutput == app_colors.mediumGrey
                    ? null
                    : synoptic.bypOutput),
          ),
        )
    ],
  );
}

Widget _getBottomLine(Synoptic synoptic) {
  return Row(
    children: [
      Container(
        height: SizeConfig.safeBlockVertical * 4,
        width: SizeConfig.safeVBlocHorizontal * 3,
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage(
                  "assets/images/dashboard/synoptic/input_output/INPUT.png"),
              fit: BoxFit.fill),
        ),
      ),
      SizedBox(
        width: SizeConfig.safeVBlocHorizontal * 8,
        child: CustomPaint(
          foregroundPainter:
              HLinePainter(_strokeWidth, synoptic.rectifierInput),
        ),
      ),
      Container(
        height: SizeConfig.safeBlockVertical * 4,
        width: SizeConfig.safeVBlocHorizontal * 8,
        decoration: BoxDecoration(
          image: DecorationImage(image: synoptic.rectifier, fit: BoxFit.fill),
        ),
      ),
      SizedBox(
        height: SizeConfig.safeBlockVertical * 35,
        width: SizeConfig.safeVBlocHorizontal * 10,
        child: CustomPaint(
          painter: HBatteryLinePainter(
              _strokeWidth,
              synoptic.dcBus,
              synoptic.dcBus == app_colors.mediumGrey ? null : synoptic.dcBus,
              synoptic.dcInput == app_colors.mediumGrey
                  ? null
                  : synoptic.dcInput,
              synoptic.dcInput,
              synoptic.dcOutput == app_colors.mediumGrey
                  ? null
                  : synoptic.dcOutput,
              synoptic.dcOutput),
        ),
      ),
      Container(
          alignment: Alignment.topCenter,
          height: SizeConfig.safeBlockVertical * 35,
          width: SizeConfig.safeVBlocHorizontal * 20,
          child: _getBattery(synoptic.battery,
              synoptic.chargeOrDischargeBattery, synoptic.m022, synoptic.m024)),
      SizedBox(
        width: SizeConfig.safeVBlocHorizontal * 4,
        child: CustomPaint(
          foregroundPainter: HLinePainter(_strokeWidth, synoptic.invInput),
        ),
      ),
      Container(
        height: SizeConfig.safeBlockVertical * 4,
        width: SizeConfig.safeVBlocHorizontal * 8,
        decoration: BoxDecoration(
          image: DecorationImage(image: synoptic.inverter, fit: BoxFit.fill),
        ),
      ),
      SizedBox(
        width: SizeConfig.safeVBlocHorizontal * 6,
        height: SizeConfig.safeBlockVertical * 35,
        child: CustomPaint(
          foregroundPainter: VDLinePainter(
              _strokeWidth,
              synoptic.invOutput,
              synoptic.invOutput == app_colors.mediumGrey
                  ? null
                  : synoptic.invOutput),
        ),
      )
    ],
  );
}

Widget? _getBattery(AssetImage? battery, AssetImage? chargeOrDischargeBattery,
    String? batCapacity, String? batBackUpTime) {
  return battery != null
      ? Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    margin: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                    alignment: Alignment.topLeft,
                    child: Container(
                      width: SizeConfig.safeVBlocHorizontal * 1.5,
                      height: SizeConfig.safeBlockVertical * 3,
                      decoration: BoxDecoration(
                        image: chargeOrDischargeBattery != null
                            ? DecorationImage(
                                image: chargeOrDischargeBattery,
                                fit: BoxFit.fill)
                            : null,
                      ),
                    )),
                CustomText(
                    batCapacity ?? batBackUpTime ?? "",
                    SizeConfig.safeVBlocHorizontal * 2.3,
                    SizeConfig.safeVBlocHorizontal * 2.3,
                    bold: true)
              ],
            ),
            Container(
              height: SizeConfig.safeBlockVertical * 10,
              width: SizeConfig.safeVBlocHorizontal * 10,
              decoration: BoxDecoration(
                  image: DecorationImage(image: battery, fit: BoxFit.fill)),
            )
          ],
        )
      : null;
}
