part of 'get_started_bloc.dart';

class GetStartedState extends Equatable {
  const GetStartedState({this.language});

  final String? language;

  GetStartedState copyWith({
    String? language,
  }) {
    return GetStartedState(
      language: language ?? this.language,
    );
  }

  @override
  List<Object?> get props => [language];
}
