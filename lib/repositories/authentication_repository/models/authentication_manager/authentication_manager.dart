import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../utils/shared_preferences_global.dart'
    as shared_preferences_global;
import '../user.dart';

enum AuthenticationStatus {
  logged,
  loggedOut,
  wrongCredentials,
  unableToConnectToTheServer
}

class AuthenticationManager {
  User? _user;

  User? get user => _user;

  bool get logged => _user != null;

  final StreamController<AuthenticationStatus> _authenticationStatusController =
      StreamController<AuthenticationStatus>.broadcast();

  Stream<AuthenticationStatus> get authenticationStatusStream async* {
    yield* _authenticationStatusController.stream.asBroadcastStream();
  }

  void init() {
    final SharedPreferences prefs = shared_preferences_global.sharedPreferences;
    final List<String> user = prefs.getStringList('user') ?? [];
    if (user.isNotEmpty) {
      _user = User(
          id: int.parse(user[0]),
          name: user[1],
          surname: user[2],
          email: user[3],
          phoneNumber: user[4]);
    }
  }

  Future<void> logIn(
      {required String email,
      required String password,
      required String url}) async {
    final response = await post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );

    Map<String, dynamic> res = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (res['success'] == true) {
        _user = User.fromJson(res['data']);
        final SharedPreferences prefs =
            shared_preferences_global.sharedPreferences;
        await prefs.setStringList('user', [
          user!.id.toString(),
          user!.name,
          user!.surname,
          user!.email,
          user!.phoneNumber
        ]);
        _authenticationStatusController.add(AuthenticationStatus.logged);
      } else {
        _authenticationStatusController
            .add(AuthenticationStatus.wrongCredentials);
      }
    } else {
      _authenticationStatusController
          .add(AuthenticationStatus.unableToConnectToTheServer);
    }
  }

  Future<void> logOut() async {
    _user = null;
    _authenticationStatusController.add(AuthenticationStatus.loggedOut);
    final SharedPreferences prefs = shared_preferences_global.sharedPreferences;
    await prefs.remove('user');
  }

  Future<void> dispose() async {
    await _authenticationStatusController.close();
  }
}
