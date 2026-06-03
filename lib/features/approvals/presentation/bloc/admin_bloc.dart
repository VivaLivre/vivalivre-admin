import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/admin_repository.dart';
import 'admin_event.dart';
import 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final AdminRepository repository;

  AdminBloc({required this.repository}) : super(AdminInitial()) {
    on<LoadPendingRequests>(_onLoadPendingRequests);
    on<ApproveRequest>(_onApproveRequest);
    on<RejectRequest>(_onRejectRequest);
  }

  Future<void> _onLoadPendingRequests(
    LoadPendingRequests event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    try {
      final requests = await repository.getPendingBathrooms();
      emit(AdminLoaded(requests));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onApproveRequest(
    ApproveRequest event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await repository.updateBathroomStatus(event.id, 'approved');
      // "Regra de Ouro": disparar LoadPendingRequests imediatamente após sucesso
      add(LoadPendingRequests());
    } catch (e) {
      emit(AdminError('Failed to approve: ${e.toString()}'));
      // Voltar a carregar a lista de qualquer forma para garantir o estado correto
      add(LoadPendingRequests());
    }
  }

  Future<void> _onRejectRequest(
    RejectRequest event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await repository.updateBathroomStatus(event.id, 'rejected');
      // "Regra de Ouro": disparar LoadPendingRequests imediatamente após sucesso
      add(LoadPendingRequests());
    } catch (e) {
      emit(AdminError('Failed to reject: ${e.toString()}'));
      // Voltar a carregar a lista de qualquer forma para garantir o estado correto
      add(LoadPendingRequests());
    }
  }
}
