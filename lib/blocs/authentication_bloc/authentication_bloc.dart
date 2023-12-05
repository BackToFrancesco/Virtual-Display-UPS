import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../repositories/authentication_repository/authentication_repository.dart';
import '../../repositories/authentication_repository/models/authentication_manager/authentication_manager.dart';
import '../../repositories/authentication_repository/models/user.dart';

part 'authentication_event.dart';

part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc({
    required this.authenticationRepository,
  }) : super(const AuthenticationState()) {
    on<AuthenticationStatusChanged>(_onAuthenticationStatusChanged);
    on<Login>(_onLogin);
    on<Logout>(_onLogout);

    _authenticationStatusSubscription = authenticationRepository
        .authenticationStatusStream
        .listen((status) => add(AuthenticationStatusChanged(status)));
  }

  final AuthenticationRepository authenticationRepository;

  late StreamSubscription<AuthenticationStatus>
      _authenticationStatusSubscription;

  User? get user => authenticationRepository.user;

  bool get logged => authenticationRepository.logged;

  @override
  Future<void> close() async {
    await _authenticationStatusSubscription.cancel();
    await authenticationRepository.dispose();
    return super.close();
  }

  Future<void> _onLogin(Login event, Emitter<AuthenticationState> emit) async {
    await rootBundle.loadString('global_vars.env');
    await authenticationRepository.logIn(
        email: event.email,
        password: event.password,
        url: dotenv.get('AUTHENTICATION_SERVER'));
  }

  void _onLogout(Logout event, Emitter<AuthenticationState> emit) {
    authenticationRepository.logOut();
  }

  void _onAuthenticationStatusChanged(
      AuthenticationStatusChanged event, Emitter<AuthenticationState> emit) {
    switch (event.authenticationStatus) {
      case AuthenticationStatus.logged:
        emit(state.copyWith(authenticationStatus: event.authenticationStatus));
        break;
      case AuthenticationStatus.unableToConnectToTheServer:
        emit(state.copyWith(
            authenticationStatus: event.authenticationStatus,
            errorTitle: 'Unable to connect',
            errorDescription:
                'Cannot reach the server. Make sure the wifi network you are connected to, has internet access'));
        break;
      case AuthenticationStatus.wrongCredentials:
        emit(state.copyWith(
            authenticationStatus: event.authenticationStatus,
            errorTitle: 'Login failed',
            errorDescription: 'Wrong credentials'));
        break;
      case AuthenticationStatus.loggedOut:
        emit(state.copyWith(authenticationStatus: event.authenticationStatus));
    }
  }
}
