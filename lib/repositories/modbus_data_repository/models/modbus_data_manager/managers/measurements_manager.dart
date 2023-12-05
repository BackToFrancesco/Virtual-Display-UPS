import 'dart:typed_data';
import 'package:intl/intl.dart';
import '../../../../../utils/translator.dart';
import '../../../utils/utils.dart' as utils;
import '../component_measurements/battery_measurements.dart';
import '../component_measurements/bypass_measurements.dart';
import '../component_measurements/input_measurements.dart';
import '../component_measurements/inverter_measurements.dart';
import '../component_measurements/measurements_format.dart';
import '../component_measurements/output_measurements.dart';

class MeasurementsManager {
  late Uint8List _measurements;
  late Uint16List _measurementsUIntValues;

  late final Uint8List _mcmt;
  late final String _mcmtBinary;

  late final Uint8List _measurementsFormat;
  late final int _measurementsFormatValue;

  final Translator _translator = Translator();

  final List<MeasurementsFormat> _measurementsFormats = [
    const MeasurementsFormat("###", "###", 1, 1, false, false),
    const MeasurementsFormat("###", "###", 1, 1, false, false),
    const MeasurementsFormat("###", "###", 1, 1, false, false),
    const MeasurementsFormat("###", "###", 1, 1, false, false),
    const MeasurementsFormat("#####", "####.#", 1, 10, false, false),
    const MeasurementsFormat("#####", "####.#", 1, 10, false, false),
    const MeasurementsFormat("#####", "####.#", 1, 10, false, false),
    const MeasurementsFormat("#####", "####.#", 1, 10, false, false),
    const MeasurementsFormat("#####", "####.#", 1, 10, false, false),
    const MeasurementsFormat("#####", "####.#", 1, 10, false, false),
    const MeasurementsFormat("###", "###", 1, 1, false, false),
    const MeasurementsFormat("###", "###", 1, 1, false, false),
    const MeasurementsFormat("###", "###", 1, 1, false, false),
    const MeasurementsFormat("##.#", "##.#", 10, 10, false, false),
    const MeasurementsFormat("#.#", "#.#", 10, 10, false, false),
    const MeasurementsFormat("##.#", "##.#", 10, 10, true, false),
    const MeasurementsFormat("####", "###.#", 1, 10, true, false),
    const MeasurementsFormat("####", "###.#", 1, 10, true, false),
    const MeasurementsFormat("#####", "####.#", 1, 10, true, false),
    const MeasurementsFormat("#####", "####.#", 1, 10, true, false),
    const MeasurementsFormat("", "", 1, 1, false, false),
    const MeasurementsFormat("", "", 1, 1, false, false),
    const MeasurementsFormat("###", "###", 1, 1, false, false),
    const MeasurementsFormat("#####", "####.#", 1, 10, false, false),
    const MeasurementsFormat(
        "%02d:%02d:%02d", "%02d:%02d:%02d", 1, 1, false, true),
    const MeasurementsFormat(
        "%02d:%02d:%02d", "%02d:%02d:%02d", 60, 60, false, true),
    const MeasurementsFormat("##.#", "##.#", 10, 10, true, false),
    const MeasurementsFormat("##.#", "##.#", 10, 10, true, false),
    const MeasurementsFormat("####", "###.#", 1, 10, false, false),
    const MeasurementsFormat("##.#", "##.#", 10, 10, true, false),
    const MeasurementsFormat("", "", 1, 1, false, false),
    const MeasurementsFormat("", "", 1, 1, false, false),
    const MeasurementsFormat("###", "###", 1, 1, false, false),
    const MeasurementsFormat("###", "###", 1, 1, false, false),
    const MeasurementsFormat("###", "###", 1, 1, false, false),
    const MeasurementsFormat("##.#", "##.#", 10, 10, false, false),
    const MeasurementsFormat("###", "###", 1, 1, false, false),
    const MeasurementsFormat("###", "###", 1, 1, false, false),
    const MeasurementsFormat("###", "###", 1, 1, false, false),
    const MeasurementsFormat("###", "###", 1, 1, false, false),
    const MeasurementsFormat("###", "###", 1, 1, false, false),
    const MeasurementsFormat("###", "###", 1, 1, false, false),
    const MeasurementsFormat("##.#", "##.#", 10, 10, false, false),
    const MeasurementsFormat("###", "###", 1, 1, false, false),
    const MeasurementsFormat("###", "###", 1, 1, false, false),
    const MeasurementsFormat("###", "###", 1, 1, false, false),
    const MeasurementsFormat("", "", 1, 1, false, false),
    const MeasurementsFormat("#####", "####.#", 1, 10, false, false),
    const MeasurementsFormat("#####", "####.#", 1, 10, false, false),
    const MeasurementsFormat("#####", "####.#", 1, 10, false, false),
    const MeasurementsFormat("#####", "####.#", 1, 10, false, false),
    const MeasurementsFormat("#####", "####.#", 1, 10, false, false),
    const MeasurementsFormat("#####", "####.#", 1, 10, false, false),
    const MeasurementsFormat("###", "###", 1, 1, false, false),
    const MeasurementsFormat("###", "###", 1, 1, false, false),
    const MeasurementsFormat("###", "###", 1, 1, false, false),
    const MeasurementsFormat("#.##", "#.##", 100, 100, true, false),
    const MeasurementsFormat("#.##", "#.##", 100, 100, true, false),
    const MeasurementsFormat("#.##", "#.##", 100, 100, true, false),
    const MeasurementsFormat("#.#", "#.#", 10, 10, false, false),
    const MeasurementsFormat("#.#", "#.#", 10, 10, false, false),
    const MeasurementsFormat("#.#", "#.#", 10, 10, false, false),
    const MeasurementsFormat("#.#", "#.#", 10, 10, false, false),
    const MeasurementsFormat("#####", "####.#", 1, 10, false, false),
    const MeasurementsFormat("#####", "####.#", 1, 10, false, false),
    const MeasurementsFormat("#####", "####.#", 1, 10, false, false),
    const MeasurementsFormat("#####", "####.#", 1, 10, true, false),
    const MeasurementsFormat("#####", "####.#", 1, 10, true, false),
    const MeasurementsFormat("#####", "####.#", 1, 10, true, false),
    const MeasurementsFormat("#####", "####.#", 1, 10, false, false),
    const MeasurementsFormat("#####", "####.#", 1, 10, false, false),
    const MeasurementsFormat("#####", "####.#", 1, 10, false, false),
    const MeasurementsFormat("#####", "####.#", 1, 10, false, false),
    const MeasurementsFormat("#####", "####.#", 1, 10, false, false),
    const MeasurementsFormat("#####", "####.#", 1, 10, false, false),
    const MeasurementsFormat("##", "##", 1, 1, true, false),
    const MeasurementsFormat("", "", 1, 1, false, false),
    const MeasurementsFormat("", "", 1, 1, false, false),
    const MeasurementsFormat("", "", 1, 1, false, false)
  ];

