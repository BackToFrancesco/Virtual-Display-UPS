part of 'inverter_measurements_bloc.dart';

class InverterMeasurementsState extends Equatable {
  const InverterMeasurementsState({this.upsStatus, this.inverterMeasurements});

  final UpsStatus? upsStatus;
  final InverterMeasurements? inverterMeasurements;

  InverterMeasurementsState copyWith(
      {UpsStatus? upsStatus, InverterMeasurements? inverterMeasurements}) {
    return InverterMeasurementsState(
        upsStatus: upsStatus ?? this.upsStatus,
        inverterMeasurements:
            inverterMeasurements ?? this.inverterMeasurements);
  }

  @override
  List<Object?> get props => [upsStatus, inverterMeasurements];
}
