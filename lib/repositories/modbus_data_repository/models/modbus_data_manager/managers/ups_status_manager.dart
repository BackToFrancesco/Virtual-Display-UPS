import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../../config/colors.dart' as app_colors;
import '../../../../../utils/translator.dart';
import '../status/ups_status.dart';
import 'alarms_manager.dart';
import 'measurements_manager.dart';
import 'states_manager.dart';

enum _ColorAnimation { fixed, blinking }

class UpsStatusManager {
  final StatesManager statesManager;
  final AlarmsManager alarmManager;
  final MeasurementsManager measurementsManager;

  bool _initialized = false;

  Timer? _timer;

  late String _description;
  late List<Color> _colors;
  late _ColorAnimation _colorAnimation;
  late int _colorIndex;

  final StreamController<UpsStatus> _upsUpsStatusController =
      StreamController<UpsStatus>.broadcast();

  UpsStatusManager(
      this.statesManager, this.alarmManager, this.measurementsManager);

  Stream<UpsStatus> get upsStatusStream async* {
    yield* _upsUpsStatusController.stream.asBroadcastStream();
  }

  void updateUpsStatus() {
    String currentDescription =
        _getStatusDescription(statesManager, alarmManager);
    List<Color> currentColors = _getColors();
    _ColorAnimation currentColorAnimation = _getColorAnimation();
    if (!_initialized ||
        _description != currentDescription ||
        !listEquals(_colors, currentColors) ||
        _colorAnimation != currentColorAnimation) {
      if (!_initialized) {
        _initialized = true;
      }
      _description = currentDescription;
      _colors = currentColors;
      _colorAnimation = currentColorAnimation;
      _colorIndex = 0;
      _stopUpdatingUpsStatusColors();
      _startUpdatingUpsStatusColors();
    }
  }

  Future<void> dispose() async {
    _timer?.cancel();
    await _upsUpsStatusController.close();
  }

  void _stopUpdatingUpsStatusColors() {
    _timer?.cancel();
  }

  void _startUpdatingUpsStatusColors() {
    _upsUpsStatusController.add(UpsStatus(_description, _colors[_colorIndex]));
    if (_colorAnimation == _ColorAnimation.blinking &&
        (_timer == null || !_timer!.isActive)) {
      _timer = Timer.periodic(const Duration(milliseconds: 300), (Timer t) {
        if (_colorIndex == _colors.length - 1) {
          _colorIndex = 0;
        } else {
          _colorIndex++;
        }
        _upsUpsStatusController
            .add(UpsStatus(_description, _colors[_colorIndex]));
      });
    }
  }

  String _getStatusDescription(
      StatesManager statesManager, AlarmsManager alarmManager) {
    Translator translator = Translator();
    if (statesManager.getStateValueByIndex(26) == 1) {
      return translator.translateIfExists("STS_STARTING");
    }
    if (statesManager.getStateValueByIndex(27) == 1) {
      return translator.translateIfExists("STS_MAINT_BP");
    }
    if (statesManager.getStateValueByIndex(28) == 1) {
      return translator.translateIfExists("STS_STOP");
    }
    if (statesManager.getStateValueByIndex(3) == 1) {
      return translator.translateIfExists("ON_MAINT_BYPASS");
    }
    if (alarmManager.getAlarmByIndex(0) == 1) {
      return translator.translateIfExists("IMMINENT_STOP");
    }
    if (statesManager.getStateValueByIndex(30) == 1) {
      return translator.translateIfExists("AUTO_TEST");
    }
    if (alarmManager.getAlarmByIndex(19) == 1) {
      return translator.translateIfExists("ON_BATTERY");
    }
    if (statesManager.getStateValueByIndex(34) == 1) {
      return translator.translateIfExists("BATTERY_TEST_UPP");
    }
    if (statesManager.getStateValueByIndex(0) == 1) {
      return translator.translateIfExists("ON_INVERTER");
    }
    if (statesManager.getStateValueByIndex(1) == 1) {
      return translator.translateIfExists("NORMAL_MODE");
    }
    if (statesManager.getStateValueByIndex(2) == 1 &&
        statesManager.getStateValueByIndex(6) == 1) {
      return translator.translateIfExists("ECO_MODE");
    }
    if (statesManager.getStateValueByIndex(2) == 1 &&
        statesManager.getStateValueByIndex(6) == 0) {
      return translator.translateIfExists("ON_AUTO_BYPASS");
    }
    if (statesManager.getStateValueByIndex(12) == 1) {
      return translator.translateIfExists("UNIT_AVAILABLE");
    }
    if (statesManager.getStateValueByIndex(13) == 1) {
      return translator.translateIfExists("STANDBY");
    }
    return translator.translateIfExists("LOAD_OFF");
  }

  List<Color> _getColors() {
    String? m078 = measurementsManager.getMeasurementByIndex(78);
    switch (m078) {
      case "0":
        return [app_colors.darkGrey];
      case "1":
        return [app_colors.green];
      case "2":
        return [app_colors.white, app_colors.green];
      case "3":
        return [app_colors.green, app_colors.yellow];
      case "4":
        return [app_colors.yellow];
      case "5":
        return [app_colors.white, app_colors.yellow];
      case "6":
        return const [app_colors.yellow, app_colors.red];
      case "7":
        return [app_colors.red];
      case "8":
        return [app_colors.white, app_colors.red];
      default:
        return [app_colors.green, app_colors.yellow, app_colors.red];
    }
  }

  _ColorAnimation _getColorAnimation() {
    String? m078 = measurementsManager.getMeasurementByIndex(78);
    switch (m078) {
      case "0":
        return _ColorAnimation.fixed;
      case "1":
        return _ColorAnimation.fixed;
      case "2":
        return _ColorAnimation.blinking;
      case "3":
        return _ColorAnimation.blinking;
      case "4":
        return _ColorAnimation.fixed;
      case "5":
        return _ColorAnimation.blinking;
      case "6":
        return _ColorAnimation.blinking;
      case "7":
        return _ColorAnimation.fixed;
      case "8":
        return _ColorAnimation.blinking;
      default:
        return _ColorAnimation.blinking;
    }
  }
}
