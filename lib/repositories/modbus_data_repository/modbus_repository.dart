import 'dart:async';
import 'dart:typed_data';
import 'models/modbus/modbus_functions.dart';
import 'models/modbus/ups_info.dart';
import 'models/modbus_connection_manager/modbus_connection_manager.dart';
import 'models/modbus_data_manager/component_measurements/battery_measurements.dart';
import 'models/modbus_data_manager/component_measurements/bypass_measurements.dart';
import 'models/modbus_data_manager/component_measurements/input_measurements.dart';
import 'models/modbus_data_manager/component_measurements/inverter_measurements.dart';
import 'models/modbus_data_manager/component_measurements/output_measurements.dart';
import 'models/modbus_data_manager/modbus_data_manager.dart';
import 'models/modbus_data_manager/status/ups_status.dart';
import 'models/modbus_data_manager/synoptic/synoptic.dart';

class ModbusRepository {
  ModbusDataManager? _modbusDataManager;

  final ModbusConnectionManager _modbusConnectionManager =
      ModbusConnectionManager();

  int _dataRefreshSpeedSeconds;

  Timer? _timer;

  final StreamController<bool> _upsDataChangedController =
      StreamController<bool>.broadcast();

  ModbusRepository([this._dataRefreshSpeedSeconds = 1]);

  Stream<bool> get dataChangedStream async* {
    yield* _upsDataChangedController.stream.asBroadcastStream();
  }

  Stream<UpsStatus> get upsStatusStream => _modbusDataManager!.upsStatusStream;

  bool get connected => _modbusConnectionManager.isConnected;

  Stream<Synoptic> get synopticStatusStream =>
      _modbusDataManager!.synopticStatusStream;

  Stream<UpsConnectionStatus> get connectionStatusStream =>
      _modbusConnectionManager.connectionStatusStream;

  UpsInfo get upsInfo => _modbusConnectionManager.upsInfo;

  set dataRefreshSpeedSeconds(int dataRefreshSpeedSeconds) {
    _dataRefreshSpeedSeconds = dataRefreshSpeedSeconds;
    if (_modbusConnectionManager.isConnected == true) {
      _stopUpdatingData();
      _startUpdatingData();
    }
  }

  int get dataRefreshSpeedSeconds => _dataRefreshSpeedSeconds;

  Future<void> _updateData() async {
    try {
      _modbusDataManager!.states =
          await _modbusConnectionManager.readHoldingRegisters(0x0030, 8);
      _modbusDataManager!.alarms =
          await _modbusConnectionManager.readHoldingRegisters(0x0038, 8);
      _modbusDataManager!.t009 =
          await _modbusConnectionManager.readHoldingRegisters(0x000A, 1);
      _modbusDataManager!.t010 =
          await _modbusConnectionManager.readHoldingRegisters(0x000B, 1);
      _modbusDataManager!.measurements =
          await _modbusConnectionManager.readHoldingRegisters(0x0040, 80);
      _upsDataChangedController.add(true);
      _modbusDataManager!.updateUpsStatus();
      _modbusDataManager!.updateSynoptic();
    } catch (e) {
      _stopUpdatingData();
      await _clearData();
    }
  }

  Future<void> _clearData() async {
    await _modbusDataManager?.dispose();
    _modbusDataManager = null;
  }

  Future<void> setMaster(String ipAddress, int port, int slaveId) async {
    _stopUpdatingData();
    await _clearData();
    await _modbusConnectionManager.setMaster(ipAddress, port, slaveId);
  }

  Future<void> connectMaster() async {
    if (!_modbusConnectionManager.isConnected) {
      if (await _modbusConnectionManager.connectMaster()) {
        _modbusDataManager = ModbusDataManager();
        await _readConfiguration();
        _startUpdatingData();
      }
    }
  }

  Future<void> _readConfiguration() async {
    try {
      _modbusDataManager!.mcmt =
          await _modbusConnectionManager.readHoldingRegisters(0x00C0, 5);
      _modbusDataManager!.measurementsFormat =
          await _modbusConnectionManager.readHoldingRegisters(0x000E, 1);
    } catch (e) {
      await _clearData();
    }
  }

  Future<void> closeMaster() async {
    _stopUpdatingData();
    await _modbusConnectionManager.closeMaster();
    await _clearData();
  }

  Future<void> dispose() async {
    await closeMaster();
    await _upsDataChangedController.close();
  }

  List<String>? getStates() {
    return _modbusDataManager?.getStates();
  }

  List<String>? getAlarms() {
    return _modbusDataManager?.getAlarms();
  }

  BatteryMeasurements? getBatteryMeasurements() {
    return _modbusDataManager?.getBatteryMeasurements();
  }

  BypassMeasurements? getBypassMeasurements() {
    return _modbusDataManager?.getBypassMeasurements();
  }

  InputMeasurements? getInputMeasurements() {
    return _modbusDataManager?.getInputMeasurements();
  }

  InverterMeasurements? getInverterMeasurements() {
    return _modbusDataManager?.getInverterMeasurements();
  }

  OutputMeasurements? getOutputMeasurements() {
    return _modbusDataManager?.getOutputMeasurements();
  }

  Uint8List? getRawStatesFrame() {
    if (_modbusDataManager != null) {
      return _modbusConnectionManager.rebuildFrame(
          ModbusFunctions.readHoldingRegisters,
          _modbusDataManager!.states.sublist(0));
    }
    return null;
  }

  Uint8List? getRawAlarmsFrame() {
    if (_modbusDataManager != null) {
      return _modbusConnectionManager.rebuildFrame(
          ModbusFunctions.readHoldingRegisters,
          _modbusDataManager!.alarms.sublist(0));
    }
    return null;
  }

  Uint8List? getRawMeasurementsFrame() {
    if (_modbusDataManager != null) {
      return _modbusConnectionManager.rebuildFrame(
          ModbusFunctions.readHoldingRegisters,
          _modbusDataManager!.measurements.sublist(0));
    }
    return null;
  }

  Uint8List? getRawMcmtFrame() {
    if (_modbusDataManager != null) {
      return _modbusConnectionManager.rebuildFrame(
          ModbusFunctions.readHoldingRegisters,
          _modbusDataManager!.mcmt.sublist(0));
    }
    return null;
  }

  bool? getBatPresent() {
    return _modbusDataManager?.batPresent;
  }

  bool? getNoBypass() {
    return _modbusDataManager?.noBypass;
  }

  int? getMeasurementsFormatValue() {
    return _modbusDataManager?.measurementsFormatValue;
  }

  void _stopUpdatingData() {
    _timer?.cancel();
  }

  void _startUpdatingData() {
    if (_timer == null || !_timer!.isActive) {
      _timer = Timer.periodic(Duration(seconds: _dataRefreshSpeedSeconds),
          (Timer t) => _updateData());
    }
  }
}
