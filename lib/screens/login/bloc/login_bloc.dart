import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../blocs/authentication_bloc/authentication_bloc.dart';
import '../../../utils/shared_preferences_global.dart'
    as shared_preferences_global;
import '../models/email.dart';
import '../models/password.dart';

part 'login_event.dart';

part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({required this.authenticationBloc}) : super(const LoginState()) {
    on<EmailChanged>(_onEmailChanged);
    on<PasswordChanged>(_onPasswordChanged);
    on<Submitted>(_onSubmitted);
    on<SubmissionFailure>(_onSubmissionFailure);
    on<SubmissionSuccess>(_onSubmissionSuccess);
  }

  final AuthenticationBloc authenticationBloc;

  void _onSubmissionSuccess(SubmissionSuccess event, Emitter<LoginState> emit) {
    emit(state.copyWith(status: FormzStatus.submissionSuccess));
  }

  void _onSubmissionFailure(SubmissionFailure event, Emitter<LoginState> emit) {
    emit(state.copyWith(status: FormzStatus.submissionFailure));
  }

  void _onSubmitted(Submitted event, Emitter<LoginState> emit) {
    emit(state.copyWith(status: FormzStatus.submissionInProgress));
    if (state.status.isValidated) {
      authenticationBloc.add(Login(state.email.value, state.password.value));
    }
  }

  void _onEmailChanged(EmailChanged event, Emitter<LoginState> emit) {
    final email = Email.dirty(event.email);
    emit(state.copyWith(
        email: email, status: Formz.validate([email, state.password])));
  }

  void _onPasswordChanged(PasswordChanged event, Emitter<LoginState> emit) {
    final password = Password.dirty(event.password);
    emit(state.copyWith(
        password: password, status: Formz.validate([state.email, password])));
  }
}
