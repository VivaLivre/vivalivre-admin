import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/i_admin_moderation_repository.dart';
import 'admin_moderation_event.dart';
import 'admin_moderation_state.dart';

class AdminModerationBloc extends Bloc<AdminModerationEvent, AdminModerationState> {
  final IAdminModerationRepository repository;

  AdminModerationBloc({required this.repository}) : super(AdminModerationInitial()) {
    on<LoadPendingRequests>(_onLoadPendingRequests);
    on<ApproveRequest>(_onApproveRequest);
    on<RejectRequest>(_onRejectRequest);
  }

  Future<void> _onLoadPendingRequests(
    LoadPendingRequests event,
    Emitter<AdminModerationState> emit,
  ) async {
    emit(AdminModerationLoading());
    try {
      final requests = await repository.getPendingRequests();
      emit(AdminModerationLoaded(requests));
    } catch (e) {
      emit(AdminModerationError(e.toString()));
    }
  }

  Future<void> _onApproveRequest(
    ApproveRequest event,
    Emitter<AdminModerationState> emit,
  ) async {
    try {
      // Idealmente poderíamos emitir um estado de loading ou apenas aguardar a ação
      await repository.updateRequestStatus(event.id, 'approved');
      add(LoadPendingRequests());
    } catch (e) {
      emit(AdminModerationError(e.toString()));
    }
  }

  Future<void> _onRejectRequest(
    RejectRequest event,
    Emitter<AdminModerationState> emit,
  ) async {
    try {
      await repository.updateRequestStatus(event.id, 'rejected');
      add(LoadPendingRequests());
    } catch (e) {
      emit(AdminModerationError(e.toString()));
    }
  }
}
