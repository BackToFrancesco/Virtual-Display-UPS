part of 'dashboard_bloc.dart';

class DashboardState extends Equatable {
  const DashboardState({this.upsStatus, this.synoptic});

  final UpsStatus? upsStatus;
  final Synoptic? synoptic;

  DashboardState copyWith({UpsStatus? upsStatus, Synoptic? synoptic}) {
    return DashboardState(
        upsStatus: upsStatus ?? this.upsStatus,
        synoptic: synoptic ?? this.synoptic);
  }

  @override
  List<Object?> get props => [upsStatus, synoptic];
}
