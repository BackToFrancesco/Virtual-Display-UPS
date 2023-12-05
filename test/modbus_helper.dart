import 'dart:io';

import 'dart:typed_data';

import 'package:virtual_display/repositories/modbus_data_repository/models/modbus_data_manager/component_measurements/battery_measurements.dart';
import 'package:virtual_display/repositories/modbus_data_repository/models/modbus_data_manager/component_measurements/bypass_measurements.dart';
import 'package:virtual_display/repositories/modbus_data_repository/models/modbus_data_manager/component_measurements/input_measurements.dart';
import 'package:virtual_display/repositories/modbus_data_repository/models/modbus_data_manager/component_measurements/inverter_measurements.dart';
import 'package:virtual_display/repositories/modbus_data_repository/models/modbus_data_manager/component_measurements/output_measurements.dart';

class UpsMock {
  late ServerSocket _ups;
  final int _port;
  final String _ipAddres;
  static const String upsDataJson = "{states: 10d57fffffffffffffffffffffffffffff, alarms: 10ffffffffffffffffffffffffffffffff, measurements: a000050005000500050005000500050005000500050005000500050005000500050005000500050005000500050005000500050005000500050005000500050005000500050005000500050005000500050005000500050005000500050005000500050005000500050005000500050005000500050005000500050005000500050005000500050005000500050005000500050005000500050005ca55ffff003c, isBatteryPresent: true, isBypassPresent: true}";
  static const String upsConnectionStatusData = "Connect";
  static const String upsConnectionStatusDataJson = "{upsConnectionStatus: Connect}";

  UpsMock(this._ipAddres, this._port);

  int get port => _port;
  String get ipAddress => _ipAddres;
  ServerSocket get ups => _ups;

  Future<void> bind() async {
    _ups = await ServerSocket.bind(_ipAddres, _port);
  }

  Future<void> close() async {
    _ups = await _ups.close();
  }

  void onModbusMasterRequest() {
    Uint8List data = Uint8List.fromList([
      1,
      3,
      16,
      213,
      127,
      255,
      255,
      255,
      255,
      255,
      255,
      255,
      255,
      255,
      255,
      255,
      255,
      255,
      255
    ]);
    Uint8List crcList = crc(data);
    ups.listen((Socket socket) {
      socket.listen((Uint8List received) {
        socket.add(data + [crcList[1]] + [crcList[0]]);
      });
    });
  }

  void onModbusMasterRequestFail() {
    Uint8List data = Uint8List.fromList([
      0,
      3,
      16,
      213,
      127,
      255,
      255,
      255,
      255,
      255,
      255,
      255,
      255,
      255,
      255,
      255,
      255,
      255,
      255
    ]);
    Uint8List crcList = crc(data);
    ups.listen((Socket socket) {
      socket.listen((Uint8List received) {
        socket.add(data + [crcList[1]] + [crcList[0]]);
        socket.close();
      });
    });
  }

  void onModbusMasterRequestInvalidRegister() {
    Uint8List data = Uint8List.fromList([
      0,
      131,
      16,
      213,
      127,
      255,
      255,
      255,
      255,
      255,
      255,
      255,
      255,
      255,
      255,
      255,
      255,
      255,
      255
    ]);
    Uint8List crcList = crc(data);
    ups.listen((Socket socket) {
      socket.listen((Uint8List received) {
        socket.add(data + [crcList[1]] + [crcList[0]]);
        socket.close();
      });
    });
  }
}

