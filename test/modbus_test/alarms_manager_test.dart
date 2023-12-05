import 'package:flutter_test/flutter_test.dart';
import 'package:virtual_display/repositories/modbus_data_repository/models/modbus_data_manager/managers/alarms_manager.dart';
import 'package:virtual_display/utils/translator.dart';

import '../modbus_helper.dart';
void main() async{
  TestWidgetsFlutterBinding.ensureInitialized();
  
  await Translator.init();

  AlarmsManager alarmsManager = AlarmsManager();
  alarmsManager.alarms = ExpectedAlarms.alarms;
  test('set allarms sets correct allarms', () {
    expect(alarmsManager.alarms, ExpectedAlarms.alarms);
  });

  test('getAllarmByIndex returns the expected list of alarms', () {
    for (var index = 0; index < 128; index++) {
      expect(alarmsManager.getAlarmByIndex(index), ExpectedAlarms.getAllarmByIndex[index]);
    }
  });

  test('getAlarms returs the list of the expected alarms', () {
    expect(alarmsManager.getAlarms(), ExpectedAlarms.getAlarms);
  });
}