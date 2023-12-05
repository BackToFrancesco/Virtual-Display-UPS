import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../../config/colors.dart' as app_colors;
import '../synoptic/synoptic.dart';
import 'alarms_manager.dart';
import 'measurements_manager.dart';
import 'states_manager.dart';

class SynopticManager {
  final StatesManager statesManager;
  final AlarmsManager alarmsManager;
  final MeasurementsManager measurementsManager;

  bool _initialized = false;

  bool _maintOn = false;

  Timer? _timer;

  late Synoptic _synoptic;

  final StreamController<Synoptic> _synopticStatusController =
      StreamController<Synoptic>.broadcast();

  SynopticManager(
      this.statesManager, this.alarmsManager, this.measurementsManager);

  Stream<Synoptic> get synopticStatusStream async* {
    yield* _synopticStatusController.stream.asBroadcastStream();
  }

  void updateSynoptic(
      {required bool batPresent,
      required bool dcPresent,
      required bool noBypass,
      required bool noMntByp}) {
    Synoptic currentSynoptic =
        _getSynoptic(batPresent, dcPresent, noBypass, noMntByp);
    if (!_initialized || _synoptic != currentSynoptic) {
      if (!_initialized) {
        _initialized = true;
      }
      _synoptic = currentSynoptic;
      _stopUpdating();
      _startUpdating();
    }
  }

  Future<void> dispose() async {
    _timer?.cancel();
    await _synopticStatusController.close();
  }

  void _stopUpdating() {
    _timer?.cancel();
    _maintOn = false;
  }

  void _startUpdating() {
    if (_timer == null || !_timer!.isActive) {
      _timer = Timer.periodic(const Duration(milliseconds: 500), (Timer t) {
        if (statesManager.getStateValueByIndex(15) == 1) {
          _synopticStatusController.add(_synoptic);
        } else if (alarmsManager.getAlarmByIndex(12) == 1) {
          _maintOn = !_maintOn;
          if (_maintOn) {
            _synopticStatusController.add(_synoptic);
          } else {
            _synopticStatusController.add(_synoptic.copyWith(maint: null));
          }
        } else {
          _synopticStatusController.add(_synoptic);
          t.cancel();
        }
      });
    }
  }

  Synoptic _getSynoptic(
      bool batPresent, bool dcPresent, bool noBypass, bool noMntByp) {
    return Synoptic(
        _getMaint(),
        _getRectifierInput(),
        _getRectifier(),
        _getDcBus(),
        _getDcInput(dcPresent),
        _getBattery(batPresent),
        _getM022(batPresent),
        _getM024(batPresent),
        _getM015(),
        _getChargeOrDischargeBattery(batPresent),
        _getDcOutput(dcPresent),
        _getInvInput(),
        _getInverter(),
        _getInvOutput(),
        _getOutput(),
        _getLoad(noMntByp),
        _getM000(),
        _getM005(),
        _getBypOutput(noBypass),
        _getBypass(noBypass),
        _getBypInput(noBypass),
        _getOnMntByp(noMntByp),
        noBypass);
  }

  AssetImage? _getMaint() {
    if (alarmsManager.getAlarmByIndex(12) == 1) {
      return const AssetImage(
          "assets/images/dashboard/synoptic/bypass/MAINT.png");
    }
    if (statesManager.getStateValueByIndex(15) == 1) {
      return const AssetImage(
          "assets/images/dashboard/synoptic/bypass/MAINT.png");
    }
    return null;
  }

  String? _getM022(bool batPresent) {
    if (batPresent) {
      String? m022 = measurementsManager.getMeasurementByIndex(22);
      if (m022 != "0" && alarmsManager.getAlarmByIndex(19) == 0) {
        return measurementsManager.addMeasurementUnit(m022, "UM_PERC");
      }
    }
    return null;
  }

