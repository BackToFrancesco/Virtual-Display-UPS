import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:virtual_display/repositories/modbus_data_repository/exceptions/exceptions.dart';
import 'package:virtual_display/repositories/modbus_data_repository/models/modbus/modbus_functions.dart';
import 'package:virtual_display/repositories/modbus_data_repository/models/modbus/ups_info.dart';
import 'package:virtual_display/repositories/modbus_data_repository/models/modbus_connection_manager/modbus_connection_manager.dart';

import '../modbus_helper.dart';

void main() async {
  UpsMock upsMock = UpsMock('127.0.0.1', 55555);
  setUp(() async {
    await upsMock.bind();
  });

  tearDown(() async {
    await upsMock.close();
  });
  ModbusConnectionManager modbusConnectionManager = ModbusConnectionManager();
group('Connecting to an not existing UPS', () {
    UpsInfo upsInfoNotExist = const UpsInfo("130.0.0.2", 456789, 1);
    test(
        'connectMaster() return false if modbusMaster fail to connect to an UPS',
        () async {
      upsMock.onModbusMasterRequest();
      await modbusConnectionManager.setMaster(upsInfoNotExist.ipAddress, upsInfoNotExist.port, upsInfoNotExist.slaveId);
      expectLater(await modbusConnectionManager.connectMaster(), false);
      await modbusConnectionManager.closeMaster();
    });
  });
  group('Connecting to an existing UPS', () {
    UpsInfo upsInfoExist = const UpsInfo('127.0.0.1', 55555, 1);
    test('upsInfo return the correct info of the ups ', () async{
      await modbusConnectionManager.setMaster(upsInfoExist.ipAddress, upsInfoExist.port, upsInfoExist.slaveId);
      expect(modbusConnectionManager.upsInfo.ipAddress, upsInfoExist.ipAddress);
      expect(modbusConnectionManager.upsInfo.port, upsInfoExist.port);
      expect(modbusConnectionManager.upsInfo.slaveId, upsInfoExist.slaveId);
    });
    test(
        'isConnected is true when modbusConnectionManager is connected to an UPS',
        () async {
      upsMock.onModbusMasterRequest();
      await modbusConnectionManager.setMaster(upsInfoExist.ipAddress, upsInfoExist.port, upsInfoExist.slaveId);
      await modbusConnectionManager.connectMaster();
      expect(modbusConnectionManager.isConnected, true);
      await modbusConnectionManager.closeMaster();
    });
    test(
        'isConnected is false when modbusConnectionManager is disconnected from an UPS',
        () async {
      upsMock.onModbusMasterRequest();
      await modbusConnectionManager.setMaster(upsInfoExist.ipAddress, upsInfoExist.port, upsInfoExist.slaveId);
      await modbusConnectionManager.connectMaster();
      expect(modbusConnectionManager.isConnected, true);
      await modbusConnectionManager.closeMaster();
      expect(modbusConnectionManager.isConnected, false);
    });
    test(
        'rebuildFrame compose a frame and return it correctly',
        () async {
      upsMock.onModbusMasterRequest();
      await modbusConnectionManager.setMaster(upsInfoExist.ipAddress, upsInfoExist.port, upsInfoExist.slaveId);
      await modbusConnectionManager.connectMaster();
      expect(modbusConnectionManager.isConnected, true);
      Uint8List data = Uint8List.fromList([0x0030, 0x0008]);
      Uint8List expectedFrame = Uint8List.fromList([1, 3, 48, 8, 228, 30]);
      expect(
          modbusConnectionManager.rebuildFrame(
              ModbusFunctions.readHoldingRegisters, data),
          expectedFrame);
      await modbusConnectionManager.closeMaster();
    });
    test(
        'if the ModbusConnectionManager request invalid data to the UPS an exception is thrown',
        () async {
      upsMock.onModbusMasterRequest();
      await modbusConnectionManager.setMaster(upsInfoExist.ipAddress, upsInfoExist.port, upsInfoExist.slaveId);
      await modbusConnectionManager.connectMaster();
      expect(modbusConnectionManager.isConnected, true);
      await expectLater(modbusConnectionManager.readHoldingRegisters(0x0030, 6), throwsA(isA<ModbusInvalidDataException>()));
      await modbusConnectionManager.closeMaster();
    });
  });
}
