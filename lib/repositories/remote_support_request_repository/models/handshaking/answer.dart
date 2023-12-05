class Answer {
  Answer({
    required this.sdp,
    required this.type,
  });

  final String sdp;
  final String type;

  factory Answer.fromJson(Map<String, dynamic> json) =>
      Answer(sdp: json["sdp"], type: json["type"]);
}
