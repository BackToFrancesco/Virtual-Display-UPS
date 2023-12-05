import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../repositories/modbus_data_repository/modbus_repository.dart';
import '../../../../repositories/modbus_data_repository/models/modbus_data_manager/component_measurements/battery_measurements.dart';
import '../../../../repositories/modbus_data_repository/models/modbus_data_manager/status/ups_status.dart';

part 'battery_measurements_event.dart';

part 'battery_measurements_state.dart';

class BatteryMeasurementsBloc
    extends Bloc<BatteryMeasurementsEvent, BatteryMeasurementsState> {
  BatteryMeasurementsBloc({
    required ModbusRepository modbusDataRepository,
  })  : _modbusDataRepository = modbusDataRepository,
        super(const BatteryMeasurementsState()) {
    on<UpsStatusChanged>(_onUpsStatusChanged);
    on<DataChanged>(_onDataChanged);
    on<Init>(_onInit);
    _dataChangedSubscription = _modbusDataRepository.dataChangedStream
        .listen((dataChanged) => add(const DataChanged()));
    _upsStatusChangedSubscription = _modbusDataRepository.upsStatusStream
        .listen((upsStatus) => add(UpsStatusChanged(upsStatus)));
  }

  final ModbusRepository _modbusDataRepository;

  late StreamSubscription<bool> _dataChangedSubscription;

  late StreamSubscription<UpsStatus> _upsStatusChangedSubscription;

  @override
  Future<void> close() async {
    await _dataChangedSubscription.cancel();
    await _upsStatusChangedSubscription.cancel();
    return super.close();
  }

  void _onInit(Init event, Emitter<BatteryMeasurementsState> emit) {
    emit(state.copyWith(
        batteryMeasurements: _modbusDataRepository.getBatteryMeasurements()));
  }

  void _onDataChanged(
      DataChanged event, Emitter<BatteryMeasurementsState> emit) {
    emit(state.copyWith(
        batteryMeasurements: _modbusDataRepository.getBatteryMeasurements()));
  }

  void _onUpsStatusChanged(
      UpsStatusChanged event, Emitter<BatteryMeasurementsState> emit) {
    emit(state.copyWith(upsStatus: event.upsStatus));
  }
}
