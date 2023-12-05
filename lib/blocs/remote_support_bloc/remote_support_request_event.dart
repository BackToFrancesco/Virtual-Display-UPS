part of 'remote_support_request_bloc.dart';

abstract class RemoteSupportRequestEvent {
  const RemoteSupportRequestEvent();
}

class StopwatchUpdated extends RemoteSupportRequestEvent {
  const StopwatchUpdated();
}

class WaitingDotsUpdated extends RemoteSupportRequestEvent {
  const WaitingDotsUpdated();
}

class RemoteSupportRequestStatusChanged extends RemoteSupportRequestEvent {
  const RemoteSupportRequestStatusChanged(this.remoteSupportRequestsStatus);

  final RemoteSupportRequestStatus remoteSupportRequestsStatus;
}

class RemoteSupportMediaStatusChanged extends RemoteSupportRequestEvent {
  const RemoteSupportMediaStatusChanged(this.remoteSupportCallMediaStatus);

  final RemoteSupportCallMediaStatus remoteSupportCallMediaStatus;
}

class QueueUp extends RemoteSupportRequestEvent {
  const QueueUp();
}

class DeleteRemoteSupportRequest extends RemoteSupportRequestEvent {
  const DeleteRemoteSupportRequest();
}

class SwitchCamera extends RemoteSupportRequestEvent {
  const SwitchCamera();
}

class EnableOrDisableMic extends RemoteSupportRequestEvent {
  const EnableOrDisableMic();
}

class EnableOrDisableVideo extends RemoteSupportRequestEvent {
  const EnableOrDisableVideo();
}

class CloseCall extends RemoteSupportRequestEvent {
  const CloseCall();
}