  set measurements(Uint8List measurements) {
    Uint16List measurementsUIntValues = Uint16List(80);
    for (int i = 1, j = 0; i < measurements.length; i += 2, j++) {
      measurementsUIntValues[j] =
          (((measurements[i] & 0xff) << 8) | (measurements[i + 1] & 0xff));
    }
    _measurements = measurements;
    _measurementsUIntValues = measurementsUIntValues;
  }

  Uint8List get measurements => _measurements;

  set mcmt(Uint8List mcmt) {
    String mcmtBinary = "";
    for (var i = 1; i < mcmt.length; i++) {
      mcmtBinary += utils.uIntTo8bitString(mcmt[i]);
    }
    _mcmt = mcmt;
    _mcmtBinary = mcmtBinary;
  }

  Uint8List get mcmt => _mcmt;

  set measurementsFormat(Uint8List measurementsFormat) {
    _measurementsFormat = measurementsFormat;
    _measurementsFormatValue =
        ((measurementsFormat[1] & 0xff) << 8) | (measurementsFormat[2] & 0xff);
    if (_measurementsFormatValue != 0 && _measurementsFormatValue != 1) {
      _measurementsFormatValue = 0;
    }
  }

  Uint8List get measurementsFormat => _measurementsFormat;

  int get measurementsFormatValue => _measurementsFormatValue;

  BatteryMeasurements getBatteryMeasurements(bool batPresent) {
    return BatteryMeasurements(
        batPresent,
        addMeasurementUnit(getMeasurementByIndex(16), "UM_V"),
        addMeasurementUnit(getMeasurementByIndex(17), "UM_V"),
        addMeasurementUnit(getMeasurementByIndex(18), "UM_A"),
        addMeasurementUnit(getMeasurementByIndex(19), "UM_A"),
        addMeasurementUnit(getMeasurementByIndex(22), "UM_PERC"),
        addMeasurementUnit(getMeasurementByIndex(23), "UM_AH"),
        getMeasurementByIndex(24),
        getMeasurementByIndex(25),
        addMeasurementUnit(getMeasurementByIndex(26), "UM_DEGREES"),
        addMeasurementUnit(getMeasurementByIndex(27), "UM_DEGREES"));
  }

  BypassMeasurements getBypassMeasurements(bool noBypass) {
    return BypassMeasurements(
        noBypass,
        getMeasurementByIndex(39),
        getMeasurementByIndex(40),
        getMeasurementByIndex(41),
        addMeasurementUnit(getMeasurementByIndex(42), "HZ"),
        getMeasurementByIndex(43),
        getMeasurementByIndex(44),
        getMeasurementByIndex(45),
        getMeasurementByIndex(70),
        getMeasurementByIndex(71),
        getMeasurementByIndex(71),
        getMeasurementByIndex(73),
        getMeasurementByIndex(74),
        getMeasurementByIndex(75));
  }

