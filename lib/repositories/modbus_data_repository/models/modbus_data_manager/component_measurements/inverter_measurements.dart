import 'package:equatable/equatable.dart';

class InverterMeasurements extends Equatable {
  final String? m010, m011, m012, m013, m015, m054, m055, m056;

  const InverterMeasurements(this.m010, this.m011, this.m012, this.m013,
      this.m015, this.m054, this.m055, this.m056);

  @override
  List<Object?> get props => [m010, m011, m012, m013, m015, m054, m055, m056];
}
