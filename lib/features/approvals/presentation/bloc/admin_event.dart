import 'package:equatable/equatable.dart';

abstract class AdminEvent extends Equatable {
  const AdminEvent();

  @override
  List<Object> get props => [];
}

class LoadPendingRequests extends AdminEvent {}

class ApproveRequest extends AdminEvent {
  final String id;

  const ApproveRequest(this.id);

  @override
  List<Object> get props => [id];
}

class RejectRequest extends AdminEvent {
  final String id;

  const RejectRequest(this.id);

  @override
  List<Object> get props => [id];
}
