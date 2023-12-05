import 'package:flutter_test/flutter_test.dart';
import 'package:virtual_display/repositories/modbus_data_repository/models/modbus_data_manager/component_measurements/battery_measurements.dart';
import 'package:virtual_display/repositories/modbus_data_repository/models/modbus_data_manager/component_measurements/bypass_measurements.dart';
import 'package:virtual_display/repositories/modbus_data_repository/models/modbus_data_manager/component_measurements/input_measurements.dart';
import 'package:virtual_display/repositories/modbus_data_repository/models/modbus_data_manager/component_measurements/inverter_measurements.dart';
import 'package:virtual_display/repositories/modbus_data_repository/models/modbus_data_manager/component_measurements/output_measurements.dart';
import 'package:virtual_display/repositories/modbus_data_repository/models/modbus_data_manager/managers/measurements_manager.dart';
import 'package:virtual_display/utils/translator.dart';

import '../modbus_helper.dart';

void main() async{
  TestWidgetsFlutterBinding.ensureInitialized();
  await Translator.init();
  
  MeasurementsManager measurementsManager = MeasurementsManager();

  measurementsManager.measurements = ExpectedMeasurements.measurments;
  measurementsManager.mcmt = ExpectedMeasurements.mcmt;
  measurementsManager.measurementsFormat = ExpectedMeasurements.measurementsFormat;
  test('set measurements sets correct measurements', () {
    expect(measurementsManager.measurements, ExpectedMeasurements.measurments);
  });

  test('set mcmt sets the correct mcmt', () {  
    expect(measurementsManager.mcmt, ExpectedMeasurements.mcmt);
  });

  test('set measurementsFormat sets the correct measurementsFormat', () {
    expect(measurementsManager.measurementsFormat, ExpectedMeasurements.measurementsFormat);
  });

  test('get measurementsFormatValue returns the correct measurements format value', () {
    expect(measurementsManager.measurementsFormatValue, ExpectedMeasurements.measurementsFormatValue);
  });

  test('addMesurement returns the correct translated String', () {
    String measurement = "0.5";
    String measurementUnit = "UM_V";
    expect(measurementsManager.addMeasurementUnit(measurement, measurementUnit), "0.5 V");
  });

  test('getBatteryMeasurements returns the expected battery measurements', () {
    expect(measurementsManager.getBatteryMeasurements(true), ExpectedMeasurements.batteryMeasurements);
  });

  test('getBypassMeasurements returns the expected bypass measurements', () {
    expect(measurementsManager.getBypassMeasurements(false), ExpectedMeasurements.bypassMeasurements);
  });

  test('getInputMeasurements returns the expected input measurements', () {
    expect(measurementsManager.getInputMeasurements(), ExpectedMeasurements.inputMeasurements);
  });

  test('getInverterMeasurements returns the expected inverter measurements', () {
    expect(measurementsManager.getInverterMeasurements(), ExpectedMeasurements.inverterMeasurements);
  });

  test('getOutputMeasurements returns the expected output measurements', () {
    expect(measurementsManager.getOutputMeasurements(), ExpectedMeasurements.outputMeasurements);
  });
}