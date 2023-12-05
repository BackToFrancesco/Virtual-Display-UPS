import 'package:equatable/equatable.dart';

class BypassMeasurements extends Equatable {
  final bool noBypass;
  final String? m039,
      m040,
      m041,
      m042,
      m043,
      m044,
      m045,
      m070,
      m071,
      m072,
      m073,
      m074,
      m075;

  const BypassMeasurements(
      this.noBypass,
      this.m039,
      this.m040,
      this.m041,
      this.m042,
      this.m043,
      this.m044,
      this.m045,
      this.m070,
      this.m071,
      this.m072,
      this.m073,
      this.m074,
      this.m075);

  @override
  List<Object?> get props => [
        noBypass,
        m039,
        m040,
        m041,
        m042,
        m043,
        m044,
        m045,
        m070,
        m071,
        m072,
        m073,
        m074,
        m075
      ];
}
