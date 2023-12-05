import '../../../authentication_repository/models/user.dart';
import 'answer.dart';
import 'technician.dart';

class TechnicianOffer {
  TechnicianOffer({required this.from, required this.to, required this.answer});

  final Technician from;
  final User to;
  final Answer answer;

  factory TechnicianOffer.fromJson(Map<String, dynamic> json) =>
      TechnicianOffer(
          from: Technician.fromJson(json["from"]),
          to: User.fromRestrictedJson(json["to"]),
          answer: Answer.fromJson(json["answer"]));
}
