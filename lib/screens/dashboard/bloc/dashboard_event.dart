part of 'dashboard_bloc.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object> get props => [];
}

class UpsStatusChanged extends DashboardEvent {
  const UpsStatusChanged(this.upsStatus);

  final UpsStatus upsStatus;

  @override
  List<Object> get props => [upsStatus];
}

class SynopticChanged extends DashboardEvent {
  const SynopticChanged(this.synoptic);

  final Synoptic synoptic;

  @override
  List<Object> get props => [synoptic];
}

class MaintChanged extends DashboardEvent {
  const MaintChanged(this.maint);

  final bool maint;

  @override
  List<Object> get props => [maint];
}