  String? _getM024(bool batPresent) {
    if (batPresent) {
      String? m024 = measurementsManager.getMeasurementByIndex(24);
      if (m024 != null && alarmsManager.getAlarmByIndex(19) == 1) {
        int minutes = (60 * int.parse(m024.substring(0, 2))) +
            int.parse(m024.substring(3, 5));
        if (minutes < 2) {
          return "---";
        }
        return m024.substring(0, 5) + "'";
      }
    }
    return null;
  }

  String? _getM015() {
    return measurementsManager.addMeasurementUnit(
        measurementsManager.getMeasurementByIndex(15), "UM_DEGREES");
  }

  AssetImage? _getBattery(bool batPresent) {
    if (batPresent) {
      if (alarmsManager.getAlarmByIndex(27) == 1) {
        if (alarmsManager.getAlarmByIndex(16) == 1) {
          return const AssetImage(
              "assets/images/dashboard/synoptic/battery/BAT_OPEN_CRITIC.png");
        }
        return const AssetImage(
            "assets/images/dashboard/synoptic/battery/BAT_CRITIC.png");
      }
      if (alarmsManager.getAlarmByIndex(20) == 1 ||
          alarmsManager.getAlarmByIndex(21) == 1 ||
          alarmsManager.getAlarmByIndex(22) == 1 ||
          alarmsManager.getAlarmByIndex(26) == 1) {
        if (alarmsManager.getAlarmByIndex(16) == 1) {
          return const AssetImage(
              "assets/images/dashboard/synoptic/battery/BAT_OPEN_PREV.png");
        }
        return const AssetImage(
            "assets/images/dashboard/synoptic/battery/BAT_PREV.png");
      }
      if (alarmsManager.getAlarmByIndex(16) == 1) {
        return const AssetImage(
            "assets/images/dashboard/synoptic/battery/BAT_OPEN_NORMAL.png");
      }
      String? m022 = measurementsManager.getMeasurementByIndex(22);
      if (m022 == null) {
        return null;
      }
      int m022Int = int.parse(m022);
      if (m022Int <= 0) {
        return const AssetImage(
            "assets/images/dashboard/synoptic/battery/BAT_NORMAL.png");
      }
      if (m022Int > 0 && m022Int <= 5) {
        return const AssetImage(
            "assets/images/dashboard/synoptic/battery/5.png");
      }
      if (m022Int > 5 && m022Int <= 10) {
        return const AssetImage(
            "assets/images/dashboard/synoptic/battery/10.png");
      }
      if (m022Int > 10 && m022Int <= 15) {
        return const AssetImage(
            "assets/images/dashboard/synoptic/battery/15.png");
      }
      if (m022Int > 15 && m022Int <= 20) {
        return const AssetImage(
            "assets/images/dashboard/synoptic/battery/20.png");
      }
      if (m022Int > 20 && m022Int <= 25) {
        return const AssetImage(
            "assets/images/dashboard/synoptic/battery/25.png");
      }
      if (m022Int > 25 && m022Int <= 30) {
        return const AssetImage(
            "assets/images/dashboard/synoptic/battery/30.png");
      }
      if (m022Int > 30 && m022Int <= 35) {
        return const AssetImage(
            "assets/images/dashboard/synoptic/battery/35.png");
      }
      if (m022Int > 35 && m022Int <= 40) {
        return const AssetImage(
            "assets/images/dashboard/synoptic/battery/40.png");
      }
      if (m022Int > 40 && m022Int <= 45) {
        return const AssetImage(
            "assets/images/dashboard/synoptic/battery/45.png");
      }
      if (m022Int > 45 && m022Int <= 50) {
        return const AssetImage(
            "assets/images/dashboard/synoptic/battery/50.png");
      }
      if (m022Int > 50 && m022Int <= 55) {
        return const AssetImage(
            "assets/images/dashboard/synoptic/battery/55.png");
      }
      if (m022Int > 55 && m022Int <= 60) {
        return const AssetImage(
            "assets/images/dashboard/synoptic/battery/60.png");
      }
      if (m022Int > 60 && m022Int <= 65) {
        return const AssetImage(
            "assets/images/dashboard/synoptic/battery/65.png");
      }
      if (m022Int > 65 && m022Int <= 70) {
        return const AssetImage(
            "assets/images/dashboard/synoptic/battery/70.png");
      }
      if (m022Int > 70 && m022Int <= 75) {
        return const AssetImage(
            "assets/images/dashboard/synoptic/battery/75.png");
      }
      if (m022Int > 75 && m022Int <= 80) {
        return const AssetImage(
            "assets/images/dashboard/synoptic/battery/80.png");
      }
      if (m022Int > 80 && m022Int <= 85) {
        return const AssetImage(
            "assets/images/dashboard/synoptic/battery/85.png");
      }
      if (m022Int > 85 && m022Int <= 90) {
        return const AssetImage(
            "assets/images/dashboard/synoptic/battery/90.png");
      }
      if (m022Int > 90 && m022Int <= 95) {
        return const AssetImage(
            "assets/images/dashboard/synoptic/battery/95.png");
      }
      return const AssetImage(
          "assets/images/dashboard/synoptic/battery/100.png");
    }
    return null;
  }

