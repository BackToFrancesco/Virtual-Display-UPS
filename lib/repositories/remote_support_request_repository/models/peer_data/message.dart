import 'data.dart';

class Message {
  Message({
    required this.type,
    required this.data,
  });

  final String type;
  final Data data;

  Map<String, dynamic> toJson() => {
        'type': type,
        'data': data.toJson(),
      };
}
