import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class LinearIndicator extends StatelessWidget {
  const LinearIndicator(
      {Key? key,
      required this.maximum,
      required this.value,
      required this.color})
      : super(key: key);
  final double maximum;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SfLinearGauge(
        minimum: 0,
        maximum: maximum,
        showTicks: false,
        showLabels: false,
        ranges: [
          LinearGaugeRange(
            color: color,
            startValue: 0,
            endValue: value,
          ),
        ]);
  }
}
