part of 'bypass_measurements_bloc.dart';

abstract class BypassMeasurementsEvent extends Equatable {
  const BypassMeasurementsEvent();

  @override
  List<Object> get props => [];
}

class Init extends BypassMeasurementsEvent {
  const Init();

  @override
  List<Object> get props => [];
}

class UpsStatusChanged extends BypassMeasurementsEvent {
  const UpsStatusChanged(this.upsStatus);

  final UpsStatus upsStatus;

  @override
  List<Object> get props => [upsStatus];
}

class DataChanged extends BypassMeasurementsEvent {
  const DataChanged();

  @override
  List<Object> get props => [];
}
