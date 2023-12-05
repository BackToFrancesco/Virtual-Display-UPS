import 'dart:typed_data';
import '../../utils/utils.dart' as utils;
import 'component_measurements/battery_measurements.dart';
import 'component_measurements/bypass_measurements.dart';
import 'component_measurements/input_measurements.dart';
import 'component_measurements/inverter_measurements.dart';
import 'component_measurements/output_measurements.dart';
import 'managers/alarms_manager.dart';
import 'managers/measurements_manager.dart';
import 'managers/states_manager.dart';
import 'managers/synoptic_manager.dart';
import 'managers/ups_status_manager.dart';
import 'status/ups_status.dart';
import 'synoptic/synoptic.dart';

class ModbusDataManager {
  ModbusDataManager() {
    _upsStatusManager =
        UpsStatusManager(_statesManager, _alarmsManager, _measurementsManager);
    _synopticManager =
        SynopticManager(_statesManager, _alarmsManager, _measurementsManager);
  }

  final StatesManager _statesManager = StatesManager();
  final AlarmsManager _alarmsManager = AlarmsManager();
  final MeasurementsManager _measurementsManager = MeasurementsManager();
  late final UpsStatusManager _upsStatusManager;
  late final SynopticManager _synopticManager;

  Uint8List _t009 = Uint8List.fromList([]);
  late bool noBypass;
  late bool noMntByp;

  Uint8List _t010 = Uint8List.fromList([]);
  late bool dcPresent;
  late bool batPresent;

  set states(Uint8List states) {
    _statesManager.states = states;
  }

  Uint8List get states => _statesManager.states;

  set alarms(Uint8List alarms) {
    _alarmsManager.alarms = alarms;
  }

  Uint8List get alarms => _alarmsManager.alarms;

  set measurements(Uint8List measurements) {
    _measurementsManager.measurements = measurements;
  }

  Uint8List get measurements => _measurementsManager.measurements;

  set mcmt(Uint8List mcmt) {
    _measurementsManager.mcmt = mcmt;
  }

  Uint8List get mcmt => _measurementsManager.mcmt;

  set measurementsFormat(Uint8List measurementsFormat) {
    _measurementsManager.measurementsFormat = measurementsFormat;
  }

  Uint8List get measurementsFormat => _measurementsManager.measurementsFormat;

  int get measurementsFormatValue =>
      _measurementsManager.measurementsFormatValue;

  set t009(Uint8List t009) {
    _t009 = t009;
    String lsb = utils.uIntTo8bitString(t009[2]);
    noMntByp = lsb[0] == "1" ? true : false;
    noBypass = lsb[1] == "1" ? true : false;
  }

  Uint8List get t009 => _t009;

  set t010(Uint8List t010) {
    _t010 = t010;
    String lsb = utils.uIntTo8bitString(t010[2]);
    batPresent = lsb[7] == "1" ? true : false;
    dcPresent = (((t010[1] & 0xff) << 8) | (t010[2] & 0xff)) > 0 ? true : false;
  }

  Uint8List get t010 => _t010;

  Stream<UpsStatus> get upsStatusStream => _upsStatusManager.upsStatusStream;

  Stream<Synoptic> get synopticStatusStream =>
      _synopticManager.synopticStatusStream;

  List<String> getStates() {
    return _statesManager.getStates();
  }

  int getStateValueByIndex(int index) {
    return _statesManager.getStateValueByIndex(index);
  }

  List<String> getAlarms() {
    return _alarmsManager.getAlarms();
  }

  int getAlarmByIndex(int index) {
    return _alarmsManager.getAlarmByIndex(index);
  }

  BatteryMeasurements getBatteryMeasurements() {
    return _measurementsManager.getBatteryMeasurements(batPresent);
  }

  BypassMeasurements getBypassMeasurements() {
    return _measurementsManager.getBypassMeasurements(noBypass);
  }

  InputMeasurements getInputMeasurements() {
    return _measurementsManager.getInputMeasurements();
  }

  InverterMeasurements getInverterMeasurements() {
    return _measurementsManager.getInverterMeasurements();
  }

  OutputMeasurements getOutputMeasurements() {
    return _measurementsManager.getOutputMeasurements();
  }

  void updateUpsStatus() {
    _upsStatusManager.updateUpsStatus();
  }

  void updateSynoptic() {
    _synopticManager.updateSynoptic(
        batPresent: batPresent,
        dcPresent: dcPresent,
        noBypass: noBypass,
        noMntByp: noMntByp);
  }

  Future<void> dispose() async {
    await _upsStatusManager.dispose();
    await _synopticManager.dispose();
  }
}
