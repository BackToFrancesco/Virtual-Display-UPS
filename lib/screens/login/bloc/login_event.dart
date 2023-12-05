part of 'login_bloc.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object> get props => [];
}

class EmailChanged extends LoginEvent {
  const EmailChanged(this.email);

  final String email;

  @override
  List<Object> get props => [email];
}

class PasswordChanged extends LoginEvent {
  const PasswordChanged(this.password);

  final String password;

  @override
  List<Object> get props => [password];
}

class Submitted extends LoginEvent {
  const Submitted();
}

class SubmissionSuccess extends LoginEvent {
  const SubmissionSuccess();

  @override
  List<Object> get props => [];
}

class SubmissionFailure extends LoginEvent {
  const SubmissionFailure();

  @override
  List<Object> get props => [];
}
