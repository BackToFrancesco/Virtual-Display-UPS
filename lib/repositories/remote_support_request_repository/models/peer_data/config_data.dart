import 'dart:typed_data';
import '../../utils.dart' as utils;
import 'data.dart';

class ConfigData implements Data {
  ConfigData({
    required this.mcmt,
    required this.format,
  });

  final Uint8List mcmt;
  final int format;

  @override
  Map<String, dynamic> toJson() => {
        'mcmt': utils.uInt8ListToString(mcmt),
        'format': format,
      };
}
