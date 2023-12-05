part of 'input_measurements_bloc.dart';

class InputMeasurementsState extends Equatable {
  const InputMeasurementsState({this.upsStatus, this.inputMeasurements});

  final UpsStatus? upsStatus;
  final InputMeasurements? inputMeasurements;

  InputMeasurementsState copyWith(
      {UpsStatus? upsStatus, InputMeasurements? inputMeasurements}) {
    return InputMeasurementsState(
        upsStatus: upsStatus ?? this.upsStatus,
        inputMeasurements: inputMeasurements ?? this.inputMeasurements);
  }

  @override
  List<Object?> get props => [upsStatus, inputMeasurements];
}
