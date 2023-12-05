part of 'alarms_bloc.dart';

class AlarmsState extends Equatable {
  const AlarmsState({this.upsStatus, this.alarms});

  final UpsStatus? upsStatus;
  final List<String>? alarms;

  AlarmsState copyWith({UpsStatus? upsStatus, List<String>? alarms}) {
    return AlarmsState(
        upsStatus: upsStatus ?? this.upsStatus, alarms: alarms ?? this.alarms);
  }

  @override
  List<Object?> get props => [upsStatus, alarms];
}
