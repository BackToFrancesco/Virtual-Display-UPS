part of 'ups_connection_handler_bloc.dart';

class UpsConnectionHandlerState {
  const UpsConnectionHandlerState(
      {this.upsConnectionStatus, this.errorTitle, this.errorDescription});

  final UpsConnectionStatus? upsConnectionStatus;
  final String? errorTitle;
  final String? errorDescription;

  UpsConnectionHandlerState copyWith(
      {UpsConnectionStatus? upsConnectionStatus,
      String? errorTitle,
      String? errorDescription}) {
    return UpsConnectionHandlerState(
        upsConnectionStatus: upsConnectionStatus ?? this.upsConnectionStatus,
        errorTitle: errorTitle ?? this.errorTitle,
        errorDescription: errorDescription ?? this.errorDescription);
  }
}
