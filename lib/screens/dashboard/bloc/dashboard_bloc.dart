import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../repositories/modbus_data_repository/modbus_repository.dart';
import '../../../repositories/modbus_data_repository/models/modbus_data_manager/status/ups_status.dart';
import '../../../repositories/modbus_data_repository/models/modbus_data_manager/synoptic/synoptic.dart';

part 'dashboard_event.dart';

part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc({
    required ModbusRepository modbusDataRepository,
  })  : _modbusDataRepository = modbusDataRepository,
        super(const DashboardState()) {
    on<UpsStatusChanged>(_onUpsStatusChanged);
    on<SynopticChanged>(_onSynopticChanged);

    _upsStatusChangedSubscription = _modbusDataRepository.upsStatusStream
        .listen((upsStatus) => add(UpsStatusChanged(upsStatus)));

    _synopticChangedSubscription = modbusDataRepository.synopticStatusStream
        .listen((synoptic) => add(SynopticChanged(synoptic)));
  }

  final ModbusRepository _modbusDataRepository;

  late StreamSubscription<UpsStatus> _upsStatusChangedSubscription;

  late StreamSubscription<Synoptic> _synopticChangedSubscription;

  @override
  Future<void> close() async {
    await _upsStatusChangedSubscription.cancel();
    await _synopticChangedSubscription.cancel();
    return super.close();
  }

  void _onUpsStatusChanged(
      UpsStatusChanged event, Emitter<DashboardState> emit) {
    emit(state.copyWith(upsStatus: event.upsStatus));
  }

  void _onSynopticChanged(SynopticChanged event, Emitter<DashboardState> emit) {
    emit(state.copyWith(synoptic: event.synoptic));
  }
}