Uint8List crc(Uint8List bytes) {
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

class ExpectedState {
  static final Uint8List states = Uint8List.fromList([
    16,
    213,
    127,
    255,
    255,
    255,
    255,
    255,
    255,
    255,
    255,
    255,
    255,
    255,
    255,
    255,
    255
  ]);
  static const List<String> getState = ([
    'S000: Load protected by inverter',
    'S001: Load supplied in normal mode',
    'S003: Load supplied by maintenance bypass',
    'S005: Free',
    'S007: Ups in energy saver',
    'S009: In service mode',
    'S010: Line-interactive mode',
    'S011: Operating',
    'S012: Available',
    'S013: On standby',
    'S014: Unit isolated',
    'S015: Maintenance alert',
    'S016: Output breaker closed ',
    'S017: Maintenance bypass closed ',
    'S018: External maintenance bypass closed ',
    'S019: External output breaker closed',
    'S020: Single phase input supply',
    'S021: Rectifier input breaker closed',
    'S022: Bypass input breaker closed',
    'S023: Gen set on',
    'S024: Bus bar 1 closed ',
    'S025: Bus bar 2 closed ',
    'S026: Automatic start in progress',
    'S027: Maintenance bypass procedure in progress',
    'S028: Ups off procedure in progress',
    'S029: Bypass extraction procedure',
    'S030: Auto-test procedure in progress',
    'S031: Alarm acknowledgement requested',
    'S032: Battery ok',
    'S033: Battery charged',
    'S034: Battery test in progress',
    'S035: Battery test programmed',
    'S036: Battery charging',
    'S037: Battery test interrupted',
    'S038: Floating voltage reduced',
    'S039: Battery discharge to input',
    'S040: Ups backup system connected',
    'S041: Ups backup system charged/ready',
    'S042: Ups backup system charging',
    'S043: Free',
    'S044: All inverters are on',
    'S045: All rectifiers are on',
    'S046: All bypasses are available',
    'S047: All units or modules are available',
    'S048: Rectifier input supply present',
    'S049: Rectifier on',
    'S050: Charger on',
    'S051: Rectifier is starting',
    'S052: Inverter on',
    'S053: Inverter switch on',
    'S054: Free',
    'S055: Bypass output breaker closed',
    'S056: Bypass input supply present',
    'S057: Bypass static switch closed',
    'S058: Bypass input & inverter synchronised',
    'S059: Acs external synchronisation',
    'S060: Powershare plug 1 closed',
    'S061: Powershare plug 2 closed',
    'S062: Powershare plug 3 closed',
    'S063: Powershare plug 4 closed',
    'S064: Card in slot 1 present',
    'S065: Card in slot 2 present',
    'S066: Card in slot 1-ext present',
    'S067: Card in slot 2-ext present',
    'S068: Card in slot 3/syst present',
    'S069: Card in slot 3-ext present',
    'S070: Profile 1 login',
    'S071: Profile 2 login',
    'S072: Programmable s072',
    'S073: Programmable s073',
    'S074: Programmable s074',
    'S075: Programmable s075',
    'S076: Programmable s076',
    'S077: Programmable s077',
    'S078: Programmable s078',
    'S079: Programmable s079',
    'S080: Module insertion procedure',
    'S081: Module extraction procedure',
    'S082: Free',
    'S083: Free',
    'S084: Backfeed protection opened',
    'S085: Free',
    'S086: Free',
    'S087: Free',
    'S088: Free',
    'S089: Free',
    'S090: Free',
    'S091: Free',
    'S092: Free',
    'S093: Free',
    'S094: Free',
    'S095: Free',
    'S096: [1] is operating',
    'S097: [2] is operating',
    'S098: [3] is operating',
    'S099: [4] is operating',
    'S100: [5] is operating',
    'S101: [6] is operating',
    'S102: [7] is operating',
    'S103: [8] is operating',
    'S104: [9] is operating',
    'S105: [10] is operating',
    'S106: [11] is operating',
    'S107: [12] is operating',
    'S108: [13] is operating',
    'S109: [14] is operating',
    'S110: [15] is operating',
    'S111: Free',
    'S112: [1] is available',
    'S113: [2] is available',
    'S114: [3] is available',
    'S115: [4] is available',
    'S116: [5] is available',
    'S117: [6] is available',
    'S118: [7] is available',
    'S119: [8] is available',
    'S120: [9] is available',
    'S121: [10] is available',
    'S122: [11] is available',
    'S123: [12] is available',
    'S124: [13] is available',
    'S125: [14] is available',
    'S126: [15] is available',
    'S127: Data no longer updated'
  ]);
  static const List<int> getStateValueByIndex = [
    1,
    1,
    0,
    1,
    0,
    1,
    0,
    1,
    0,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1
  ];
}

class ExpectedMeasurements {
  static final Uint8List measurments = Uint8List.fromList([
    160,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    0,
    5,
    202,
    85,
    255,
    255,
    0,
    60
  ]);
  static const String json = '{mcmt: 0affffffffffffffffffff, format: 1}';
  static final Uint8List mcmt = Uint8List.fromList(
      [10, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255]);
  static final Uint8List measurementsFormat = Uint8List.fromList([2, 0, 1]);
  static const int measurementsFormatValue = 1;
  static const BatteryMeasurements batteryMeasurements = BatteryMeasurements(
      true,
      '0.5 V',
      '0.5 V',
      '0.5 A',
      '0.5 A',
      '5 %',
      '0.5 Ah',
      '00:05:00',
      '00:00:05',
      '0.5 °c',
      '0.5 °c');
  static const BypassMeasurements bypassMeasurements = BypassMeasurements(
      false,
      '5',
      '5',
      '5',
      '0.5 Hz',
      '5',
      '5',
      '5',
      '0.5',
      '0.5',
      '0.5',
      '0.5',
      '0.5',
      '5');
  static const InputMeasurements inputMeasurements = InputMeasurements('5', '5',
      '5', '0.5 Hz', '5', '5', '5', '0.5', '0.5', '0.5', '0.5', '0.5', '0.5');
  static const InverterMeasurements inverterMeasurements =
      InverterMeasurements('5', '5', '5', '0.5 Hz', '0.5 °c', '5', '5', '0.05');
  static const OutputMeasurements outputMeasurements = OutputMeasurements(
      '5',
      '5',
      '5',
      '5',
      '0.5',
      '0.5',
      '0.5',
      '0.5',
      '0.5',
      '0.5',
      '5',
      '5',
      '5',
      '0.5 Hz',
      '0.5',
      '5',
      '0.5',
      '0.5',
      '0.5',
      '0.5',
      '0.5',
      '5',
      '5',
      '5',
      '0.05',
      '0.05',
      '0.05',
      '0.5',
      '0.5',
      '0.5',
      '0.5');
}

class ExpectedAlarms {
  static final Uint8List alarms = Uint8List.fromList([
    16,
    255,
    255,
    255,
    255,
    255,
    255,
    255,
    255,
    255,
    255,
    255,
    255,
    255,
    255,
    255,
    255
  ]);
  static const List<String> getAlarms = [
    'A000: Imminent stop',
    'A001: Overload alarm',
    'A002: Ambient temperature alarm',
    'A003: Transfer locked',
    'A004: Transfer impossible',
    'A005: Insufficient resources',
    'A006: Redundancy lost',
    'A007: Output short circuit detection',
    'A008: Eco mode disabled by ups',
    'A009: Energy saver disabled by ups',
    'A010: On bypass for 1 hour',
    'A011: Wrong profile password entered',
    'A012: Maintenance alarm',
    'A013: Remote service alarm',
    'A014: Remote service preventive alarm',
    'A015: General alarm',
    'A016: Battery disconnected',
    'A017: Battery discharged',
    'A018: End of back-up time',
    'A019: Operating on battery',
    'A020: Battery temperature alarm',
    'A021: Battery room alarm',
    'A022: Battery test failed',
    'A023: Bms has detected a weak string',
    'A024: At least one battery string open',
    'A025: On battery with mains ok',
    'A026: Insulation fault',
    'A027: Battery alarm',
    'A028: Battery preventive alarm',
    'A029: Ups backup critical alarm',
    'A030: Ups backup preventive alarm',
    'A031: Ups backup not ok',
    'A032: Rectifier critical alarm',
    'A033: Rectifier preventive alarm',
    'A034: Rectifier redundancy alarm',
    'A035: Rectifier input supply not ok',
    'A036: Gen set alarm',
    'A037: Charger critical alarm',
    'A038: Charger preventive alarm',
    'A039: Battery charge interrupted',
    'A040: Inverter critical alarm',
    'A041: Inverter preventive alarm',
    'A042: Inverter redundancy alarm',
    'A043: Imminent redundancy lost',
    'A044: Consumable alarm',
    'A045: Unit redundancy lost',
    'A046: Parallel board critical alarm',
    'A047: Parallel board preventive alarm',
    'A048: Bypass critical alarm',
    'A049: Bypass preventive alarm',
    'A050: Bypass input supply not ok',
    'A051: Phase rotation fault',
    'A052: Bypass back-feed detection',
    'A053: Transformer alarm',
    'A054: Fan failure',
    'A055: Acs alarm',
    'A056: Maintenance bypass alarm',
    'A057: Internal back-feed detection',
    'A058: Battery monitoring alarm',
    'A059: Ups power off ',
    'A060: Wrong configuration ',
    'A061: Internal/communication failure',
    'A062: Option board alarm ',
    'A063: Spare parts not compatible',
    'A064: Programmable a064',
    'A065: Programmable a065',
    'A066: Programmable a066',
    'A067: Programmable a067',
    'A068: Programmable a068',
    'A069: Programmable a069',
    'A070: Programmable a070',
    'A071: Programmable a071',
    'A072: Line-interactive mode disabled by ups',
    'A073: Free',
    'A074: Free',
    'A075: Free',
    'A076: Free',
    'A077: Free',
    'A078: Free',
    'A079: Free',
    'A080: Customer installation overload',
    'A081: Free',
    'A082: Free',
    'A083: Free',
    'A084: Free',
    'A085: Free',
    'A086: Free',
    'A087: Free',
    'A088: Free',
    'A089: Free',
    'A090: Free',
    'A091: Free',
    'A092: Overload pre alarm',
    'A093: Battery voltage out of range',
    'A094: Battery charger failure',
    'A095: Battery deep discharge protection initiated',
    'A096: [1] in general alarm',
    'A097: [2] in general alarm',
    'A098: [3] in general alarm',
    'A099: [4] in general alarm',
    'A100: [5] in general alarm',
    'A101: [6] in general alarm',
    'A102: [7] in general alarm',
    'A103: [8] in general alarm',
    'A104: [9] in general alarm',
    'A105: [10] in general alarm',
    'A106: [11] in general alarm',
    'A107: [12] in general alarm',
    'A108: [13] in general alarm',
    'A109: [14] in general alarm',
    'A110: [15] in general alarm',
    'A111: Free',
    'A112: [1] in imminent stop',
    'A113: [2] in imminent stop',
    'A114: [3] in imminent stop',
    'A115: [4] in imminent stop',
    'A116: [5] in imminent stop',
    'A117: [6] in imminent stop',
    'A118: [7] in imminent stop',
    'A119: [8] in imminent stop',
    'A120: [9] in imminent stop',
    'A121: [10] in imminent stop',
    'A122: [11] in imminent stop',
    'A123: [12] in imminent stop',
    'A124: [13] in imminent stop',
    'A125: [14] in imminent stop',
    'A126: [15] in imminent stop',
    'A127: Free'
  ];
  static const List<int> getAllarmByIndex = [
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1
  ];
}

class ExpectedDataManagerMeasure {
  static final Uint8List t009 = Uint8List.fromList([2, 0, 0]);
  static final Uint8List t010 = Uint8List.fromList([2, 255, 255]);
}
// ./genhtml.perl ./coverage/lcov.info -o coverage/html
