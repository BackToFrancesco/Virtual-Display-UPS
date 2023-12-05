import 'dart:async';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../authentication_repository/authentication_repository.dart';
import '../modbus_data_repository/modbus_repository.dart';
import 'managers/remote_support_request_call_manager.dart';
import 'managers/remote_support_request_connection_manager.dart';
import 'models/handshaking/technician.dart';

class RemoteSupportRequestRepository {
  RemoteSupportRequestRepository(
      {required ModbusRepository modbusRepository,
        required AuthenticationRepository authenticationRepository})
      : _modbusRepository = modbusRepository,
        _authenticationRepository = authenticationRepository;

  final ModbusRepository _modbusRepository;

  final AuthenticationRepository _authenticationRepository;

  final Map<String, dynamic> _configuration = {
    'iceServers': [
      {
        'urls': [
          'stun:stun1.l.google.com:19302',
          'stun:stun2.l.google.com:19302',
        ]
      }
    ]
  };

  bool _disposed = true;

  RemoteSupportRequestConnectionManager? _connectionManager;

  RemoteSupportRequestCallManager? _callManager;

  RTCPeerConnection? _rtcPeerConnection;

  Technician? get technician => _connectionManager?.technician;

  RTCVideoRenderer get localRenderer => _callManager!.localRenderer;

  RTCVideoRenderer get remoteRenderer => _callManager!.remoteRenderer;

  Stream<RemoteSupportRequestStatus> get remoteSupportRequestStatusStream =>
      _connectionManager!.remoteSupportRequestStatusStream;

  StreamSubscription<RemoteSupportRequestStatus>?
  _remoteSupportRequestStatusSubscription;

  Stream<RemoteSupportCallMediaStatus>
  get remoteSupportMediaStatusStream async* {
    yield* _callManager!.remoteSupportMediaStatusStream;
  }

  Future<void> connectToServerAndStartHandshaking() async {
    _disposed = false;
    _rtcPeerConnection = await createPeerConnection(_configuration);
    await _initConnectionManager();
    await _initCallManager();
    _connectionManager!.connectToServerAndStartHandshaking();
  }

  Future<void> deleteRemoteSupportRequest() async {
    _connectionManager?.deleteRemoteSupportRequest();
    await dispose();
  }

  Future<void> switchCamera() async {
    await _callManager!.switchCamera();
  }

  void enablerOrDisableMic() {
    _callManager!.enablerOrDisableMic();
  }

  void enablerOrDisableVideo() {
    _callManager!.enablerOrDisableVideo();
  }

  Future<void> closeCall() async {
    await _connectionManager?.closeCall();
    await dispose();
  }

  Future<void> _initConnectionManager() async {
    _connectionManager = RemoteSupportRequestConnectionManager(
        user: _authenticationRepository.user!,
        rtcPeerConnection: _rtcPeerConnection!);
    await _connectionManager!.init();
    _remoteSupportRequestStatusSubscription =
        remoteSupportRequestStatusStream.listen((remoteSupportRequestStatus) =>
            _remoteSupportRequestStatusChanged(remoteSupportRequestStatus));
  }

  Future<void> _initCallManager() async {
    _callManager = RemoteSupportRequestCallManager(
        rtcPeerConnection: _rtcPeerConnection!,
        modbusRepository: _modbusRepository);
    await _callManager!.init();
  }

  Future<void> _remoteSupportRequestStatusChanged(
      RemoteSupportRequestStatus remoteSupportRequestStatus) async {
    if ([
      RemoteSupportRequestStatus.callClosedByTechnician,
      RemoteSupportRequestStatus.connectTimeout,
      RemoteSupportRequestStatus.serverUnreachable,
      RemoteSupportRequestStatus.disconnectedFromServer
    ].contains(remoteSupportRequestStatus)) {
      await dispose();
    } else if (remoteSupportRequestStatus ==
        RemoteSupportRequestStatus.connectedToTechnician) {
      await _callManager!.startUpdatingDataChannel();
    }
  }

  Future<void> dispose() async {
    if (!_disposed) {
      _disposed = true;
      _connectionManager = null;
      await _callManager!.dispose();
      _callManager = null;
      await _rtcPeerConnection?.close();
      await _rtcPeerConnection?.dispose();
      _rtcPeerConnection = null;
      await _remoteSupportRequestStatusSubscription?.cancel();
      _remoteSupportRequestStatusSubscription = null;
    }
  }
}
