import 'dart:typed_data';

String uInt8ListToString(Uint8List toConvert) {
  String converted = "";
  for (int i = 0; i < toConvert.length; i++) {
    converted += toConvert[i].toRadixString(16).padLeft(2, '0');
  }
  return converted;
}
