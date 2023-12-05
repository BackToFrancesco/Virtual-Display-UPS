import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;

Future<Excel> getExcel(String fileName) async {
  ByteData data = await rootBundle.load(fileName);
  return compute(decode, data);
}

Future<Excel> decode(ByteData data) async {
  return Excel.decodeBytes(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
}

Sheet? getSheet(Excel excel, String sheetName) {
  return excel.tables[sheetName];
}
