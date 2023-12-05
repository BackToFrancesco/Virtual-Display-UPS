import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:socket_io_client/socket_io_client.dart';
import '../../authentication_repository/models/user.dart';
import '../models/handshaking/accept_call.dart';
import '../models/handshaking/client_ice_candidate.dart';
import '../models/handshaking/client_offer.dart';
import '../models/handshaking/close_call.dart';
import '../models/handshaking/start_call.dart';
import '../models/handshaking/technician.dart';
import '../models/handshaking/technician_ice_candidate.dart';
import '../models/handshaking/technician_offer.dart';

enum RemoteSupportRequestStatus {
  connectTimeout,
  serverUnreachable,
  noTechniciansAvailable,
  disconnectedFromServer,
  connectedToServer,
  connectingToServer,
  connectedToTechnician,
  callClosedByTechnician,
  callClosedByCustomer
}

class RemoteSupportRequestConnectionManager {
  RemoteSupportRequestConnectionManager(
      {required User user, required RTCPeerConnection rtcPeerConnection})
      : _user = user,
        _rtcPeerConnection = rtcPeerConnection;

  final Map<String, dynamic> _constraints = {
    'mandatory': {
      'OfferToReceiveAudio': true,
      'OfferToReceiveVideo': true,
    },
    'optional': [],
  };

  final User _user;

  Technician? _technician;

  late final Socket socket;

  late final RTCPeerConnection _rtcPeerConnection;

  Technician? get technician => _technician;

  bool _callClosedByTechnician = false;

  final StreamController<RemoteSupportRequestStatus>
  _remoteSupportRequestStatusController =
  StreamController<RemoteSupportRequestStatus>.broadcast();

  Stream<RemoteSupportRequestStatus>
  get remoteSupportRequestStatusStream async* {
    yield* _remoteSupportRequestStatusController.stream.asBroadcastStream();
  }

  Future<void> init() async {
    await rootBundle.loadString('global_vars.env');
    socket = io(
        dotenv.get('SIGNALING_SERVER'),
        OptionBuilder()
            .disableReconnection()
            .disableAutoConnect()
            .setTransports(['websocket']).setQuery({
          "id": _user.id,
          "name": _user.name,
          "surname": _user.surname,
          "email": _user.email,
          "phoneNumber": _user.phoneNumber,
          "isCustomer": true
        }).build());

    socket.onConnect((_) {
      _remoteSupportRequestStatusController
          .add(RemoteSupportRequestStatus.connectedToServer);
      _startHandshaking();
    });

    socket.onDisconnect((_) async {
      if (!_callClosedByTechnician) {
        //_remoteSupportRequestStatusController
        //    .add(RemoteSupportRequestStatus.disconnectedFromServer);
        await _dispose();
      }
    });

    socket.onConnectTimeout((_) {
      _remoteSupportRequestStatusController
          .add(RemoteSupportRequestStatus.connectTimeout);
    });

    socket.onConnectError((_) {
      _remoteSupportRequestStatusController
          .add(RemoteSupportRequestStatus.serverUnreachable);
    });

    socket.onError((_) async {
      if (socket.connected &&
          _rtcPeerConnection.connectionState ==
              RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        emit("close-call", CloseCall(from: _user, to: _technician!).toJson());
      }
      //_remoteSupportRequestStatusController
      //    .add(RemoteSupportRequestStatus.disconnectedFromServer);
      await _dispose();
    });

    socket.on('refuse-call', (data) => _onRefuseCall());

    socket.on('no-technicians', (data) => _onNoTechniciansAvailable());

    socket.on('accept-call', (data) async => await _onAcceptCall(data));

    socket.on(
        'technician-offer', (data) async => await _onTechnicianOffer(data));

    socket.on('technician-ice-candidate',
            (data) async => await _onTechnicianIceCandidate(data));

    socket.on('close-call', (data) => _onCloseCall(data));

    _rtcPeerConnection.onIceCandidate =
        (RTCIceCandidate candidate) => _onIceCandidate(candidate);
  }

  void connectToServerAndStartHandshaking() {
    _remoteSupportRequestStatusController
        .add(RemoteSupportRequestStatus.connectingToServer);
    socket.connect();
  }

  void _startHandshaking() {
    if (socket.connected) {
      emit("start-call", StartCall(from: _user).toJson());
    }
  }

  Future<void> _onRefuseCall() async {
    _startHandshaking();
  }

  void _onNoTechniciansAvailable() {
    _remoteSupportRequestStatusController
        .add(RemoteSupportRequestStatus.noTechniciansAvailable);
    Future.delayed(const Duration(seconds: 15), () => _startHandshaking());
  }

  Future<void> _onAcceptCall(dynamic data) async {
    final AcceptCall acceptCall = AcceptCall.fromJson(data);
    _technician = acceptCall.from;
    RTCSessionDescription offer =
    await _rtcPeerConnection.createOffer(_constraints);
    await _rtcPeerConnection.setLocalDescription(offer);
    socket.emit('client-offer',
        ClientOffer(from: _user, to: _technician!, offer: offer).toJson());
  }

  Future<void> _onTechnicianOffer(dynamic data) async {
    final TechnicianOffer technicianOffer = TechnicianOffer.fromJson(data);
    await _rtcPeerConnection.setRemoteDescription(RTCSessionDescription(
        technicianOffer.answer.sdp, technicianOffer.answer.type));
  }

  void _onIceCandidate(RTCIceCandidate candidate) {
    socket.emit(
        'client-ice-candidate',
        ClientIceCandidate(from: _user, to: _technician!, candidate: candidate)
            .toJson());
  }

  Future<void> _onTechnicianIceCandidate(dynamic data) async {
    TechnicianIceCandidate technicianIceCandidate =
    TechnicianIceCandidate.fromJson(data);
    await _rtcPeerConnection.addCandidate(RTCIceCandidate(
        technicianIceCandidate.candidate.candidate,
        technicianIceCandidate.candidate.sdpMid,
        technicianIceCandidate.candidate.sdpMLineIndex));
    _remoteSupportRequestStatusController
        .add(RemoteSupportRequestStatus.connectedToTechnician);
  }

  Future<void> _onCloseCall(dynamic data) async {
    _callClosedByTechnician = true;
    _remoteSupportRequestStatusController
        .add(RemoteSupportRequestStatus.callClosedByTechnician);
    await _dispose();
  }

  Future<void> closeCall() async {
    if (socket.connected &&
        _rtcPeerConnection.connectionState ==
            RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
      emit("close-call", CloseCall(from: _user, to: _technician!));
    }
    _remoteSupportRequestStatusController
        .add(RemoteSupportRequestStatus.callClosedByCustomer);
    await _dispose();
  }

  Future<void> deleteRemoteSupportRequest() async {
    emit("close-call", CloseCall(from: _user, to: _technician!));
    await _dispose();
  }

  void emit(String event, dynamic data) {
    if (socket.connected) {
      socket.emit(event, data);
    }
  }

  Future<void> _dispose() async {
    if (socket.connected) {
      socket.disconnect();
    }
    _technician = null;
    //await _remoteSupportRequestStatusController.close();
  }
}
