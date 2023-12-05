import 'data.dart';

class UpsConnectionStatusData implements Data {
  UpsConnectionStatusData({
    required this.upsConnectionStatus,
  });

  final String upsConnectionStatus;

  @override
  Map<String, dynamic> toJson() => {
        'upsConnectionStatus': upsConnectionStatus,
      };
}
