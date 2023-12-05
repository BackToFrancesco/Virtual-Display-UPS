import 'package:equatable/equatable.dart';

class BatteryMeasurements extends Equatable {
  final bool batPresent;
  final String? m016, m017, m018, m019, m022, m023, m024, m025, m026, m027;

  const BatteryMeasurements(
      this.batPresent,
      this.m016,
      this.m017,
      this.m018,
      this.m019,
      this.m022,
      this.m023,
      this.m024,
      this.m025,
      this.m026,
      this.m027);

  @override
  List<Object?> get props =>
      [batPresent, m016, m017, m018, m019, m022, m023, m024, m025, m026, m027];
}
