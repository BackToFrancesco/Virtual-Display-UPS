part of 'ups_connection_bloc.dart';

abstract class UpsConnectionEvent extends Equatable {
  const UpsConnectionEvent();

  @override
  List<Object> get props => [];
}

class IpAddressChanged extends UpsConnectionEvent {
  const IpAddressChanged(this.ipAddress);

  final String ipAddress;

  @override
  List<Object> get props => [ipAddress];
}

class PortChanged extends UpsConnectionEvent {
  const PortChanged(this.port);

  final String port;

  @override
  List<Object> get props => [port];
}

class SlaveIdChanged extends UpsConnectionEvent {
  const SlaveIdChanged(this.slaveId);

  final String slaveId;

  @override
  List<Object> get props => [slaveId];
}

class Submitted extends UpsConnectionEvent {
  const Submitted();
}

class SubmittedFromRecentConnections extends UpsConnectionEvent {
  const SubmittedFromRecentConnections(this.index);

  final int index;

  @override
  List<Object> get props => [index];
}

class SubmissionSuccess extends UpsConnectionEvent {
  const SubmissionSuccess();

  @override
  List<Object> get props => [];
}

class SubmissionFailure extends UpsConnectionEvent {
  const SubmissionFailure();

  @override
  List<Object> get props => [];
}
