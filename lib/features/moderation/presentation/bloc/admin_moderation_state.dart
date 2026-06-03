import '../../domain/entities/bathroom_request_entity.dart';

abstract class AdminModerationState {}

class AdminModerationInitial extends AdminModerationState {}

class AdminModerationLoading extends AdminModerationState {}

class AdminModerationLoaded extends AdminModerationState {
  final List<BathroomRequestEntity> requests;

  AdminModerationLoaded(this.requests);
}

class AdminModerationError extends AdminModerationState {
  final String message;

  AdminModerationError(this.message);
}
