abstract class AdminModerationEvent {}

class LoadPendingRequests extends AdminModerationEvent {}

class ApproveRequest extends AdminModerationEvent {
  final String id;

  ApproveRequest(this.id);
}

class RejectRequest extends AdminModerationEvent {
  final String id;

  RejectRequest(this.id);
}
