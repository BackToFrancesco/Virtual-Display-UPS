import '../../../authentication_repository/models/user.dart';
import 'technician.dart';

class AcceptCall {
  AcceptCall({
    required this.from,
    required this.to,
  });

  final Technician from;
  final User to;

  factory AcceptCall.fromJson(Map<String, dynamic> json) => AcceptCall(
      from: Technician.fromJson(json["from"]),
      to: User.fromRestrictedJson(json["to"]));
}
