import 'package:equatable/equatable.dart';

class InputMeasurements extends Equatable {
  final String? m032,
      m033,
      m034,
      m035,
      m036,
      m037,
      m038,
      m064,
      m065,
      m066,
      m067,
      m068,
      m069;

  const InputMeasurements(
      this.m032,
      this.m033,
      this.m034,
      this.m035,
      this.m036,
      this.m037,
      this.m038,
      this.m064,
      this.m065,
      this.m066,
      this.m067,
      this.m068,
      this.m069);

  @override
  List<Object?> get props => [
        m032,
        m033,
        m034,
        m035,
        m036,
        m037,
        m038,
        m064,
        m065,
        m066,
        m067,
        m068,
        m069
      ];
}
