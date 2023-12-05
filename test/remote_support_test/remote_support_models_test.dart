import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:virtual_display/repositories/authentication_repository/models/user.dart';
import 'package:virtual_display/repositories/remote_support_request_repository/models/handshaking/accept_call.dart';
import 'package:virtual_display/repositories/remote_support_request_repository/models/handshaking/answer.dart';
import 'package:virtual_display/repositories/remote_support_request_repository/models/handshaking/client_ice_candidate.dart';
import 'package:virtual_display/repositories/remote_support_request_repository/models/handshaking/client_offer.dart';
import 'package:virtual_display/repositories/remote_support_request_repository/models/handshaking/close_call.dart';
import 'package:virtual_display/repositories/remote_support_request_repository/models/handshaking/ice_candidate.dart';
import 'package:virtual_display/repositories/remote_support_request_repository/models/handshaking/start_call.dart';

import 'package:virtual_display/repositories/remote_support_request_repository/models/handshaking/technician.dart';
import 'package:virtual_display/repositories/remote_support_request_repository/models/handshaking/technician_ice_candidate.dart';
import 'package:virtual_display/repositories/remote_support_request_repository/models/handshaking/technician_offer.dart';
import 'package:virtual_display/repositories/remote_support_request_repository/models/peer_data/config_data.dart';
import 'package:virtual_display/repositories/remote_support_request_repository/models/peer_data/media_status_data.dart';
import 'package:virtual_display/repositories/remote_support_request_repository/models/peer_data/message.dart';
import 'package:virtual_display/repositories/remote_support_request_repository/models/peer_data/ups_connection_status_data.dart';
import 'package:virtual_display/repositories/remote_support_request_repository/models/peer_data/ups_data.dart';

import '../authentication_helper.dart';
import '../modbus_helper.dart';
import '../remote_support_helper.dart';

