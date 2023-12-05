import 'package:flutter_test/flutter_test.dart';
import 'package:virtual_display/repositories/modbus_data_repository/models/modbus_data_manager/modbus_data_manager.dart';
import 'package:virtual_display/utils/translator.dart';

import '../modbus_helper.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await Translator.init();

  ModbusDataManager modbusDataManager = ModbusDataManager();
  modbusDataManager.states = ExpectedState.states;
  modbusDataManager.alarms = ExpectedAlarms.alarms;
  modbusDataManager.measurements = ExpectedMeasurements.measurments;
  modbusDataManager.mcmt = ExpectedMeasurements.mcmt;
  modbusDataManager.measurementsFormat =
      ExpectedMeasurements.measurementsFormat;
  modbusDataManager.t009 = ExpectedDataManagerMeasure.t009;
  modbusDataManager.t010 = ExpectedDataManagerMeasure.t010;

  setUp((() {
    modbusDataManager.updateUpsStatus();
    modbusDataManager.updateSynoptic();
  }));

  tearDown((()async {
    await modbusDataManager.dispose();
  }));

  test('get states returns the expected states', () {
    expect(modbusDataManager.states, ExpectedState.states);
  });

  test('get alarms returns the expected alarms', () {
    expect(modbusDataManager.alarms, ExpectedAlarms.alarms);
  });

  test('get measurements returns the expected measurements', () {
    expect(modbusDataManager.measurements, ExpectedMeasurements.measurments);
  });

  test('get mcmt returns the expected mcmt', () {
    expect(modbusDataManager.mcmt, ExpectedMeasurements.mcmt);
  });

  test('get measurementsFormat returns the expected measurements format', () {
    expect(modbusDataManager.measurementsFormat,
        ExpectedMeasurements.measurementsFormat);
  });

  test('get measurementsFormatValue returns the expected measurements format value', () {
    expect(modbusDataManager.measurementsFormatValue,
        ExpectedMeasurements.measurementsFormatValue);
  });

  test('get t009 returns the expected t009 measure', () {
    expect(modbusDataManager.t009, ExpectedDataManagerMeasure.t009);
  });

  test('get t010 returns the expected t010 measure', () {
    expect(modbusDataManager.t010,
        ExpectedDataManagerMeasure.t010);
  });

  test('getStates returns the expected states', () {
    expect(modbusDataManager.getStates(), ExpectedState.getState);
  });

  test('getStatesValueByIndex returns the expected states values', () {
    for (var index = 0; index < 128; index++) {
      expect(modbusDataManager.getStateValueByIndex(index), ExpectedState.getStateValueByIndex[index]);
    }
  });

  test('getAlarms returns the expected alarms', () {
    expect(modbusDataManager.getAlarms(), ExpectedAlarms.getAlarms);
  });

  test('getAlarmsByIndex returns the expected alarms list', () {
    for (var index = 0; index < 128; index++) {
      expect(modbusDataManager.getAlarmByIndex(index), ExpectedAlarms.getAllarmByIndex[index]);
    }
  });

  test('getBatteryMeasurements returns the expected battery measurements', () {
    expect(modbusDataManager.getBatteryMeasurements(), ExpectedMeasurements.batteryMeasurements);
  });

  test('getBypassMeasurements returns the expected bypass measurements', () {
    expect(modbusDataManager.getBypassMeasurements(), ExpectedMeasurements.bypassMeasurements);
  });

  test('getInputMeasurements returns the expected input measurements', () {
    expect(modbusDataManager.getInputMeasurements(), ExpectedMeasurements.inputMeasurements);
  });

  test('getInverterMeasurements returns the expected inverter measurements', () {
    expect(modbusDataManager.getInverterMeasurements(), ExpectedMeasurements.inverterMeasurements);
  });

  test('getOutputMeasurements returns the expected output measurements', () {
    expect(modbusDataManager.getOutputMeasurements(), ExpectedMeasurements.outputMeasurements);
  });

}