  AssetImage? _getChargeOrDischargeBattery(bool batPresent) {
    if (batPresent) {
      if (alarmsManager.getAlarmByIndex(16) == 1) {
        return null;
      }
      if (alarmsManager.getAlarmByIndex(19) == 1) {
        return const AssetImage(
            "assets/images/dashboard/synoptic/battery/DISCHARGE.png");
      }
      if (statesManager.getStateValueByIndex(36) == 1) {
        return const AssetImage(
            "assets/images/dashboard/synoptic/battery/CHARGE.png");
      }
    }
    return null;
  }

  Color _getRectifierInput() {
    if (statesManager.getStateValueByIndex(39) == 1) {
      return app_colors.yellow;
    } else if (statesManager.getStateValueByIndex(48) == 1) {
      return app_colors.green;
    } else {
      return app_colors.mediumGrey;
    }
  }

  AssetImage _getRectifier() {
    if (alarmsManager.getAlarmByIndex(32) == 1 &&
        statesManager.getStateValueByIndex(49) == 1) {
      return const AssetImage(
          "assets/images/dashboard/synoptic/rectifier/REC_CRITIC.png");
    } else if (alarmsManager.getAlarmByIndex(33) == 1 &&
        statesManager.getStateValueByIndex(49) == 1) {
      return const AssetImage(
          "assets/images/dashboard/synoptic/rectifier/REC_PREV.png");
    }
    return const AssetImage(
        "assets/images/dashboard/synoptic/rectifier/REC_NORMAL.png");
  }

  Color _getDcBus() {
    if (statesManager.getStateValueByIndex(39) == 1) {
      return app_colors.yellow;
    } else if (statesManager.getStateValueByIndex(49) == 1) {
      return app_colors.green;
    }
    return app_colors.mediumGrey;
  }

  Color? _getDcInput(bool dcPresent) {
    if (dcPresent) {
      if (statesManager.getStateValueByIndex(39) == 1) {
        return app_colors.yellow;
      } else if (statesManager.getStateValueByIndex(49) == 1) {
        return app_colors.green;
      }
      return app_colors.mediumGrey;
    }
    return null;
  }

  Color? _getDcOutput(bool dcPresent) {
    if (dcPresent) {
      if (alarmsManager.getAlarmByIndex(19) == 1 &&
          statesManager.getStateValueByIndex(39) == 1) {
        return app_colors.yellow;
      }
      return app_colors.mediumGrey;
    }
    return null;
  }

  Color _getInvInput() {
    if (alarmsManager.getAlarmByIndex(19) == 1 &&
        statesManager.getStateValueByIndex(39) == 1) {
      return app_colors.yellow;
    } else if (statesManager.getStateValueByIndex(49) == 1) {
      return app_colors.green;
    }
    return app_colors.mediumGrey;
  }

