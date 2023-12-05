import 'dart:typed_data';
import '../../../../../utils/translator.dart';
import '../../../utils/utils.dart' as utils;

class AlarmsManager {
  late Uint8List _alarms;
  late String _alarmsBinary;
  final Translator _translator = Translator();

  set alarms(Uint8List alarms) {
    String alarmsBinary = "";
    for (var i = 1; i < alarms.length; i++) {
      alarmsBinary += utils.uIntTo8bitString(alarms[i]);
    }
    _alarms = alarms;
    _alarmsBinary = alarmsBinary;
  }

  Uint8List get alarms => _alarms;

  List<String> getAlarms() {
    List<String> temp = [];
    for (int i = 0; i < _alarmsBinary.length; i++) {
      if (_alarmsBinary[i].compareTo("1") == 0) {
        temp.add("A" +
            utils.fillStringPaddingLeft(i.toString(), 3, "0") +
            ": " +
            _translator.translateIfExists(
                "A" + utils.fillStringPaddingLeft(i.toString(), 3, "0")));
      }
    }
    return temp;
  }

  int getAlarmByIndex(int index) {
    return int.parse(_alarmsBinary[index]);
  }
}
