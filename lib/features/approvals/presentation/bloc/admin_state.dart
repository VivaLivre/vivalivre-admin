import 'package:equatable/equatable.dart';
import '../../data/models/bathroom_request_model.dart';

abstract class AdminState extends Equatable {
  const AdminState();
  
  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class AdminLoaded extends AdminState {
  final List<BathroomRequestModel> pendingRequests;

  const AdminLoaded(this.pendingRequests);

  @override
  List<Object> get props => [pendingRequests];
}

class AdminError extends AdminState {
  final String message;

  const AdminError(this.message);

  @override
  List<Object> get props => [message];
}

class AdminActionSuccess extends AdminState {
  final String message;
  
  const AdminActionSuccess(this.message);

  @override
  List<Object> get props => [message];
}
