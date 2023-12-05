part of 'splash_screen_bloc.dart';

class SplashScreenState extends Equatable {
  const SplashScreenState(
      {this.initialized = false, this.nextRouteName = "getStarted"});

  final bool initialized;
  final String nextRouteName;

  SplashScreenState copyWith({bool? initialized, String? nextRouteName}) {
    return SplashScreenState(
        initialized: initialized ?? this.initialized,
        nextRouteName: nextRouteName ?? this.nextRouteName);
  }

  @override
  List<Object> get props => [initialized, nextRouteName];
}
