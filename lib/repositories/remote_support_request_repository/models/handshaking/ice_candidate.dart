class IceCandidate {
  IceCandidate(
      {required this.candidate,
      required this.sdpMid,
      required this.sdpMLineIndex});

  final String? candidate;
  final String? sdpMid;
  final int? sdpMLineIndex;

  factory IceCandidate.fromJson(Map<String, dynamic> json) => IceCandidate(
      candidate: json["candidate"],
      sdpMid: json["sdpMid"],
      sdpMLineIndex: json["sdpMLineIndex"]);

  Map<String, dynamic> toJson() => {
        'candidate': candidate,
        'sdpMid': sdpMid,
        'sdpMLineIndex': sdpMLineIndex
      };
}
