import '../../../authentication_repository/models/user.dart';
import 'ice_candidate.dart';
import 'technician.dart';

class TechnicianIceCandidate {
  TechnicianIceCandidate(
      {required this.from, required this.to, required this.candidate});

  final Technician from;
  final User to;
  final IceCandidate candidate;

  factory TechnicianIceCandidate.fromJson(Map<String, dynamic> json) =>
      TechnicianIceCandidate(
          from: Technician.fromJson(json["from"]),
          to: User.fromRestrictedJson(json["to"]),
          candidate: IceCandidate.fromJson(json["candidate"]));
}
