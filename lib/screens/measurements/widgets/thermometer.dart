import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import '../../../config/colors.dart' as app_colors;
import '../../../widgets/custom_text/custom_text.dart';

class Thermometer extends StatelessWidget {
  const Thermometer(
      {Key? key,
      this.interval = 5,
      required this.title,
      required this.maximum,
      required this.temperatureValue,
      required this.temperatureText,
      this.titleFontSize})
      : super(key: key);
  final double interval;
  final String title;
  final double maximum;
  final double? temperatureValue;
  final String? temperatureText;
  final double? titleFontSize;

  @override
  Widget build(BuildContext context) {
    return SfRadialGauge(
      title: GaugeTitle(
          text: title,
          textStyle: TextStyle(
              fontSize: titleFontSize ??
                  (MediaQuery.of(context).orientation == Orientation.portrait
                      ? 15.0.sp
                      : 13.0.sp),
              fontWeight: FontWeight.bold)),
      axes: <RadialAxis>[
        RadialAxis(
          ticksPosition: ElementsPosition.outside,
          labelsPosition: ElementsPosition.outside,
          minorTicksPerInterval: 5,
          axisLineStyle: const AxisLineStyle(
            thicknessUnit: GaugeSizeUnit.factor,
            thickness: 0.1,
          ),
          axisLabelStyle: GaugeTextStyle(
              fontSize: MediaQuery.of(context).orientation == Orientation.portrait
                  ? 15.0.sp
                  : 13.0.sp),
          radiusFactor: 0.97,
          majorTickStyle: const MajorTickStyle(
              length: 0.1, thickness: 2, lengthUnit: GaugeSizeUnit.factor),
          minorTickStyle: const MinorTickStyle(
              length: 0.05, thickness: 1.5, lengthUnit: GaugeSizeUnit.factor),
          minimum: 0,
          maximum: maximum,
          interval: interval,
          startAngle: 145,
          endAngle: 35,
          ranges: <GaugeRange>[
            GaugeRange(
                startValue: 0,
                endValue: 70,
                startWidth: 0.1,
                sizeUnit: GaugeSizeUnit.factor,
                endWidth: 0.1,
                gradient: const SweepGradient(stops: <double>[
                  0.2,
                  0.5,
                  0.75
                ], colors: <Color>[
                  app_colors.mediumGreen,
                  app_colors.lightYellow,
                  app_colors.mediumRed
                ]))
          ],
          pointers: <GaugePointer>[
            NeedlePointer(
                value: temperatureValue ?? 0,
                needleColor: app_colors.black,
                tailStyle: const TailStyle(
                    length: 0.18,
                    width: 8,
                    color: app_colors.black,
                    lengthUnit: GaugeSizeUnit.factor),
                needleLength: 0.68,
                needleStartWidth: 1,
                needleEndWidth: 8,
                knobStyle: const KnobStyle(
                    knobRadius: 0.07,
                    color: app_colors.white,
                    borderWidth: 0.05,
                    borderColor: app_colors.black),
                lengthUnit: GaugeSizeUnit.factor)
          ],
          annotations: <GaugeAnnotation>[
            if (temperatureText != null)
              GaugeAnnotation(
                  widget: CustomText(temperatureText!, 14.0.sp, 12.0.sp,
                      bold: true),
                  positionFactor: 0.5,
                  angle: 90)
          ],
        ),
      ],
    );
  }
}
