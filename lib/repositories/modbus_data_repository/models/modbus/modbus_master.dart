import 'dart:async';
import 'dart:typed_data';
import '../../exceptions/exceptions.dart';
import '../../utils/utils.dart' as utils;
import 'modbus_connector.dart';
import 'modbus_exception_codes.dart';
import 'modbus_functions.dart';
import 'ups_info.dart';

class ModbusMaster {
  late final ModbusConnector _connector;

  Completer? _completer;
  FunctionCallback? _nextDataCallBack;

  ModbusMaster(UpsInfo upsInfo) {
    _connector = ModbusConnector(upsInfo);
    _connector.onResponse = _onConnectorData;
    _connector.onError = _onConnectorError;
    _connector.onClose = _onConnectorClose;
  }

  UpsInfo get upsInfo => _connector.upsInfo;

  bool get isConnected => _connector.isConnected;

  Future<void> connect() async {
    await _connector.connect();
    await _checkSlaveId();
  }

  Future<void> close() async {
    await _connector.close();
  }

  Uint8List rebuildFrame(int function, Uint8List data) {
    return _connector.rebuildFrame(function, data);
  }

  Future<void> _checkSlaveId() async {
    try {
      await readHoldingRegisters(0x0030, 8);
    } catch (e) {
      if (_connector.isConnected) {
        await _connector.close();
      }
      if (e is ModbusIllegalAddressException) {
        throw ModbusBadSlaveIdException();
      } else {
        rethrow;
      }
    }
  }

  Future<Uint8List> readHoldingRegisters(int address, int amount) async {
    Uint8List dataTx = Uint8List.fromList([
      utils.extractByteFromUInt16(address, 1),
      utils.extractByteFromUInt16(address, 0),
      utils.extractByteFromUInt16(amount, 1),
      utils.extractByteFromUInt16(amount, 0)
    ]);

    if (_connector.isConnected) {
      Uint8List dataRx = Uint8List.fromList([]);
      dataRx =
          await _executeFunction(ModbusFunctions.readHoldingRegisters, dataTx);
      if (dataRx.length < 2 ||
          dataRx[0] != 2 * amount ||
          amount != (dataRx.length - 1) / 2) {
        throw ModbusInvalidDataException();
      }
      return dataRx;
    } else {
      throw ModbusConnectorErrorException("The UPS connector was closed");
    }
  }

  void _sendData(int function, Uint8List data) {
    _connector.write(function, data);
  }

  void _onConnectorData(int function, Uint8List data, bool valid) {
    if (_nextDataCallBack != null) _nextDataCallBack!(function, data, valid);
  }

  void _onConnectorError(Object error) {
    if (_completer?.isCompleted == false) {
      _completer
          ?.completeError(ModbusConnectorErrorException(error.toString()));
    }
  }

  Future<void> _onConnectorClose() async {
    if (_connector.isConnected) {
      await _connector.close();
    }
    if (_completer?.isCompleted == false) {
      _completer!.completeError(
          ModbusConnectorErrorException("The UPS connector was closed"));
    }
  }

  Future<Uint8List> _executeFunction(int function, Uint8List data) {
    return _executeFunctionImpl(function, data,
        (responseFunction, responseData, isValid) async {
      if (isValid) {
        if (responseFunction == function + 0x80) {
          int errorCode = responseData.elementAt(0);
          ModbusException e;
          switch (errorCode) {
            case ModbusExceptionCodes.illegalFunction:
              e = ModbusIllegalFunctionException();
              break;
            case ModbusExceptionCodes.illegalAddress:
              e = ModbusIllegalAddressException();
              break;
            default:
              e = ModbusUnknownErrorCodeException(errorCode.toString());
              break;
          }
          if (_completer?.isCompleted == false) {
            _completer!.completeError(e);
          }
        } else {
          if (function == responseFunction) {
            if (_completer?.isCompleted == false) {
              _completer!.complete(responseData);
            }
          } else {
            if (_completer?.isCompleted == false) {
              _completer!.completeError(ModbusInvalidDataException());
            }
          }
        }
      } else {
        if (_completer?.isCompleted == false) {
          _completer!.completeError(ModbusInvalidDataException());
        }
      }
    });
  }

  Future<Uint8List> _executeFunctionImpl(
      int function, Uint8List data, FunctionCallback callback) async {
    _completer = Completer<Uint8List>();

    _nextDataCallBack = callback;
    _sendData(function, Uint8List.fromList(data));
    return _completer!.future.then((value) => value as Uint8List);
  }
}
