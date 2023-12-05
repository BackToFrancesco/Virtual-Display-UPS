import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/modbus_data_repository/modbus_repository.dart';
import '../../repositories/modbus_data_repository/models/modbus/ups_info.dart';
import '../../repositories/modbus_data_repository/models/modbus_connection_manager/modbus_connection_manager.dart';

part 'ups_connection_handler_event.dart';

part 'ups_connection_handler_state.dart';

class UpsConnectionHandlerBloc
    extends Bloc<UpsConnectionHandlerEvent, UpsConnectionHandlerState> {
  UpsConnectionHandlerBloc({required ModbusRepository modbusDataRepository})
      : super(const UpsConnectionHandlerState()) {
    _modbusDataRepository = modbusDataRepository;

    _upsConnectionStatusSubscription = modbusDataRepository
        .connectionStatusStream
        .listen((status) => add(UpsConnectionStatusChanged(status)));

    on<UpsConnectionStatusChanged>(_onUpsConnectionStatusChanged);
    on<DisconnectFromUps>(_onDisconnectFromUps);
    on<ConnectToUps>(_onConnectToUps);
    on<ReconnectToUps>(_onReconnectToUps);
  }

  late final ModbusRepository _modbusDataRepository;

  late StreamSubscription<UpsConnectionStatus> _upsConnectionStatusSubscription;

  UpsInfo get upsInfo => _modbusDataRepository.upsInfo;

  bool get connected => _modbusDataRepository.connected;

  @override
  Future<void> close() async {
    await _upsConnectionStatusSubscription.cancel();
    await _modbusDataRepository.dispose();
    return super.close();
  }

  Future<void> _onConnectToUps(
      ConnectToUps event, Emitter<UpsConnectionHandlerState> emit) async {
    await _modbusDataRepository.setMaster(
        event.ipAddress, int.parse(event.port), int.parse(event.slaveId));
    await _modbusDataRepository.connectMaster();
  }

  Future<void> _onReconnectToUps(
      ReconnectToUps event, Emitter<UpsConnectionHandlerState> emit) async {
    await _modbusDataRepository.connectMaster();
  }

  Future<void> _onDisconnectFromUps(
      DisconnectFromUps event, Emitter<UpsConnectionHandlerState> emit) async {
    await _modbusDataRepository.closeMaster();
  }

  void _onUpsConnectionStatusChanged(UpsConnectionStatusChanged event,
      Emitter<UpsConnectionHandlerState> emit) {
    switch (event.upsConnectionStatus) {
      case UpsConnectionStatus.connected:
        emit(state.copyWith(upsConnectionStatus: event.upsConnectionStatus));
        break;
      case UpsConnectionStatus.unableToConnect:
        emit(state.copyWith(
            upsConnectionStatus: event.upsConnectionStatus,
            errorTitle: 'Unable to connect',
            errorDescription:
                'Cannot reach ${_modbusDataRepository.upsInfo.ipAddress}:${_modbusDataRepository.upsInfo.port}. '
                'Make sure you are connected to the same wifi network as the UPS and check the IP address and port'));
        break;
      case UpsConnectionStatus.unableToCommunicate:
        emit(state.copyWith(
            upsConnectionStatus: event.upsConnectionStatus,
            errorTitle: 'Unable to communicate',
            errorDescription: 'Bad slave id'));
        break;
      case UpsConnectionStatus.unableToVerifyTheSlaveId:
        emit(state.copyWith(
            upsConnectionStatus: event.upsConnectionStatus,
            errorTitle: 'Unable to verify the slave id',
            errorDescription:
                'An error occurred during the verify of the slave id'));
        break;
      case UpsConnectionStatus.reconnecting:
        emit(state.copyWith(upsConnectionStatus: event.upsConnectionStatus));
        break;
      case UpsConnectionStatus.disconnected:
        emit(state.copyWith(upsConnectionStatus: event.upsConnectionStatus));
        break;
      case UpsConnectionStatus.disconnectedDueToConnectorError:
        emit(state.copyWith(
            upsConnectionStatus: event.upsConnectionStatus,
            errorTitle: 'Disconnected from UPS',
            errorDescription:
                'You disconnected from the UPS due to a connector error'));
        break;
      case UpsConnectionStatus.disconnectedDueToIllegalFunction:
        emit(state.copyWith(
            upsConnectionStatus: event.upsConnectionStatus,
            errorTitle: 'Disconnected from UPS',
            errorDescription:
                'You disconnected from the UPS due to an illegal function request'));
        break;
      case UpsConnectionStatus.disconnectedDueToIllegalAddress:
        emit(state.copyWith(
            upsConnectionStatus: event.upsConnectionStatus,
            errorTitle: 'Disconnected from UPS',
            errorDescription:
                'You disconnected from the UPS due to an illegal address request'));
        break;
      case UpsConnectionStatus.disconnectedDueToInvalidData:
        emit(state.copyWith(
            upsConnectionStatus: event.upsConnectionStatus,
            errorTitle: 'Disconnected from UPS',
            errorDescription:
                'You disconnected from the UPS due to invalid data received'));
        break;
      case UpsConnectionStatus.disconnectedDueToUnknownErrorCode:
        emit(state.copyWith(
            upsConnectionStatus: event.upsConnectionStatus,
            errorTitle: 'Disconnected from UPS',
            errorDescription:
                'You disconnected from the UPS due to an unknown error code'));
    }
  }
}
