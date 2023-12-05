part of 'output_measurements_bloc.dart';

abstract class OutputMeasurementsEvent extends Equatable {
  const OutputMeasurementsEvent();

  @override
  List<Object> get props => [];
}

class Init extends OutputMeasurementsEvent {
  const Init();

  @override
  List<Object> get props => [];
}

class UpsStatusChanged extends OutputMeasurementsEvent {
  const UpsStatusChanged(this.upsStatus);

  final UpsStatus upsStatus;

  @override
  List<Object> get props => [upsStatus];
}

class DataChanged extends OutputMeasurementsEvent {
  const DataChanged();

  @override
  List<Object> get props => [];
}