void main() {
  User user = User(id: int.parse(MockUser.user[0]),name: MockUser.user[1], surname: MockUser.user[2],email: MockUser.user[3],phoneNumber: MockUser.user[4]);
  Technician technician = Technician(id: MockTechnician.id);
  test('toJson return the expected json value of user', () {
    
    Map<String, dynamic> userJson = user.toJson();
    User result = User.fromJson(userJson);
    expect(result.id, int.parse(MockUser.user[0]));
    expect(result.name, MockUser.user[1]);
    expect(result.surname, MockUser.user[2]);
    expect(result.email, MockUser.user[3]);
    expect(result.phoneNumber, MockUser.user[4]);
    userJson = user.toRestrictedJson();
    result = User.fromRestrictedJson(userJson);
    expect(result.id, int.parse(MockUser.user[0]));
  });

  test('toJson return the expected json value of ConfigData', () {
    ConfigData configData = ConfigData(mcmt: ExpectedMeasurements.mcmt, format: ExpectedMeasurements.measurementsFormatValue);
    Map<String, dynamic> result = configData.toJson();
    expect(result.toString(), ExpectedMeasurements.json);
  });

  test('fromJson create the correct MediaStatusData from a json file', () {
    MediaStatusData mediaStatusData = MediaStatusData(isMicEnabled: true, isVideoEnabled: true);
    Map<String, dynamic> mediaStatusJson = mediaStatusData.toJson();
    MediaStatusData result = MediaStatusData.fromJson(mediaStatusJson);
    expect(result.isMicEnabled, mediaStatusData.isMicEnabled);
    expect(result.isVideoEnabled, mediaStatusData.isVideoEnabled);
  });

  test('toJson return the expected json value of UpsData', () {
    UpsData upsData= UpsData(states: ExpectedState.states, alarms: ExpectedAlarms.alarms, measurements: ExpectedMeasurements.measurments, isBatteryPresent: true, isBypassPresent: true);
    Map<String, dynamic> upsDataJson = upsData.toJson();
    expect(upsDataJson.toString(), UpsMock.upsDataJson);
  });

  test('toJson return the expected json value of Message', () {
    String type = "Text";
    UpsData upsData= UpsData(states: ExpectedState.states, alarms: ExpectedAlarms.alarms, measurements: ExpectedMeasurements.measurments, isBatteryPresent: true, isBypassPresent: true);
    Message message = Message(type: type, data: upsData);
    Map<String, dynamic> messageJson = message.toJson();
    expect(messageJson.toString(), ExpectedMessage.message);
  });

  test('toJson return the expected json value of UpsConnectionStatusData', () {
    UpsConnectionStatusData upsConnectionStatusData = UpsConnectionStatusData(upsConnectionStatus: UpsMock.upsConnectionStatusData);
    Map<String, dynamic> upsConnectionStatusDataJson = upsConnectionStatusData.toJson();
    expect(upsConnectionStatusDataJson.toString(), UpsMock.upsConnectionStatusDataJson);
  });

  test('fromJson create the correct Technician from a json file', () {
    
    Map<String, dynamic> technicianJson = technician.toJson();
    Technician result = Technician.fromJson(technicianJson);
    expect(result.id, technician.id);
  });

  test('toJson return the expected json value of StartCall', () {
    StartCall startCall = StartCall(from: user);
    Map<String, dynamic> startCallJson = startCall.toJson();
    expect(startCallJson.toString(), MockStartCall.json);
  });

  test('toJson return the expected json value of CloseCall', () {
    CloseCall closeCall = CloseCall(from: user, to: technician);
    Map<String, dynamic> closeCallJson = closeCall.toJson();
    expect(closeCallJson.toString(), MockCloseCall.json);
  });

  test('fromJson create the correct Answer from a json file', () {
    Answer answer = Answer(sdp: MockAnswer.sdp, type: MockAnswer.type);
    Map<String, dynamic> answerJson = {'sdp': answer.sdp, 'type': answer.type};
    Answer result = Answer.fromJson(answerJson);
    expect(result.sdp, answer.sdp);
    expect(result.type, answer.type);
  });

  test('fromJson create the correct AcceptCall from a json file', () {
    AcceptCall acceptCall = AcceptCall(from: technician, to: user);
    Map<String, dynamic> acceptCallJson = {'from': acceptCall.from.toJson(), 'to': acceptCall.to.toJson()};
    AcceptCall result = AcceptCall.fromJson(acceptCallJson);
    expect(acceptCall.from.id, result.from.id);
    expect(acceptCall.to.id, result.to.id);
  });

  test('toJson return the expected json value of ClientOffer', () {
    RTCSessionDescription rtcSessionDescription = RTCSessionDescription("client", "video-call");
    ClientOffer clientOffer = ClientOffer(from: user, to: technician, offer: rtcSessionDescription);
    Map<String, dynamic> clientOfferJson = clientOffer.toJson();
    expect(clientOfferJson.toString(), MockClientOffer.json);
  });

  test('toJson return the expected json value of ClientIceCandidate', () {
    RTCIceCandidate rtcIceCandidate = RTCIceCandidate("user", "technician", 1);
    ClientIceCandidate clientIceCandidate = ClientIceCandidate(from: user, to: technician, candidate: rtcIceCandidate);
    Map<String, dynamic> clientIceCandidateJson = clientIceCandidate.toJson();
    expect(clientIceCandidateJson.toString(), MockIceCandidate.clientJson);
  });

  test('fromJson create the correct IceCandidate from a json file', () {
    IceCandidate iceCandidate = IceCandidate(candidate: "client", sdpMid:"user", sdpMLineIndex: 1);
    Map<String, dynamic> iceCandidateJson = iceCandidate.toJson();
    IceCandidate result = IceCandidate.fromJson(iceCandidateJson);
    expect(result.candidate, iceCandidate.candidate);
    expect(result.sdpMid, iceCandidate.sdpMid);
    expect(result.sdpMLineIndex, iceCandidate.sdpMLineIndex);
  });

  test('fromJson create the correct TechnicianIceCandidate from a json file', () {
    IceCandidate iceCandidate = IceCandidate(candidate: "client", sdpMid:"user", sdpMLineIndex: 1);
    TechnicianIceCandidate technicianIceCandidate = TechnicianIceCandidate(from: technician, to: user, candidate: iceCandidate);
    Map<String, dynamic> technicianIceCandidateJson = {'from': technician.toJson(), 'to': user.toJson(), 'candidate': iceCandidate.toJson()};
    TechnicianIceCandidate result = TechnicianIceCandidate.fromJson(technicianIceCandidateJson);
    expect(result.from.id, technicianIceCandidate.from.id);
    expect(result.to.id, technicianIceCandidate.to.id);
    expect(result.candidate.candidate, technicianIceCandidate.candidate.candidate);
  });

  test('fromJson create the correct TechnicianOffer from a json file', () {
    Answer answer = Answer(sdp: MockAnswer.sdp, type: MockAnswer.type);
    TechnicianOffer technicianOffer = TechnicianOffer(from: technician, to: user, answer: answer);
    Map<String, dynamic> technicianOfferJson = {'from': technician.toJson(), 'to': user.toJson(), 'answer': {'sdp': answer.sdp, 'type': answer.type} };
    TechnicianOffer result = TechnicianOffer.fromJson(technicianOfferJson);
    expect(result.from.id , technicianOffer.from.id);
    expect(result.to.id, technicianOffer.to.id);
  });
}
