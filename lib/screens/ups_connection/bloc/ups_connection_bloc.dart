import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../blocs/ups_connection_handler_bloc/ups_connection_handler_bloc.dart';
import '../../../utils/shared_preferences_global.dart'
    as shared_preferences_global;
import '../../../utils/translator.dart';
import '../models/ip_address.dart';
import '../models/port.dart';
import '../models/slave_id.dart';

part 'ups_connection_event.dart';

part 'ups_connection_state.dart';

class UpsConnectionBloc extends Bloc<UpsConnectionEvent, UpsConnectionState> {
  UpsConnectionBloc({required this.upsConnectionHandlerBloc})
      : super(const UpsConnectionState()) {
    on<IpAddressChanged>(_onIpAddressChanged);
    on<PortChanged>(_onPortChanged);
    on<SlaveIdChanged>(_onSlaveIdChanged);
    on<Submitted>(_onSubmitted);
    on<SubmittedFromRecentConnections>(_onSubmittedFromRecentConnections);
    on<SubmissionFailure>(_onSubmissionFailure);
    on<SubmissionSuccess>(_onSubmissionSuccess);
  }

  final UpsConnectionHandlerBloc upsConnectionHandlerBloc;

  void _onSubmissionSuccess(
      SubmissionSuccess event, Emitter<UpsConnectionState> emit) {
    final SharedPreferences prefs = shared_preferences_global.sharedPreferences;
    prefs.setBool('firstLaunch', false);
    prefs.setString("language", Translator().targetLanguage);
    _updateRecentConnections(
        state.ipAddress.value, state.port.value, state.slaveId.value);
    emit(state.copyWith(status: FormzStatus.submissionSuccess));
  }

  void _onSubmissionFailure(
      SubmissionFailure event, Emitter<UpsConnectionState> emit) {
    emit(state.copyWith(status: FormzStatus.submissionFailure));
  }

  void _onSubmittedFromRecentConnections(
      SubmittedFromRecentConnections event, Emitter<UpsConnectionState> emit) {
    final SharedPreferences prefs = shared_preferences_global.sharedPreferences;
    List<String> upsInfo = prefs.getStringList(
            prefs.getStringList("recentConnections")![event.index]) ??
        [];
    emit(state.copyWith(
        ipAddress: IpAddress.dirty(upsInfo[0]),
        port: Port.dirty(upsInfo[1]),
        slaveId: SlaveId.dirty(upsInfo[2]),
        status: FormzStatus.submissionInProgress,
        fromRecentConnections: true));
    upsConnectionHandlerBloc
        .add(ConnectToUps(upsInfo[0], upsInfo[1], upsInfo[2]));
  }

  void _onSubmitted(Submitted event, Emitter<UpsConnectionState> emit) {
    emit(state.copyWith(
        status: FormzStatus.submissionInProgress,
        fromRecentConnections: false));
    if (state.status.isValidated) {
      upsConnectionHandlerBloc.add(ConnectToUps(
          state.ipAddress.value, state.port.value, state.slaveId.value));
    }
  }

  void _onIpAddressChanged(
      IpAddressChanged event, Emitter<UpsConnectionState> emit) {
    final ipAddress = IpAddress.dirty(event.ipAddress);
    emit(state.copyWith(
        ipAddress: ipAddress,
        status: Formz.validate([ipAddress, state.port, state.slaveId]),
        fromRecentConnections: false));
  }

  void _onPortChanged(PortChanged event, Emitter<UpsConnectionState> emit) {
    final port = Port.dirty(event.port);
    emit(state.copyWith(
        port: port,
        status: Formz.validate([state.ipAddress, port, state.slaveId]),
        fromRecentConnections: false));
  }

  void _onSlaveIdChanged(
      SlaveIdChanged event, Emitter<UpsConnectionState> emit) {
    final slaveId = SlaveId.dirty(event.slaveId);
    emit(state.copyWith(
        slaveId: slaveId,
        status: Formz.validate([state.ipAddress, state.port, slaveId]),
        fromRecentConnections: false));
  }

  Future<void> _updateRecentConnections(
      String ipAddress, String port, String slaveId) async {
    final SharedPreferences prefs = shared_preferences_global.sharedPreferences;

    List<String> recentConnections =
        prefs.getStringList("recentConnections") ?? [];

    int? lastUpsConnectionIndex;

    for (int i = 0; i < recentConnections.length; i++) {
      List<String> current = prefs.getStringList(i.toString())!;
      if (current[0] == ipAddress &&
          current[1] == port &&
          current[2] == slaveId) {
        lastUpsConnectionIndex = i;
        break;
      }
    }

    if (lastUpsConnectionIndex != null) {
      recentConnections.remove(lastUpsConnectionIndex.toString());
    } else {
      lastUpsConnectionIndex = recentConnections.length;
      await prefs.setStringList(
          lastUpsConnectionIndex.toString(), [ipAddress, port, slaveId]);
    }
    recentConnections = [lastUpsConnectionIndex.toString()] + recentConnections;
    await prefs.setStringList("recentConnections", recentConnections);
  }
}
