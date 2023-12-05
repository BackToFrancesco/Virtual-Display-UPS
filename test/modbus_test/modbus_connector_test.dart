import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:virtual_display/repositories/modbus_data_repository/models/modbus/modbus_connector.dart';
import 'package:virtual_display/repositories/modbus_data_repository/models/modbus/ups_info.dart';
import 'package:virtual_display/repositories/modbus_data_repository/exceptions/exceptions.dart';
import 'package:virtual_display/repositories/modbus_data_repository/models/modbus/modbus_functions.dart';
import 'dart:typed_data';

import '../modbus_helper.dart';

void main() async{
  UpsMock upsMock = UpsMock('127.0.0.1', 55555);

  setUp(() async{
    await upsMock.bind();
  });

  tearDown(() async{
    await upsMock.close();
  });
  group('Connection to an not existing UPS: ', () {
    UpsInfo upsInfoNotExist = UpsInfo("130.0.0.2", 456789, 1);
    final ModbusConnector modbusConnector = ModbusConnector(upsInfoNotExist);
    test('throws an exception if the UPS port is not reachable', () async {
      expect(() async => modbusConnector.connect(),
          throwsA(isA<ModbusUnreachableIpPortException>()));
      await modbusConnector.close();
    });
    test('isConnected is false when UPS not exist', () async {
      expect(() async => modbusConnector.connect(),
          throwsA(isA<ModbusUnreachableIpPortException>()));
      expect(modbusConnector.isConnected, false);
      await modbusConnector.close();
    });
  });

  group('Connecting to an existing UPS: ', () {
    UpsInfo upsInfo = UpsInfo('127.0.0.1', 55555, 1);
    ModbusConnector modbusConnector = ModbusConnector(upsInfo);
    test('isConnected is true when UPS is connected', () async {
      await modbusConnector.connect();
      expect(modbusConnector.isConnected, true);
      await modbusConnector.close();
    });
    test('isConnected is false when UPS is disconnected', () async {
      await modbusConnector.connect();
      expect(modbusConnector.isConnected, true);
      await modbusConnector.close();
      expect(modbusConnector.isConnected, false);
      await modbusConnector.close();
    });
    test('isConnected is false before making any connection to an UPS',
        () {
      expect(modbusConnector.isConnected, false);
    });
    test('rebuildFrame return compose a frame and return it correctly',
        () async {
      await modbusConnector.connect();
      Uint8List data = Uint8List.fromList([0x0030, 0x0008]);
      Uint8List expectedFrame = Uint8List.fromList([1, 3, 48, 8, 228, 30]);
      expect(
          modbusConnector.rebuildFrame(
              ModbusFunctions.readHoldingRegisters, data),
          expectedFrame);
      await modbusConnector.close();
    });
  
    test('The frame that the ModbusConnector send to UPS is received correctly',
        () async {
      Uint8List data = Uint8List.fromList([0x0030, 0x0008]);
      Uint8List expectedFrame = Uint8List.fromList([1, 3, 48, 8, 228, 30]);
      late Uint8List result;
      upsMock.ups.listen((Socket socket) {
      socket.listen((List<int> data) {
        result = Uint8List.fromList(data);
        expect(result, expectedFrame);
      });
    });
      await modbusConnector.connect();
      modbusConnector.write(ModbusFunctions.readHoldingRegisters, data);
      await modbusConnector.close();
    });
  });
}