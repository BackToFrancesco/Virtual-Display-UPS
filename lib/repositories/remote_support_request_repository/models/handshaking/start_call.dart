import '../../../authentication_repository/models/user.dart';

class StartCall {
  StartCall({required this.from});

  final User from;

  Map<String, dynamic> toJson() => {"from": from.toJson()};
}
