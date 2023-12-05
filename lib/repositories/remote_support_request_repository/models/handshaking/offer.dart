class Offer {
  Offer({
    required this.sdp,
    required this.type,
  });

  final String sdp;
  final String type;

  Map<String, dynamic> toJson() => {"sdp": sdp, "type": type};
}
