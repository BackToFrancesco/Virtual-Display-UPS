part of 'authentication_bloc.dart';

class AuthenticationState {
  const AuthenticationState(
      {this.authenticationStatus, this.errorTitle, this.errorDescription});

  final AuthenticationStatus? authenticationStatus;
  final String? errorTitle;
  final String? errorDescription;

  AuthenticationState copyWith(
      {AuthenticationStatus? authenticationStatus,
      String? errorTitle,
      String? errorDescription}) {
    return AuthenticationState(
        authenticationStatus: authenticationStatus ?? this.authenticationStatus,
        errorTitle: errorTitle ?? this.errorTitle,
        errorDescription: errorDescription ?? this.errorDescription);
  }
}
