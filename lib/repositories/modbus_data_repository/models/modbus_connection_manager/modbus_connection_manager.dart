import 'dart:async';
import 'dart:typed_data';
import '../../exceptions/exceptions.dart';
import '../modbus/modbus_master.dart';
import '../modbus/ups_info.dart';

enum UpsConnectionStatus {
  connected,
  unableToConnect,
  unableToCommunicate,
  unableToVerifyTheSlaveId,
  reconnecting,
  disconnected,
  disconnectedDueToConnectorError,
  disconnectedDueToIllegalFunction,
  disconnectedDueToIllegalAddress,
  disconnectedDueToInvalidData,
  disconnectedDueToUnknownErrorCode
}

class ModbusConnectionManager {
  ModbusMaster? _master;

  bool _disconnectedDueToError = false;

  bool _firstTimeConnecting = true;

  int _invalidDataPacketsCount = 0;

  final StreamController<UpsConnectionStatus> _upsConnectionStatusController =
  StreamController<UpsConnectionStatus>.broadcast();

  Stream<UpsConnectionStatus> get connectionStatusStream async* {
    yield* _upsConnectionStatusController.stream.asBroadcastStream();
  }

  UpsInfo get upsInfo => _master!.upsInfo;

  bool get isConnected => _master?.isConnected ?? false;

  Future<void> setMaster(String ipAddress, int port, int slaveId) async {
    await closeMaster();
    _firstTimeConnecting = true;
    _master = ModbusMaster(UpsInfo(ipAddress, port, slaveId));
  }

  Future<bool> connectMaster() async {
    if (_master?.isConnected == false) {
      try {
        if (!_firstTimeConnecting) {
          _upsConnectionStatusController.add(UpsConnectionStatus.reconnecting);
        } else {
          _firstTimeConnecting = false;
        }
        await _master!.connect();
        _upsConnectionStatusController.add(UpsConnectionStatus.connected);
        return true;
      } on ModbusException catch (e) {
        if (e is ModbusUnreachableIpPortException) {
          _upsConnectionStatusController
              .add(UpsConnectionStatus.unableToConnect);
        } else if (e is ModbusBadSlaveIdException) {
          _upsConnectionStatusController
              .add(UpsConnectionStatus.unableToCommunicate);
        } else {
          _upsConnectionStatusController
              .add(UpsConnectionStatus.unableToVerifyTheSlaveId);
        }
        return false;
      }
    }
    return true;
  }

  Future<void> closeMaster() async {
    if (_master?.isConnected == true) {
      if (!_disconnectedDueToError) {
        _upsConnectionStatusController.add(UpsConnectionStatus.disconnected);
      }
      await _master?.close();
      _disconnectedDueToError = false;
      _invalidDataPacketsCount = 0;
    }
  }

  Future<void> dispose() async {
    await closeMaster();
    await _upsConnectionStatusController.close();
    _master = null;
  }

  Uint8List? rebuildFrame(int function, Uint8List data) {
    return _master!.rebuildFrame(function, data);
  }

  Future<Uint8List> readHoldingRegisters(int address, int amount) async {
    try {
      return await _master!.readHoldingRegisters(address, amount);
    } catch (e) {
      _disconnectedDueToError = true;
      await closeMaster();
      if (e is ModbusInvalidDataException) {
        _invalidDataPacketsCount++;
        if (_invalidDataPacketsCount == 5) {
          _upsConnectionStatusController
              .add(UpsConnectionStatus.disconnectedDueToInvalidData);
        }
      } else if (e is ModbusIllegalAddressException) {
        _upsConnectionStatusController
            .add(UpsConnectionStatus.disconnectedDueToIllegalAddress);
      } else if (e is ModbusIllegalFunctionException) {
        _upsConnectionStatusController
            .add(UpsConnectionStatus.disconnectedDueToIllegalFunction);
      } else if (e is ModbusUnknownErrorCodeException) {
        _upsConnectionStatusController
            .add(UpsConnectionStatus.disconnectedDueToUnknownErrorCode);
      } else {
        _upsConnectionStatusController
            .add(UpsConnectionStatus.disconnectedDueToConnectorError);
      }
      rethrow;
    }
  }
}
