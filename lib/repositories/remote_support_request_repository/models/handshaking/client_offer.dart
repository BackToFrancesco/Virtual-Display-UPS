import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../../authentication_repository/models/user.dart';
import 'technician.dart';

class ClientOffer {
  ClientOffer({required this.from, required this.to, required this.offer});

  final User from;
  final Technician to;
  final RTCSessionDescription offer;

  Map<String, dynamic> toJson() =>
      {"from": from.toJson(), "to": to.toJson(), "offer": offer.toMap()};
}
