import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/bathroom.dart';
import '../../domain/entities/paginated_bathrooms_response.dart';
import '../../domain/repositories/i_bathroom_management_repository.dart';

// Events
abstract class BathroomCrudEvent {}

class FetchBathroomsEvent extends BathroomCrudEvent {
  final int page;
  final int limit;
  final String? search;

  FetchBathroomsEvent({this.page = 1, this.limit = 20, this.search});
}

class CreateBathroomEvent extends BathroomCrudEvent {
  final Map<String, dynamic> data;

  CreateBathroomEvent(this.data);
}

class UpdateBathroomEvent extends BathroomCrudEvent {
  final String id;
  final Map<String, dynamic> updates;

  UpdateBathroomEvent(this.id, this.updates);
}

class DeleteBathroomEvent extends BathroomCrudEvent {
  final String id;

  DeleteBathroomEvent(this.id);
}

// States
abstract class BathroomCrudState {}

class BathroomCrudLoading extends BathroomCrudState {}

class BathroomCrudLoaded extends BathroomCrudState {
  final List<Bathroom> bathrooms;
  final PaginationMeta meta;
  final String? searchQuery;

  BathroomCrudLoaded({
    required this.bathrooms,
    required this.meta,
    this.searchQuery,
  });
}

class BathroomCrudError extends BathroomCrudState {
  final String message;

  BathroomCrudError(this.message);
}

// BLoC
class BathroomCrudBloc extends Bloc<BathroomCrudEvent, BathroomCrudState> {
  final IBathroomManagementRepository repository;

  BathroomCrudBloc({required this.repository}) : super(BathroomCrudLoading()) {
    on<FetchBathroomsEvent>(_onFetchBathrooms);
    on<CreateBathroomEvent>(_onCreateBathroom);
    on<UpdateBathroomEvent>(_onUpdateBathroom);
    on<DeleteBathroomEvent>(_onDeleteBathroom);
  }

  Future<void> _onFetchBathrooms(FetchBathroomsEvent event, Emitter<BathroomCrudState> emit) async {
    emit(BathroomCrudLoading());
    try {
      final response = await repository.getAdminBathrooms(
        page: event.page,
        limit: event.limit,
        search: event.search,
      );
      emit(BathroomCrudLoaded(
        bathrooms: response.data,
        meta: response.meta,
        searchQuery: event.search,
      ));
    } catch (e) {
      emit(BathroomCrudError(e.toString()));
    }
  }

  Future<void> _onCreateBathroom(CreateBathroomEvent event, Emitter<BathroomCrudState> emit) async {
    final currentState = state;
    if (currentState is BathroomCrudLoaded) {
      emit(BathroomCrudLoading());
      try {
        await repository.createBathroom(event.data);
        add(FetchBathroomsEvent(
          page: 1, // Volta para a primeira página ao criar
          limit: currentState.meta.limit,
          search: currentState.searchQuery,
        ));
      } catch (e) {
        emit(BathroomCrudError(e.toString()));
      }
    } else {
      emit(BathroomCrudLoading());
      try {
        await repository.createBathroom(event.data);
        add(FetchBathroomsEvent());
      } catch (e) {
        emit(BathroomCrudError(e.toString()));
      }
    }
  }

  Future<void> _onUpdateBathroom(UpdateBathroomEvent event, Emitter<BathroomCrudState> emit) async {
    final currentState = state;
    if (currentState is BathroomCrudLoaded) {
      // Optamos por mostrar loading para evitar múltiplos cliques
      emit(BathroomCrudLoading());
      try {
        await repository.updateBathroom(event.id, event.updates);
        // Após atualizar, recarrega a página atual e termo de pesquisa
        add(FetchBathroomsEvent(
          page: currentState.meta.page,
          limit: currentState.meta.limit,
          search: currentState.searchQuery,
        ));
      } catch (e) {
        emit(BathroomCrudError(e.toString()));
      }
    }
  }

  Future<void> _onDeleteBathroom(DeleteBathroomEvent event, Emitter<BathroomCrudState> emit) async {
    final currentState = state;
    if (currentState is BathroomCrudLoaded) {
      emit(BathroomCrudLoading());
      try {
        await repository.deleteBathroom(event.id);
        add(FetchBathroomsEvent(
          page: currentState.meta.page,
          limit: currentState.meta.limit,
          search: currentState.searchQuery,
        ));
      } catch (e) {
        emit(BathroomCrudError(e.toString()));
      }
    }
  }
}
