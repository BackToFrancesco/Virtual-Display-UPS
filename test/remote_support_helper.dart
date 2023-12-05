import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:mockito/mockito.dart';

class ExpectedMessage{
  static const String message= "{type: Text, data: {states: 10d57fffffffffffffffffffffffffffff, alarms: 10ffffffffffffffffffffffffffffffff, measurements: a000050005000500050005000500050005000500050005000500050005000500050005000500050005000500050005000500050005000500050005000500050005000500050005000500050005000500050005000500050005000500050005000500050005000500050005000500050005000500050005000500050005000500050005000500050005000500050005000500050005000500050005ca55ffff003c, isBatteryPresent: true, isBypassPresent: true}}";
}

class MockWebRTC extends Mock implements WebRTC{
  
}

class MockTechnician{
  static const int id = 1;
  static const String json= "{id: 1, isCustomer: false}";
}

class MockCloseCall{
  static const String json = "{from: {id: 1, name: User, surname: Mock, email: user.mock@gmail.com, phoneNumber: 3520005252, isCustomer: true}, to: {id: 1, isCustomer: false}}";
}

class MockStartCall{
  static const String json = "{from: {id: 1, name: User, surname: Mock, email: user.mock@gmail.com, phoneNumber: 3520005252, isCustomer: true}}";
}

class MockAnswer{
  static const String sdp = "user";
  static const String type = "video-call";
}

class MockIceCandidate{
  static const String clientJson = "{from: {id: 1, name: User, surname: Mock, email: user.mock@gmail.com, phoneNumber: 3520005252, isCustomer: true}, to: {id: 1, isCustomer: false}, candidate: {candidate: user, sdpMid: technician, sdpMLineIndex: 1}}";
}

class MockClientOffer{
  static const String json = "{from: {id: 1, name: User, surname: Mock, email: user.mock@gmail.com, phoneNumber: 3520005252, isCustomer: true}, to: {id: 1, isCustomer: false}, offer: {sdp: client, type: video-call}}";
}