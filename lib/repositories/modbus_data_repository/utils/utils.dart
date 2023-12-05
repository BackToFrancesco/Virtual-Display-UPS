import 'dart:typed_data';

String uIntTo8bitString(int number) {
  return number.toRadixString(2).padLeft(8, '0');
}

final _pattern = RegExp(r'(?:0x)?(\d+)');

int binaryStringToUInt8(String binaryString) =>
    int.parse(_pattern.firstMatch(binaryString)!.group(1)!, radix: 2);

Uint8List uInt16ToTwoUInt8(int uInt16) {
  return Uint8List.fromList(
      [extractByteFromUInt16(uInt16, 0), extractByteFromUInt16(uInt16, 1)]);
}

int twoUInt8ToOneUInt16(int uInt8A, int uInt8B) {
  return Uint8List.fromList([uInt8A, uInt8B]).buffer.asByteData().getUint16(0);
}

//Estrae da dx, cioè dal byte meno significativo
int extractByteFromUInt16(int uInt16, int offset) {
  return Uint16List.fromList([uInt16]).buffer.asByteData().getUint8(offset);
}

//Estrae da dx, cioè dal byte meno significativo
int extractByteFromInt16(int int16, int offset) {
  return Int16List.fromList([int16]).buffer.asByteData().getInt8(offset);
}

int intToUInt(int number) {
  return Uint16List.fromList([number])[0];
}

String fillStringPaddingLeft(String toFill, int width, String padding) {
  return toFill.padLeft(width, padding);
}
