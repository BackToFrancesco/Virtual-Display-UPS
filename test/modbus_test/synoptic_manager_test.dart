import 'package:flutter_test/flutter_test.dart';
import 'package:virtual_display/repositories/modbus_data_repository/models/modbus_data_manager/managers/alarms_manager.dart';
import 'package:virtual_display/repositories/modbus_data_repository/models/modbus_data_manager/managers/measurements_manager.dart';
import 'package:virtual_display/repositories/modbus_data_repository/models/modbus_data_manager/managers/states_manager.dart';
import 'package:virtual_display/repositories/modbus_data_repository/models/modbus_data_manager/managers/synoptic_manager.dart';
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

  SynopticManager synopticManager = SynopticManager(statesManager, alarmsManager, measurementsManager);
  
  test('synopticManager returns the correct intances of stateManager, alarmsManager and measurementsManager after the update', () async{
    synopticManager.updateSynoptic(batPresent: true, dcPresent: true, noBypass: false, noMntByp: false);
    expect(synopticManager.statesManager, statesManager);
    expect(synopticManager.alarmsManager, alarmsManager);
    expect(synopticManager.measurementsManager, measurementsManager);
    await synopticManager.dispose();
  });

}