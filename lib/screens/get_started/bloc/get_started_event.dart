part of 'get_started_bloc.dart';

abstract class GetStartedEvent extends Equatable {
  const GetStartedEvent();

  @override
  List<Object> get props => [];
}

class LanguageChanged extends GetStartedEvent {
  const LanguageChanged(this.language);

  final String language;

  @override
  List<Object> get props => [language];
}

class Init extends GetStartedEvent {
  const Init();

  @override
  List<Object> get props => [];
}
