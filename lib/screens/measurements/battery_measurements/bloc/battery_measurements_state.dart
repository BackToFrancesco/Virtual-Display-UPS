part of 'battery_measurements_bloc.dart';

class BatteryMeasurementsState extends Equatable {
  const BatteryMeasurementsState({this.upsStatus, this.batteryMeasurements});

  final UpsStatus? upsStatus;
  final BatteryMeasurements? batteryMeasurements;

  BatteryMeasurementsState copyWith(
      {UpsStatus? upsStatus, BatteryMeasurements? batteryMeasurements}) {
    return BatteryMeasurementsState(
        upsStatus: upsStatus ?? this.upsStatus,
        batteryMeasurements: batteryMeasurements ?? this.batteryMeasurements);
  }

  @override
  List<Object?> get props => [upsStatus, batteryMeasurements];
}
