part of 'alarms_bloc.dart';

abstract class AlarmsEvent extends Equatable {
  const AlarmsEvent();

  @override
  List<Object> get props => [];
}

class Init extends AlarmsEvent {
  const Init();

  @override
  List<Object> get props => [];
}

class UpsStatusChanged extends AlarmsEvent {
  const UpsStatusChanged(this.upsStatus);

  final UpsStatus upsStatus;

  @override
  List<Object> get props => [upsStatus];
}

class DataChanged extends AlarmsEvent {
  const DataChanged();

  @override
  List<Object> get props => [];
}
