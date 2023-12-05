import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import '../../exceptions/exceptions.dart';
import 'ups_info.dart';

typedef FunctionCallback = void Function(int, Uint8List, bool);
typedef ErrorCallback = void Function(Object);
typedef CloseCallback = void Function();

class ModbusConnector {
  final UpsInfo upsInfo;

  final int _timeout;

  Socket? _socket;

  late FunctionCallback onResponse;
  ErrorCallback? onError;
  CloseCallback? onClose;

  StreamSubscription<Uint8List>? _rxStream;

  ModbusConnector(this.upsInfo, [this._timeout = 15]);

  bool get isConnected => _socket != null;

  Future<void> connect() async {
    try {
      if (_socket != null) {
        await close();
      }
      _socket = await Socket.connect(upsInfo.ipAddress, upsInfo.port,
          timeout: Duration(seconds: _timeout));
    } catch (e) {
      throw ModbusUnreachableIpPortException(
          ipAddress: upsInfo.ipAddress, port: upsInfo.port);
    }
    _rxStream = _socket!.listen(_onData,
        onError: onError, onDone: onClose, cancelOnError: false);
  }

  Future<void> close() async {
    if (_socket != null) {
      await _socket?.close();
      _rxStream?.cancel();
      _rxStream = null;
      _socket = null;
    }
  }

  void write(int function, Uint8List data) {
    _socket!.add(_buildFrame(function, data));
  }

  Uint8List rebuildFrame(int function, Uint8List data) {
    return _buildFrame(function, data);
  }

  Uint8List _buildFrame(int function, Uint8List data) {
    Uint8List frameTx =
        Uint8List.fromList([upsInfo.slaveId] + [function] + data);
    Uint8List crc = _crc(frameTx);
    return Uint8List.fromList(frameTx + [crc[1]] + [crc[0]]);
  }

  void _onData(Uint8List frameRx) {
    onResponse(frameRx[1], frameRx.sublist(2, frameRx.length - 2),
        frameRx[0] == upsInfo.slaveId && _checkCrc(frameRx));
  }

  bool _checkCrc(Uint8List frameRx) {
    Uint8List crc = _crc(frameRx.sublist(0, frameRx.length - 2));
    return crc[0] == frameRx[frameRx.length - 1] &&
        crc[1] == frameRx[frameRx.length - 2];
  }

  Uint8List _crc(Uint8List bytes) {
    var crc = BigInt.from(0xffff);
    var poly = BigInt.from(0xa001);
    for (var byte in bytes) {
      var bigByte = BigInt.from(byte);
      crc = crc ^ bigByte;
      for (int n = 0; n <= 7; n++) {
        int carry = crc.toInt() & 0x1;
        crc = crc >> 1;
        if (carry == 0x1) {
          crc = crc ^ poly;
        }
      }
    }
    var ret = Uint8List(2);
    ByteData.view(ret.buffer).setUint16(0, crc.toUnsigned(16).toInt());
    return ret;
  }
}
