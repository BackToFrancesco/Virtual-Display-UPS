part of 'authentication_bloc.dart';

abstract class AuthenticationEvent {
  const AuthenticationEvent();
}

class AuthenticationStatusChanged extends AuthenticationEvent {
  const AuthenticationStatusChanged(this.authenticationStatus);

  final AuthenticationStatus authenticationStatus;
}

class Login extends AuthenticationEvent {
  const Login(this.email, this.password);

  final String email;
  final String password;
}

class Logout extends AuthenticationEvent {
  const Logout();
}