  InputMeasurements getInputMeasurements() {
    return InputMeasurements(
        getMeasurementByIndex(32),
        getMeasurementByIndex(33),
        getMeasurementByIndex(34),
        addMeasurementUnit(getMeasurementByIndex(35), "HZ"),
        getMeasurementByIndex(36),
        getMeasurementByIndex(37),
        getMeasurementByIndex(38),
        getMeasurementByIndex(64),
        getMeasurementByIndex(65),
        getMeasurementByIndex(66),
        getMeasurementByIndex(67),
        getMeasurementByIndex(68),
        getMeasurementByIndex(69));
  }

  InverterMeasurements getInverterMeasurements() {
    return InverterMeasurements(
        getMeasurementByIndex(10),
        getMeasurementByIndex(11),
        getMeasurementByIndex(12),
        addMeasurementUnit(getMeasurementByIndex(13), "HZ"),
        addMeasurementUnit(getMeasurementByIndex(15), "UM_DEGREES"),
        getMeasurementByIndex(54),
        getMeasurementByIndex(55),
        getMeasurementByIndex(56));
  }

  OutputMeasurements getOutputMeasurements() {
    return OutputMeasurements(
        getMeasurementByIndex(0),
        getMeasurementByIndex(1),
        getMeasurementByIndex(2),
        getMeasurementByIndex(3),
        getMeasurementByIndex(4),
        getMeasurementByIndex(5),
        getMeasurementByIndex(6),
        getMeasurementByIndex(7),
        getMeasurementByIndex(8),
        getMeasurementByIndex(9),
        getMeasurementByIndex(10),
        getMeasurementByIndex(11),
        getMeasurementByIndex(12),
        addMeasurementUnit(getMeasurementByIndex(13), "HZ"),
        getMeasurementByIndex(14),
        getMeasurementByIndex(46),
        getMeasurementByIndex(48),
        getMeasurementByIndex(49),
        getMeasurementByIndex(50),
        getMeasurementByIndex(51),
        getMeasurementByIndex(52),
        getMeasurementByIndex(53),
        getMeasurementByIndex(54),
        getMeasurementByIndex(55),
        getMeasurementByIndex(56),
        getMeasurementByIndex(57),
        getMeasurementByIndex(58),
        getMeasurementByIndex(59),
        getMeasurementByIndex(60),
        getMeasurementByIndex(61),
        getMeasurementByIndex(62));
  }

  String? addMeasurementUnit(String? measurement, String measurementUnit) {
    if (measurement != null) {
      measurement += " " + _translator.translateIfExists(measurementUnit);
    }
    return measurement;
  }

  String? getMeasurementByIndex(int index) {
    if (_mcmtBinary[index] == "1") {
      if (index == 77) {
        //not handled yet
        return null;
      } else if (index == 79) {
        //not handled yet
        return null;
      } else {
        if (!_measurementsFormats.elementAt(index).isTime) {
          int value;
          if (_measurementsFormats.elementAt(index).isSigned) {
            value =
                Int16List.fromList([_measurementsUIntValues.elementAt(index)])
                    .elementAt(0);
          } else {
            value = _measurementsUIntValues.elementAt(index);
          }
          if (_measurementsFormatValue == 0) {
            return (NumberFormat(_measurementsFormats.elementAt(index).format0)
                    .format(value /
                        _measurementsFormats.elementAt(index).scaleFactor0))
                .toString();
          } else {
            return (NumberFormat(_measurementsFormats.elementAt(index).format1)
                    .format(value /
                        _measurementsFormats.elementAt(index).scaleFactor1))
                .toString();
          }
        } else {
          if (index == 24) {
            int totalMinutes = _measurementsUIntValues.elementAt(index);
            String hours = utils.fillStringPaddingLeft(
                (totalMinutes ~/ 60).toString(), 2, "0");
            totalMinutes %= 60;
            String minutes =
                utils.fillStringPaddingLeft(totalMinutes.toString(), 2, "0");
            return "$hours:$minutes:00";
          } else if (index == 25) {
            int totalSeconds = _measurementsUIntValues.elementAt(index);
            String hours = utils.fillStringPaddingLeft(
                (totalSeconds ~/ 3600).toString(), 2, "0");
            totalSeconds %= 3600;
            String minutes = utils.fillStringPaddingLeft(
                (totalSeconds ~/ 60).toString(), 2, "0");
            totalSeconds %= 60;
            String seconds =
                utils.fillStringPaddingLeft(totalSeconds.toString(), 2, "0");
            return "$hours:$minutes:$seconds";
          }
        }
      }
    }
    return null;
  }
}
