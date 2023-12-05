part of 'ups_connection_bloc.dart';

class UpsConnectionState extends Equatable {
  const UpsConnectionState(
      {this.status = FormzStatus.pure,
      this.ipAddress = const IpAddress.pure(),
      this.port = const Port.pure(),
      this.slaveId = const SlaveId.pure(),
      this.fromRecentConnections = false});

  final FormzStatus status;
  final IpAddress ipAddress;
  final SlaveId slaveId;
  final Port port;
  final bool fromRecentConnections;

  UpsConnectionState copyWith(
      {FormzStatus? status,
      IpAddress? ipAddress,
      Port? port,
      SlaveId? slaveId,
      bool? fromRecentConnections}) {
    return UpsConnectionState(
        status: status ?? this.status,
        ipAddress: ipAddress ?? this.ipAddress,
        port: port ?? this.port,
        slaveId: slaveId ?? this.slaveId,
        fromRecentConnections:
            fromRecentConnections ?? this.fromRecentConnections);
  }

  @override
  List<Object> get props =>
      [status, ipAddress, port, slaveId, fromRecentConnections];
}
