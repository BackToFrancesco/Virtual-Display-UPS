part of 'inverter_measurements_bloc.dart';

abstract class InverterMeasurementsEvent extends Equatable {
  const InverterMeasurementsEvent();

  @override
  List<Object> get props => [];
}

class Init extends InverterMeasurementsEvent {
  const Init();

  @override
  List<Object> get props => [];
}

class UpsStatusChanged extends InverterMeasurementsEvent {
  const UpsStatusChanged(this.upsStatus);

  final UpsStatus upsStatus;

  @override
  List<Object> get props => [upsStatus];
}

class DataChanged extends InverterMeasurementsEvent {
  const DataChanged();

  @override
  List<Object> get props => [];
}
