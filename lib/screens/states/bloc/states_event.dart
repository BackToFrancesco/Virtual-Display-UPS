part of 'states_bloc.dart';

abstract class StatesEvent extends Equatable {
  const StatesEvent();

  @override
  List<Object> get props => [];
}

class Init extends StatesEvent {
  const Init();

  @override
  List<Object> get props => [];
}

class UpsStatusChanged extends StatesEvent {
  const UpsStatusChanged(this.upsStatus);

  final UpsStatus upsStatus;

  @override
  List<Object> get props => [upsStatus];
}

class DataChanged extends StatesEvent {
  const DataChanged();

  @override
  List<Object> get props => [];
}