  Color _getOutput() {
    if ((statesManager.getStateValueByIndex(0) == 1 &&
            alarmsManager.getAlarmByIndex(19) == 1) ||
        (statesManager.getStateValueByIndex(2) == 1 &&
            statesManager.getStateValueByIndex(6) == 0)) {
      return app_colors.yellow;
    } else if ((statesManager.getStateValueByIndex(0) == 1) ||
        (statesManager.getStateValueByIndex(2) == 1 &&
            statesManager.getStateValueByIndex(6) == 1)) {
      return app_colors.green;
    }
    return app_colors.mediumGrey;
  }

  AssetImage _getInverter() {
    if (alarmsManager.getAlarmByIndex(40) == 1 &&
        statesManager.getStateValueByIndex(52) == 1) {
      return const AssetImage(
          "assets/images/dashboard/synoptic/inverter/INV_CRITIC.png");
    } else if (alarmsManager.getAlarmByIndex(41) == 1 &&
        statesManager.getStateValueByIndex(52) == 1) {
      return const AssetImage(
          "assets/images/dashboard/synoptic/inverter/INV_PREV.png");
    }
    return const AssetImage(
        "assets/images/dashboard/synoptic/inverter/INV_NORMAL.png");
  }

  Color _getInvOutput() {
    if (alarmsManager.getAlarmByIndex(19) == 1) {
      return app_colors.yellow;
    } else if (statesManager.getStateValueByIndex(52) == 1) {
      return app_colors.green;
    }
    return app_colors.mediumGrey;
  }

  Color? _getBypInput(bool noBypass) {
    if (!noBypass) {
      if (statesManager.getStateValueByIndex(2) == 1 &&
          statesManager.getStateValueByIndex(6) == 0) {
        return app_colors.yellow;
      } else if (statesManager.getStateValueByIndex(56) == 1) {
        return app_colors.green;
      }
      return app_colors.mediumGrey;
    }
    return null;
  }

  AssetImage? _getBypass(bool noBypass) {
    if (!noBypass) {
      if (alarmsManager.getAlarmByIndex(48) == 1 &&
          statesManager.getStateValueByIndex(57) == 1) {
        return const AssetImage(
            "assets/images/dashboard/synoptic/bypass/BYP_CRITIC.png");
      } else if (alarmsManager.getAlarmByIndex(49) == 1 &&
          statesManager.getStateValueByIndex(57) == 1) {
        return const AssetImage(
            "assets/images/dashboard/synoptic/bypass/BYP_PREV.png");
      }
      return const AssetImage(
          "assets/images/dashboard/synoptic/bypass/BYP_NORMAL.png");
    }
    return null;
  }

  Color? _getBypOutput(bool noBypass) {
    if (!noBypass) {
      if (statesManager.getStateValueByIndex(2) == 1 &&
          statesManager.getStateValueByIndex(6) == 0) {
        return app_colors.yellow;
      } else if ((statesManager.getStateValueByIndex(2) == 1 &&
              statesManager.getStateValueByIndex(6) == 1) ||
          (statesManager.getStateValueByIndex(57) == 1 &&
              statesManager.getStateValueByIndex(2) == 0)) {
        return app_colors.green;
      }
      return app_colors.mediumGrey;
    }
    return null;
  }

  Color? _getOnMntByp(bool noMntByp) {
    if (!noMntByp && statesManager.getStateValueByIndex(3) == 1) {
      return app_colors.yellow;
    }
    return null;
  }

