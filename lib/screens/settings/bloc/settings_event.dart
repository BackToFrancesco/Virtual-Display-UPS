part of 'settings_bloc.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object> get props => [];
}

class LanguageChanged extends SettingsEvent {
  const LanguageChanged(this.language);

  final String language;

  @override
  List<Object> get props => [language];
}

class Init extends SettingsEvent {
  const Init();

  @override
  List<Object> get props => [];
}
