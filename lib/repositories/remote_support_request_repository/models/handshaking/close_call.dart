import '../../../authentication_repository/models/user.dart';
import 'technician.dart';

class CloseCall {
  CloseCall({required this.from, required this.to});

  final User from;
  final Technician to;

  Map<String, dynamic> toJson() =>
      {"from": from.toJson(), "to": to.toJson()};
}
