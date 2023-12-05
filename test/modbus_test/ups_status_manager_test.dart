import 'package:flutter_test/flutter_test.dart';
import 'package:virtual_display/repositories/modbus_data_repository/models/modbus_data_manager/managers/alarms_manager.dart';
import 'package:virtual_display/repositories/modbus_data_repository/models/modbus_data_manager/managers/measurements_manager.dart';
import 'package:virtual_display/repositories/modbus_data_repository/models/modbus_data_manager/managers/states_manager.dart';
import 'package:virtual_display/repositories/modbus_data_repository/models/modbus_data_manager/managers/ups_status_manager.dart';
import 'package:virtual_display/utils/translator.dart';

import '../modbus_helper.dart';

void main() async{
  TestWidgetsFlutterBinding.ensureInitialized();
  await Translator.init();

  StatesManager statesManager = StatesManager();
  statesManager.states = ExpectedState.states;

  AlarmsManager alarmsManager = AlarmsManager();
  alarmsManager.alarms = ExpectedAlarms.alarms;
  
  MeasurementsManager measurementsManager = MeasurementsManager();
  measurementsManager.measurements = ExpectedMeasurements.measurments;
  measurementsManager.mcmt = ExpectedMeasurements.mcmt;
  measurementsManager.measurementsFormat = ExpectedMeasurements.measurementsFormat;

  UpsStatusManager upsStatusManager = UpsStatusManager(statesManager, alarmsManager, measurementsManager);

  test('get stateManager, alarmManager and upsStatusManager return the expected stateManager, alarmManager and upsStatusManager after the update status', () async{
    upsStatusManager.updateUpsStatus();
    expect(upsStatusManager.statesManager, statesManager);
    expect(upsStatusManager.alarmManager, alarmsManager);
    expect(upsStatusManager.measurementsManager, measurementsManager);
    await upsStatusManager.dispose();
  });
}