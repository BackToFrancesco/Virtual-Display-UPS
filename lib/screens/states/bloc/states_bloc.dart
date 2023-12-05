import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../repositories/modbus_data_repository/modbus_repository.dart';
import '../../../repositories/modbus_data_repository/models/modbus_data_manager/status/ups_status.dart';

part 'states_event.dart';

part 'states_state.dart';

class StatesBloc extends Bloc<StatesEvent, StatesState> {
  StatesBloc({
    required ModbusRepository modbusDataRepository,
  })  : _modbusDataRepository = modbusDataRepository,
        super(const StatesState()) {
    on<Init>(_onInit);
    on<UpsStatusChanged>(_onUpsStatusChanged);
    on<DataChanged>(_onDataChanged);

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

  void _onInit(Init event, Emitter<StatesState> emit) {
    emit(state.copyWith(states: _modbusDataRepository.getStates()));
  }

  void _onDataChanged(DataChanged event, Emitter<StatesState> emit) {
    emit(state.copyWith(states: _modbusDataRepository.getStates()));
  }

  void _onUpsStatusChanged(UpsStatusChanged event, Emitter<StatesState> emit) {
    emit(state.copyWith(upsStatus: event.upsStatus));
  }
}
