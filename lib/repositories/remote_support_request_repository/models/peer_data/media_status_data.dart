import 'data.dart';

class MediaStatusData implements Data {
  MediaStatusData({
    this.isMicEnabled,
    this.isVideoEnabled,
  });

  final bool? isMicEnabled;
  final bool? isVideoEnabled;

  factory MediaStatusData.fromJson(Map<String, dynamic> json) =>
      MediaStatusData(
          isMicEnabled: json["isMicEnabled"],
          isVideoEnabled: json["isVideoEnabled"]);

  @override
  Map<String, dynamic> toJson() =>
      {'isMicEnabled': isMicEnabled, 'isVideoEnabled': isVideoEnabled};
}
