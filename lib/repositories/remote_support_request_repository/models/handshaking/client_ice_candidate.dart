import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../../authentication_repository/models/user.dart';
import 'technician.dart';

class ClientIceCandidate {
  ClientIceCandidate(
      {required this.from, required this.to, required this.candidate});

  final User from;
  final Technician to;
  final RTCIceCandidate candidate;

  Map<String, dynamic> toJson() => {
        "from": from.toJson(),
        "to": to.toJson(),
        "candidate": candidate.toMap()
      };
}
