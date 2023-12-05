import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../repositories/modbus_data_repository/utils/utils.dart' as utils;
import '../../repositories/remote_support_request_repository/managers/remote_support_request_call_manager.dart';
import '../../repositories/remote_support_request_repository/managers/remote_support_request_connection_manager.dart';
import '../../repositories/remote_support_request_repository/models/handshaking/technician.dart';
import '../../repositories/remote_support_request_repository/remote_support_request_repository.dart';

part 'remote_support_request_event.dart';

part 'remote_support_request_state.dart';

class RemoteSupportRequestBloc
    extends Bloc<RemoteSupportRequestEvent, RemoteSupportRequestState> {
  RemoteSupportRequestBloc(
      {required RemoteSupportRequestRepository remoteSupportRequestRepository})
      : super(const RemoteSupportRequestState()) {
    _remoteSupportRequestRepository = remoteSupportRequestRepository;

    on<RemoteSupportMediaStatusChanged>(_onRemoteSupportMediaStatusChanged);
    on<RemoteSupportRequestStatusChanged>(_onRemoteSupportRequestStatusChanged);
    on<StopwatchUpdated>(_onStopwatchUpdated);
    on<WaitingDotsUpdated>(_onWaitingDotsUpdated);
    on<QueueUp>(_onQueueUp);
    on<DeleteRemoteSupportRequest>(_onDeleteRemoteSupportRequest);
    on<SwitchCamera>(_onSwitchCamera);
    on<EnableOrDisableMic>(_onEnableOrDisableMic);
    on<EnableOrDisableVideo>(_onEnableOrDisableVideo);
    on<CloseCall>(_onCloseCall);
  }

  Timer? _timerStopwatch;

  Timer? _timerWaitingDots;

  int _stopwatch = 0;

  int _waitingDotsCount = 0;

  late final RemoteSupportRequestRepository _remoteSupportRequestRepository;

  StreamSubscription<RemoteSupportRequestStatus>?
  _remoteSupportRequestStatusSubscription;

  StreamSubscription<RemoteSupportCallMediaStatus>?
  _remoteSupportCallMediaStatusSubscription;

  Technician? get technician => _remoteSupportRequestRepository.technician;

  RTCVideoRenderer get localRenderer =>
      _remoteSupportRequestRepository.localRenderer;

  RTCVideoRenderer get remoteRenderer =>
      _remoteSupportRequestRepository.remoteRenderer;

  @override
  Future<void> close() async {
    _timerStopwatch?.cancel();
    _timerWaitingDots?.cancel();
    await _remoteSupportCallMediaStatusSubscription?.cancel();
    await _remoteSupportRequestStatusSubscription?.cancel();
    await _remoteSupportRequestRepository.dispose();
    return super.close();
  }

  Future<void> _onQueueUp(
      QueueUp event, Emitter<RemoteSupportRequestState> emit) async {
    await _remoteSupportRequestRepository.connectToServerAndStartHandshaking();
    _remoteSupportRequestStatusSubscription = _remoteSupportRequestRepository
        .remoteSupportRequestStatusStream
        .listen((status) => add(RemoteSupportRequestStatusChanged(status)));
    _remoteSupportCallMediaStatusSubscription = _remoteSupportRequestRepository
        .remoteSupportMediaStatusStream
        .listen((status) => add(RemoteSupportMediaStatusChanged(status)));
  }

  void _onRemoteSupportMediaStatusChanged(RemoteSupportMediaStatusChanged event,
      Emitter<RemoteSupportRequestState> emit) {
    switch (event.remoteSupportCallMediaStatus) {
      case RemoteSupportCallMediaStatus.technicianMicEnabled:
        emit(state.copyWith(technicianMicEnabled: true));
        break;
      case RemoteSupportCallMediaStatus.technicianMicDisabled:
        emit(state.copyWith(technicianMicEnabled: false));
        break;
      case RemoteSupportCallMediaStatus.technicianVideoEnabled:
        emit(state.copyWith(technicianVideoEnabled: true));
        break;
      case RemoteSupportCallMediaStatus.technicianVideoDisabled:
        emit(state.copyWith(technicianVideoEnabled: false));
    }
  }

  Future<void> _onRemoteSupportRequestStatusChanged(
      RemoteSupportRequestStatusChanged event,
      Emitter<RemoteSupportRequestState> emit) async {
    switch (event.remoteSupportRequestsStatus) {
      case RemoteSupportRequestStatus.disconnectedFromServer:
        emit(state.copyWith(
            requestStatus: event.remoteSupportRequestsStatus,
            errorTitle: "Disconnected from server",
            errorDescription: "You have disconnected from the server"));
        _resetWaitingDots();
        _resetStopwatch();
        await _remoteSupportCallMediaStatusSubscription?.cancel();
        await _remoteSupportRequestStatusSubscription?.cancel();
        break;
      case RemoteSupportRequestStatus.serverUnreachable:
        emit(state.copyWith(
            requestStatus: event.remoteSupportRequestsStatus,
            errorTitle: "Server unreachable",
            errorDescription: "Unable to connect to the server"));
        await _remoteSupportCallMediaStatusSubscription?.cancel();
        await _remoteSupportRequestStatusSubscription?.cancel();
        break;
      case RemoteSupportRequestStatus.connectTimeout:
        emit(state.copyWith(
            requestStatus: event.remoteSupportRequestsStatus,
            errorTitle: "Connection timeout",
            errorDescription:
            "Timeout was reached during the connection to the server"));
        await _remoteSupportCallMediaStatusSubscription?.cancel();
        await _remoteSupportRequestStatusSubscription?.cancel();
        break;
      case RemoteSupportRequestStatus.connectedToServer:
        emit(state.copyWith(requestStatus: event.remoteSupportRequestsStatus));
        _startStopwatch();
        _startWaitingDots();
        break;
      case RemoteSupportRequestStatus.connectingToServer:
        emit(state.copyWith(requestStatus: event.remoteSupportRequestsStatus));
        break;
      case RemoteSupportRequestStatus.connectedToTechnician:
        emit(state.copyWith(requestStatus: event.remoteSupportRequestsStatus));
        _resetWaitingDots();
        _resetStopwatch();
        _startStopwatch();
        break;
      case RemoteSupportRequestStatus.noTechniciansAvailable:
        emit(state.copyWith(requestStatus: event.remoteSupportRequestsStatus));
        break;
      case RemoteSupportRequestStatus.callClosedByTechnician:
        emit(state.copyWith(requestStatus: event.remoteSupportRequestsStatus));
        _resetStopwatch();
        await _remoteSupportCallMediaStatusSubscription?.cancel();
        await _remoteSupportRequestStatusSubscription?.cancel();
        break;
      case RemoteSupportRequestStatus.callClosedByCustomer:
        emit(state.copyWith(requestStatus: event.remoteSupportRequestsStatus));
        _resetStopwatch();
        await _remoteSupportCallMediaStatusSubscription?.cancel();
        await _remoteSupportRequestStatusSubscription?.cancel();
    }
  }

  Future<void> _onSwitchCamera(
      SwitchCamera event, Emitter<RemoteSupportRequestState> emit) async {
    await _remoteSupportRequestRepository.switchCamera();
  }

  void _onEnableOrDisableMic(
      EnableOrDisableMic event, Emitter<RemoteSupportRequestState> emit) {
    _remoteSupportRequestRepository.enablerOrDisableMic();
    emit(state.copyWith(micEnabled: !state.micEnabled));
  }

  void _onEnableOrDisableVideo(
      EnableOrDisableVideo event, Emitter<RemoteSupportRequestState> emit) {
    _remoteSupportRequestRepository.enablerOrDisableVideo();
    emit(state.copyWith(videoEnabled: !state.videoEnabled));
  }

  Future<void> _onCloseCall(
      CloseCall event, Emitter<RemoteSupportRequestState> emit) async {
    _resetStopwatch();
    await _remoteSupportRequestRepository.closeCall();
    emit(state.copyWith(
        micEnabled: true,
        videoEnabled: true,
        technicianMicEnabled: true,
        technicianVideoEnabled: true));
  }

  Future<void> _onDeleteRemoteSupportRequest(DeleteRemoteSupportRequest event,
      Emitter<RemoteSupportRequestState> emit) async {
    await _remoteSupportRequestRepository.deleteRemoteSupportRequest();
    await _remoteSupportCallMediaStatusSubscription?.cancel();
    await _remoteSupportRequestStatusSubscription?.cancel();
    _resetWaitingDots();
    _resetStopwatch();
  }

  void _onWaitingDotsUpdated(
      WaitingDotsUpdated event, Emitter<RemoteSupportRequestState> emit) {
    _waitingDotsCount = _waitingDotsCount == 3 ? 0 : ++_waitingDotsCount;
    emit(state.copyWith(waitingDots: '.' * _waitingDotsCount));
  }

  _resetWaitingDots() {
    _waitingDotsCount = -1;
    _timerWaitingDots?.cancel();
    _timerWaitingDots = null;
    add(const WaitingDotsUpdated());
  }

  void _startWaitingDots() {
    if (_timerWaitingDots == null || !_timerWaitingDots!.isActive) {
      _timerWaitingDots =
          Timer.periodic(const Duration(milliseconds: 500), (Timer t) {
            add(const WaitingDotsUpdated());
          });
    }
  }

  void _onStopwatchUpdated(
      StopwatchUpdated event, Emitter<RemoteSupportRequestState> emit) {
    _stopwatch++;
    emit(state.copyWith(stopwatch: _stopwatchToString()));
  }

  void _resetStopwatch() {
    _stopwatch = -1;
    _timerStopwatch?.cancel();
    _timerStopwatch = null;
    add(const StopwatchUpdated());
  }

  void _startStopwatch() {
    if (_timerStopwatch == null || !_timerStopwatch!.isActive) {
      _timerStopwatch = Timer.periodic(const Duration(seconds: 1), (Timer t) {
        add(const StopwatchUpdated());
      });
    }
  }

  String _stopwatchToString() {
    int temp = _stopwatch;
    String hours =
    utils.fillStringPaddingLeft((temp ~/ 3600).toString(), 2, "0");
    temp %= 3600;
    String minutes =
    utils.fillStringPaddingLeft((temp ~/ 60).toString(), 2, "0");
    temp %= 60;
    String seconds = utils.fillStringPaddingLeft(temp.toString(), 2, "0");
    if (hours != '00') {
      return "$hours:$minutes:$seconds";
    }
    return "$minutes:$seconds";
  }
}
