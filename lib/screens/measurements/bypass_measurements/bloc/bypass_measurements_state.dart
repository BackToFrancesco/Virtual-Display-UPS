part of 'bypass_measurements_bloc.dart';

class BypassMeasurementsState extends Equatable {
  const BypassMeasurementsState({this.upsStatus, this.bypassMeasurements});

  final UpsStatus? upsStatus;
  final BypassMeasurements? bypassMeasurements;

  BypassMeasurementsState copyWith(
      {UpsStatus? upsStatus, BypassMeasurements? bypassMeasurements}) {
    return BypassMeasurementsState(
        upsStatus: upsStatus ?? this.upsStatus,
        bypassMeasurements: bypassMeasurements ?? this.bypassMeasurements);
  }

  @override
  List<Object?> get props => [upsStatus, bypassMeasurements];
}
