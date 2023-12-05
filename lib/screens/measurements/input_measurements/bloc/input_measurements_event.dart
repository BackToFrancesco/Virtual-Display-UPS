part of 'input_measurements_bloc.dart';

abstract class InputMeasurementsEvent extends Equatable {
  const InputMeasurementsEvent();

  @override
  List<Object> get props => [];
}

class Init extends InputMeasurementsEvent {
  const Init();

  @override
  List<Object> get props => [];
}

class UpsStatusChanged extends InputMeasurementsEvent {
  const UpsStatusChanged(this.upsStatus);

  final UpsStatus upsStatus;

  @override
  List<Object> get props => [upsStatus];
}

class DataChanged extends InputMeasurementsEvent {
  const DataChanged();

  @override
  List<Object> get props => [];
}
