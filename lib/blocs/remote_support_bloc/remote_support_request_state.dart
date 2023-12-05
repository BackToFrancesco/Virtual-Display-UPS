part of 'remote_support_request_bloc.dart';

class RemoteSupportRequestState {
  const RemoteSupportRequestState(
      {this.stopwatch = "00:00",
      this.waitingDots = "",
      this.requestStatus,
      this.errorTitle,
      this.errorDescription,
      this.micEnabled = true,
      this.videoEnabled = true,
      this.technicianMicEnabled = true,
      this.technicianVideoEnabled = true});

  final String stopwatch;
  final String waitingDots;
  final RemoteSupportRequestStatus? requestStatus;
  final String? errorTitle;
  final String? errorDescription;
  final bool micEnabled;
  final bool videoEnabled;
  final bool technicianMicEnabled;
  final bool technicianVideoEnabled;

  RemoteSupportRequestState copyWith(
      {String? stopwatch,
      String? waitingDots,
      RemoteSupportRequestStatus? requestStatus,
      String? errorTitle,
      String? errorDescription,
      bool? micEnabled,
      bool? videoEnabled,
      bool? technicianMicEnabled,
      bool? technicianVideoEnabled}) {
    return RemoteSupportRequestState(
        stopwatch: stopwatch ?? this.stopwatch,
        waitingDots: waitingDots ?? this.waitingDots,
        requestStatus: requestStatus ?? this.requestStatus,
        errorTitle: errorTitle ?? this.errorTitle,
        errorDescription: errorDescription ?? this.errorDescription,
        micEnabled: micEnabled ?? this.micEnabled,
        videoEnabled: videoEnabled ?? this.videoEnabled,
        technicianMicEnabled: technicianMicEnabled ?? this.technicianMicEnabled,
        technicianVideoEnabled:
            technicianVideoEnabled ?? this.technicianVideoEnabled);
  }
}
