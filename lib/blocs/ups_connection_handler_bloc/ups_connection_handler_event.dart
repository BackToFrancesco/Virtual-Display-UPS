part of 'ups_connection_handler_bloc.dart';

abstract class UpsConnectionHandlerEvent {
  const UpsConnectionHandlerEvent();
}

class UpsConnectionStatusChanged extends UpsConnectionHandlerEvent {
  const UpsConnectionStatusChanged(this.upsConnectionStatus);

  final UpsConnectionStatus upsConnectionStatus;
}

class DisconnectFromUps extends UpsConnectionHandlerEvent {
  const DisconnectFromUps();
}

class ReconnectToUps extends UpsConnectionHandlerEvent {
  const ReconnectToUps();
}

class ConnectToUps extends UpsConnectionHandlerEvent {
  const ConnectToUps(this.ipAddress, this.port, this.slaveId);

  final String ipAddress;
  final String port;
  final String slaveId;
}
