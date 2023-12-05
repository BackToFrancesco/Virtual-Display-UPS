import 'dart:async';
import 'models/authentication_manager/authentication_manager.dart';
import 'models/user.dart';

class AuthenticationRepository {
  final AuthenticationManager _authenticationManager = AuthenticationManager();

  User? get user => _authenticationManager.user;

  bool get logged => _authenticationManager.logged;

  Stream<AuthenticationStatus> get authenticationStatusStream =>
      _authenticationManager.authenticationStatusStream;

  void init() {
    _authenticationManager.init();
  }

  Future<void> logIn(
      {required String email,
      required String password,
      required String url}) async {
    await _authenticationManager.logIn(
        email: email, password: password, url: url);
  }

  Future<void> logOut() async {
    await _authenticationManager.logOut();
  }

  Future<void> dispose() async {
    await _authenticationManager.dispose();
  }
}
