import 'dart:async';
import 'dart:convert';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../modbus_data_repository/modbus_repository.dart';
import '../models/peer_data/config_data.dart';
import '../models/peer_data/media_status_data.dart';
import '../models/peer_data/message.dart';
import '../models/peer_data/ups_connection_status_data.dart';
import '../models/peer_data/ups_data.dart';

enum RemoteSupportCallMediaStatus {
  technicianMicEnabled,
  technicianMicDisabled,
  technicianVideoEnabled,
  technicianVideoDisabled,
}

class RemoteSupportRequestCallManager {
  final ModbusRepository _modbusRepository;

  final RTCPeerConnection _rtcPeerConnection;

  late final RTCDataChannel _dataChannel;

  Timer? _timer;

  late final MediaStream _localStream;
  MediaStream? _remoteStream;

  late final RTCVideoRenderer localRenderer = RTCVideoRenderer();
  late final RTCVideoRenderer remoteRenderer = RTCVideoRenderer();

  bool _isFrontCamera = true;

  bool _isMicEnabled = true;

  bool _isVideoEnabled = true;

  bool _configDataSent = false;

  bool _connectedToUps = false;

  final StreamController<RemoteSupportCallMediaStatus>
      _remoteSupportCallMediaStatusController =
      StreamController<RemoteSupportCallMediaStatus>.broadcast();

  Stream<RemoteSupportCallMediaStatus>
      get remoteSupportMediaStatusStream async* {
    yield* _remoteSupportCallMediaStatusController.stream.asBroadcastStream();
  }

  late final List<MediaDeviceInfo> _mediaDevices;

  RemoteSupportRequestCallManager(
      {required RTCPeerConnection rtcPeerConnection,
      required ModbusRepository modbusRepository})
      : _rtcPeerConnection = rtcPeerConnection,
        _modbusRepository = modbusRepository;

  Future<void> init() async {
    _dataChannel = await _rtcPeerConnection.createDataChannel(
        'data-channel', RTCDataChannelInit());

    _dataChannel.onMessage = (message) => onDataChannelMessage(message);

    await initRenderers();
    await openUserMedia();

    _mediaDevices = await Helper.cameras;

    _rtcPeerConnection.onAddStream = (MediaStream stream) {
      _remoteStream = stream;
      remoteRenderer.srcObject = _remoteStream;
    };

    _rtcPeerConnection.onTrack = (RTCTrackEvent event) {
      event.streams[0].getTracks().forEach((track) {
        _remoteStream?.addTrack(track);
      });
    };

    _localStream.getTracks().forEach((track) {
      _rtcPeerConnection.addTrack(track, _localStream);
    });
  }

  void onDataChannelMessage(RTCDataChannelMessage message) {
    if (message.type == MessageType.text) {
      Map<String, dynamic> json = jsonDecode(message.text);
      if (json["type"] == "mediaStatus") {
        MediaStatusData technicianMediaStatus =
            MediaStatusData.fromJson(json['data']);
        if (technicianMediaStatus.isMicEnabled == true) {
          _remoteSupportCallMediaStatusController
              .add(RemoteSupportCallMediaStatus.technicianMicEnabled);
        } else if (technicianMediaStatus.isMicEnabled == false) {
          _remoteSupportCallMediaStatusController
              .add(RemoteSupportCallMediaStatus.technicianMicDisabled);
        } else if (technicianMediaStatus.isVideoEnabled == true) {
          _remoteSupportCallMediaStatusController
              .add(RemoteSupportCallMediaStatus.technicianVideoEnabled);
        } else if (technicianMediaStatus.isVideoEnabled == false) {
          _remoteSupportCallMediaStatusController
              .add(RemoteSupportCallMediaStatus.technicianVideoDisabled);
        }
      }
    }
  }

  Future<void> initRenderers() async {
    await localRenderer.initialize();
    await remoteRenderer.initialize();
  }

  Future<void> openUserMedia() async {
    _localStream = await navigator.mediaDevices
        .getUserMedia({'video': true, 'audio': true});
    localRenderer.srcObject = _localStream;
  }

  Future<void> startUpdatingDataChannel() async {
    if (_timer == null || !_timer!.isActive) {
      _timer = Timer.periodic(
          const Duration(seconds: 1), (Timer t) => _updateData());
    }
  }

  Future<void> _updateData() async {
    if (_modbusRepository.connected) {
      try {
        if (!_connectedToUps) {
          _connectedToUps = true;
          _configDataSent = false;
          _sendUpsConnectionStatusData(upsConnectionStatus: "connected");
        }
        if (!_configDataSent) {
          _sendConfigData();
          _configDataSent = true;
        }
        _sendUpsData();
      } catch (e) {
        _connectedToUps = false;
        _configDataSent = false;
        _sendUpsConnectionStatusData(upsConnectionStatus: "disconnected");
      }
    } else {
      if (_connectedToUps) {
        _sendUpsConnectionStatusData(upsConnectionStatus: "disconnected");
        _connectedToUps = false;
        _configDataSent = false;
      }
    }
  }

  void _sendConfigData() {
    _dataChannel.send(RTCDataChannelMessage(jsonEncode(Message(
            type: "config",
            data: ConfigData(
                mcmt: _modbusRepository.getRawMcmtFrame()!,
                format: _modbusRepository.getMeasurementsFormatValue()!))
        .toJson())));
  }

  void _sendUpsData() {
    _dataChannel.send(RTCDataChannelMessage(jsonEncode(Message(
            type: "data",
            data: UpsData(
                states: _modbusRepository.getRawStatesFrame()!,
                alarms: _modbusRepository.getRawAlarmsFrame()!,
                measurements: _modbusRepository.getRawMeasurementsFrame()!,
                isBatteryPresent: _modbusRepository.getBatPresent()!,
                isBypassPresent: !_modbusRepository.getNoBypass()!))
        .toJson())));
  }

  void _sendUpsConnectionStatusData({required String upsConnectionStatus}) {
    _dataChannel.send(RTCDataChannelMessage(jsonEncode(Message(
            type: "upsConnectionStatus",
            data: UpsConnectionStatusData(
                upsConnectionStatus: upsConnectionStatus))
        .toJson())));
  }

  Future<void> switchCamera() async {
    if (_mediaDevices.length > 1) {
      MediaStreamTrack value = _localStream.getVideoTracks()[0];
      await Helper.switchCamera(
        value,
        _isFrontCamera
            ? _mediaDevices.first.deviceId
            : _mediaDevices[1].deviceId,
      );
      _isFrontCamera = !_isFrontCamera;
    }
  }

  void enablerOrDisableMic() {
    _isMicEnabled = !_isMicEnabled;

    _localStream
        .getAudioTracks()
        .forEach((track) => track.enabled = !track.enabled);

    _dataChannel.send(RTCDataChannelMessage(jsonEncode(Message(
            type: "mediaStatus",
            data: MediaStatusData(isMicEnabled: _isMicEnabled))
        .toJson())));
  }

  void enablerOrDisableVideo() {
    _isVideoEnabled = !_isVideoEnabled;

    _localStream
        .getVideoTracks()
        .forEach((track) => track.enabled = !track.enabled);

    _dataChannel.send(RTCDataChannelMessage(jsonEncode(Message(
            type: "mediaStatus",
            data: MediaStatusData(isVideoEnabled: _isVideoEnabled))
        .toJson()
        .toString())));
  }

  Future<void> dispose() async {
    await _remoteSupportCallMediaStatusController.close();
    _timer?.cancel();
    await _dataChannel.close();
    await _localStream.dispose();
    await _remoteStream?.dispose();
  }
}
