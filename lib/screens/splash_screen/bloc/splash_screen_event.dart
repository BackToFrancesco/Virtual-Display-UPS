part of 'splash_screen_bloc.dart';

abstract class SplashScreenEvent extends Equatable {
  const SplashScreenEvent();

  @override
  List<Object> get props => [];
}

class SplashScreenCreated extends SplashScreenEvent {
  const SplashScreenCreated();

  @override
  List<Object> get props => [];
}
