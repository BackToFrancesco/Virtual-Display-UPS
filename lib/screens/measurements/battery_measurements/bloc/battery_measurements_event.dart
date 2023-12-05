part of 'battery_measurements_bloc.dart';

abstract class BatteryMeasurementsEvent extends Equatable {
  const BatteryMeasurementsEvent();

  @override
  List<Object> get props => [];
}

class Init extends BatteryMeasurementsEvent {
  const Init();

  @override
  List<Object> get props => [];
}

class UpsStatusChanged extends BatteryMeasurementsEvent {
  const UpsStatusChanged(this.upsStatus);

  final UpsStatus upsStatus;

  @override
  List<Object> get props => [upsStatus];
}

class DataChanged extends BatteryMeasurementsEvent {
  const DataChanged();

  @override
  List<Object> get props => [];
}
