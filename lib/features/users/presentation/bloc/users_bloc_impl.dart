import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/i_admin_user_repository.dart';
import 'users_bloc.dart';

class UsersBlocImpl extends Bloc<UsersEvent, UsersState> {
  final IAdminUserRepository repository;

  UsersBlocImpl({required this.repository}) : super(const UsersInitial()) {
    on<FetchUsers>(_onFetchUsers);
    on<UpdateUserStatusEvent>(_onUpdateUserStatus);
  }

  Future<void> _onFetchUsers(
    FetchUsers event,
    Emitter<UsersState> emit,
  ) async {
    emit(const UsersLoading());
    try {
      final result = await repository.getUsers(
        page: event.page,
        limit: event.limit,
        search: event.search,
      );
      emit(UsersLoaded(
        users: result.data,
        total: result.meta.total,
        currentPage: result.meta.page,
        totalPages: result.meta.totalPages,
        limit: result.meta.limit,
        search: event.search,
      ));
    } catch (e) {
      emit(UsersError('Erro ao carregar utilizadores: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateUserStatus(
    UpdateUserStatusEvent event,
    Emitter<UsersState> emit,
  ) async {
    final currentState = state;
    try {
      await repository.updateUserStatus(event.userId, event.status);
      // Re-fetch current page to reflect changes
      if (currentState is UsersLoaded) {
        final result = await repository.getUsers(
          page: currentState.currentPage,
          limit: currentState.limit,
          search: currentState.search,
        );
        emit(UsersLoaded(
          users: result.data,
          total: result.meta.total,
          currentPage: result.meta.page,
          totalPages: result.meta.totalPages,
          limit: result.meta.limit,
          search: currentState.search,
        ));
      }
    } catch (e) {
      emit(UsersError('Erro ao atualizar status: ${e.toString()}'));
    }
  }
}
