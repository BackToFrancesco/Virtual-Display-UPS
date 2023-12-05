import 'dart:convert';
import 'dart:io';
import 'package:virtual_display/utils/shared_preferences_global.dart'
    as shared_preferences_global;
import 'package:shared_preferences/shared_preferences.dart';

class MockUser {
  static final List<String> _user = [
    "1",
    "User",
    "Mock",
    "user.mock@gmail.com",
    "3520005252"
  ];

  static final Map<String, dynamic> _userData = {
    'id': int.parse(MockUser.user[0]),
    'name': MockUser.user[1],
    'surname': MockUser.user[2],
    'email': MockUser.user[3],
    'phoneNumber': MockUser.user[4],
  };

  static List<String> get user => _user;
  static Map<String, dynamic> get userData => _userData;
}

class MockServer {
  late HttpServer _server;
  static String url = 'http://localhost:8080/'; 

  void startServer() async {
    this._server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8080);
    await for (var request in this._server) {
      request.response.statusCode = 200;
      request.response
        ..headers.contentType =
            new ContentType("text", "plain", charset: "utf-8")
        ..write(jsonEncode(<String, dynamic>{
          'success': true,
          'data': MockUser.userData,
        }))
        ..close();
    }
  }

  Future<void> dispose() async{
    await this._server.close();
  }
}

class MockGlobalPreferences{

  Future<void> setGlobalPreferences(values) async{
  SharedPreferences.setMockInitialValues(values);
    await shared_preferences_global.init();
    final SharedPreferences prefs = shared_preferences_global.sharedPreferences;
}
}