  AssetImage? _getLoad(bool noMntByp) {
    if (!noMntByp && statesManager.getStateValueByIndex(3) == 1) {
      return null;
    }
    String? m000 = measurementsManager.getMeasurementByIndex(0);
    if (m000 == null) {
      return null;
    }
    int m000Int = int.parse(m000);
    if (m000Int <= 0) {
      return const AssetImage(
          "assets/images/dashboard/synoptic/load/LOAD_BKG.png");
    }
    if (m000Int > 0 && m000Int <= 5) {
      return const AssetImage("assets/images/dashboard/synoptic/load/5_b.png");
    }
    if (m000Int > 5 && m000Int <= 10) {
      return const AssetImage("assets/images/dashboard/synoptic/load/10_b.png");
    }
    if (m000Int > 10 && m000Int <= 15) {
      return const AssetImage("assets/images/dashboard/synoptic/load/10_b.png");
    }
    if (m000Int > 15 && m000Int <= 20) {
      return const AssetImage("assets/images/dashboard/synoptic/load/10_b.png");
    }
    if (m000Int > 20 && m000Int <= 25) {
      return const AssetImage("assets/images/dashboard/synoptic/load/10_b.png");
    }
    if (m000Int > 25 && m000Int <= 30) {
      return const AssetImage("assets/images/dashboard/synoptic/load/10_b.png");
    }
    if (m000Int > 30 && m000Int <= 35) {
      return const AssetImage("assets/images/dashboard/synoptic/load/10_b.png");
    }
    if (m000Int > 35 && m000Int <= 40) {
      return const AssetImage("assets/images/dashboard/synoptic/load/10_b.png");
    }
    if (m000Int > 40 && m000Int <= 45) {
      return const AssetImage("assets/images/dashboard/synoptic/load/10_b.png");
    }
    if (m000Int > 45 && m000Int <= 50) {
      return const AssetImage("assets/images/dashboard/synoptic/load/10_b.png");
    }
    if (m000Int > 50 && m000Int <= 55) {
      return const AssetImage("assets/images/dashboard/synoptic/load/10_b.png");
    }
    if (m000Int > 55 && m000Int <= 60) {
      return const AssetImage("assets/images/dashboard/synoptic/load/10_b.png");
    }
    if (m000Int > 60 && m000Int <= 65) {
      return const AssetImage("assets/images/dashboard/synoptic/load/10_b.png");
    }
    if (m000Int > 65 && m000Int <= 70) {
      return const AssetImage("assets/images/dashboard/synoptic/load/10_b.png");
    }
    if (m000Int > 70 && m000Int <= 75) {
      return const AssetImage("assets/images/dashboard/synoptic/load/10_b.png");
    }
    if (m000Int > 75 && m000Int <= 80) {
      return const AssetImage("assets/images/dashboard/synoptic/load/10_b.png");
    }
    if (m000Int > 80 && m000Int <= 85) {
      return const AssetImage("assets/images/dashboard/synoptic/load/10_b.png");
    }
    if (m000Int > 85 && m000Int <= 90) {
      return const AssetImage("assets/images/dashboard/synoptic/load/10_b.png");
    }
    if (m000Int > 90 && m000Int <= 95) {
      return const AssetImage("assets/images/dashboard/synoptic/load/10_b.png");
    }
    if (m000Int > 95 && m000Int <= 100) {
      return const AssetImage("assets/images/dashboard/synoptic/load/10_b.png");
    }
    if (m000Int > 100 && m000Int <= 105) {
      return const AssetImage("assets/images/dashboard/synoptic/load/10_b.png");
    }
    if (m000Int > 105 && m000Int <= 110) {
      return const AssetImage("assets/images/dashboard/synoptic/load/10_b.png");
    }
    if (m000Int > 110 && m000Int <= 115) {
      return const AssetImage("assets/images/dashboard/synoptic/load/10_b.png");
    }
    return const AssetImage("assets/images/dashboard/synoptic/load/10_b.png");
  }

  String? _getM000() {
    if (statesManager.getStateValueByIndex(3) == 1) {
      return null;
    }
    String? m000 = measurementsManager.getMeasurementByIndex(0);
    if (m000 == "0") {
      return null;
    }
    return measurementsManager.addMeasurementUnit(m000, "UM_PERC");
  }

  String? _getM005() {
    return measurementsManager.addMeasurementUnit(
        measurementsManager.getMeasurementByIndex(5), "UM_KW");
  }
}
