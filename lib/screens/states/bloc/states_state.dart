part of 'states_bloc.dart';

class StatesState extends Equatable {
  const StatesState({this.upsStatus, this.states});

  final UpsStatus? upsStatus;
  final List<String>? states;

  StatesState copyWith({UpsStatus? upsStatus, List<String>? states}) {
    return StatesState(
        upsStatus: upsStatus ?? this.upsStatus, states: states ?? this.states);
  }

  @override
  List<Object?> get props => [upsStatus, states];
}
