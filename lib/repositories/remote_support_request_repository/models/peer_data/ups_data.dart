import 'dart:typed_data';
import '../../utils.dart' as utils;
import 'data.dart';

class UpsData implements Data {
  UpsData({
    required this.states,
    required this.alarms,
    required this.measurements,
    required this.isBatteryPresent,
    required this.isBypassPresent,
  });

  final Uint8List states;
  final Uint8List alarms;
  final Uint8List measurements;
  final bool isBatteryPresent;
  final bool isBypassPresent;

  @override
  Map<String, dynamic> toJson() => {
        'states': utils.uInt8ListToString(states),
        'alarms': utils.uInt8ListToString(alarms),
        'measurements': utils.uInt8ListToString(measurements),
        'isBatteryPresent': isBatteryPresent,
        'isBypassPresent': isBypassPresent,
      };
}
