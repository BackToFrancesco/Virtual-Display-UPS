part of 'output_measurements_bloc.dart';

class OutputMeasurementsState extends Equatable {
  const OutputMeasurementsState({this.upsStatus, this.outputMeasurements});

  final UpsStatus? upsStatus;
  final OutputMeasurements? outputMeasurements;

  OutputMeasurementsState copyWith(
      {UpsStatus? upsStatus, OutputMeasurements? outputMeasurements}) {
    return OutputMeasurementsState(
        upsStatus: upsStatus ?? this.upsStatus,
        outputMeasurements: outputMeasurements ?? this.outputMeasurements);
  }

  @override
  List<Object?> get props => [upsStatus, outputMeasurements];
}
