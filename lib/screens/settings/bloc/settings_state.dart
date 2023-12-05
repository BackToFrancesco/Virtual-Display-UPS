part of 'settings_bloc.dart';

class SettingsState extends Equatable {
  const SettingsState({this.language});

  final String? language;

  SettingsState copyWith({
    String? language,
  }) {
    return SettingsState(
      language: language ?? this.language,
    );
  }

  @override
  List<Object?> get props => [language];
}
