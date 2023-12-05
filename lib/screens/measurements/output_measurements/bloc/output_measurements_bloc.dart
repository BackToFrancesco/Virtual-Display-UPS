import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../repositories/modbus_data_repository/modbus_repository.dart';
import '../../../../repositories/modbus_data_repository/models/modbus_data_manager/component_measurements/output_measurements.dart';
import '../../../../repositories/modbus_data_repository/models/modbus_data_manager/status/ups_status.dart';

part 'output_measurements_event.dart';

part 'output_measurements_state.dart';

class OutputMeasurementsBloc
    extends Bloc<OutputMeasurementsEvent, OutputMeasurementsState> {
  OutputMeasurementsBloc({
    required ModbusRepository modbusDataRepository,
  })  : _modbusDataRepository = modbusDataRepository,
        super(const OutputMeasurementsState()) {
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

  void _onInit(Init event, Emitter<OutputMeasurementsState> emit) {
    emit(state.copyWith(
        outputMeasurements: _modbusDataRepository.getOutputMeasurements()));
  }

  void _onDataChanged(
      DataChanged event, Emitter<OutputMeasurementsState> emit) {
    emit(state.copyWith(
        outputMeasurements: _modbusDataRepository.getOutputMeasurements()));
  }

  void _onUpsStatusChanged(
      UpsStatusChanged event, Emitter<OutputMeasurementsState> emit) {
    emit(state.copyWith(upsStatus: event.upsStatus));
  }
}
