import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:virtual_display/repositories/modbus_data_repository/models/modbus/modbus_functions.dart';
import 'package:virtual_display/repositories/modbus_data_repository/models/modbus/modbus_master.dart';
import 'package:virtual_display/repositories/modbus_data_repository/models/modbus/ups_info.dart';
import 'package:virtual_display/repositories/modbus_data_repository/exceptions/exceptions.dart';
import '../modbus_helper.dart';

void main() async{
  UpsMock upsMock = UpsMock('127.0.0.1', 55555);
  setUp(() async{
      await upsMock.bind();
  });

  tearDown(() async{
    await upsMock.close();
  });
  
  group('Connection to an not existing UPS: ', (){
    UpsInfo upsInfoNotExist = UpsInfo("130.0.0.2", 456789, 1);
    final ModbusMaster modbusMaster = ModbusMaster(upsInfoNotExist);

    test('throws an exception if the UPS port is not reachable', () async{
      expect(() async => modbusMaster.connect(),
          throwsA(isA<ModbusUnreachableIpPortException>()));
      await modbusMaster.close();
    });
    test('is connected is false when you try to connect to a not existing UPS', () async{
      
      expect(() async => modbusMaster.connect(),
          throwsA(isA<ModbusUnreachableIpPortException>()));
      expect(modbusMaster.isConnected, false);
      await modbusMaster.close();
    });
    
  });
  
  group('Connection to an existing UPS: ', (){

    UpsInfo upsInfoExist = UpsInfo('127.0.0.1', 55555, 1);
    ModbusMaster modbusMaster = ModbusMaster(upsInfoExist);

    test('upsInfo return the info of the UPS', (){
      expect(modbusMaster.upsInfo, upsInfoExist);
    });
    test('isConnected is false before making any connection to an UPS', (){
      expect(modbusMaster.isConnected, false);
    });
    test('isConnected is true when UPS is connected', () async{
      upsMock.onModbusMasterRequest();
      await modbusMaster.connect();
      expect(modbusMaster.isConnected, true);
      await modbusMaster.close();
    });
    test('isConnected is false after disconnected the UPS', () async{
      upsMock.onModbusMasterRequest();
      await modbusMaster.connect();
      expect(modbusMaster.isConnected, true);
      await modbusMaster.close();
      expect(modbusMaster.isConnected, false);
    });

    test('if Ups send an uncorrect answer then throw a data invalid exception', () async{
      upsMock.onModbusMasterRequestFail();
      expect(() async => await modbusMaster.connect(), throwsA(isA<ModbusInvalidDataException>()));
      await modbusMaster.close();
    });

    test('if Ups send an uncorrect register in the answer then throw a invalid data exception', () async{
      upsMock.onModbusMasterRequestInvalidRegister();
      expect(() async => await modbusMaster.connect(), throwsA(isA<ModbusInvalidDataException>()));
      await modbusMaster.close();
    });

    test('rebuildFrame compose a frame and return it correctly',
        () async {
      upsMock.onModbusMasterRequest();
      await modbusMaster.connect();
      Uint8List data = Uint8List.fromList([0x0030, 0x0008]);
      Uint8List expectedFrame = Uint8List.fromList([1, 3, 48, 8, 228, 30]);
      expect(
          modbusMaster.rebuildFrame(
              ModbusFunctions.readHoldingRegisters, data),
          expectedFrame);
      await modbusMaster.close();
    });

    test('if the ModbusMaster request invalid data to the UPS an exception is thrown', () async{
      upsMock.onModbusMasterRequest();
      await modbusMaster.connect();
      await expectLater(modbusMaster.readHoldingRegisters(0x0030, 6), throwsA(isA<ModbusInvalidDataException>()));
      await modbusMaster.close();
    });

  });
}