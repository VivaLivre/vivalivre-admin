import 'package:equatable/equatable.dart';
import '../../domain/entities/admin_user.dart';

abstract class UsersEvent extends Equatable {
  const UsersEvent();
  @override
  List<Object?> get props => [];
}

class FetchUsers extends UsersEvent {
  final int page;
  final int limit;
  final String search;

  const FetchUsers({this.page = 1, this.limit = 20, this.search = ''});

  @override
  List<Object?> get props => [page, limit, search];
}

class UpdateUserStatusEvent extends UsersEvent {
  final int userId;
  final String status;

  const UpdateUserStatusEvent({required this.userId, required this.status});

  @override
  List<Object?> get props => [userId, status];
}

// ── States ────────────────────────────────────────────────────────────────────

abstract class UsersState extends Equatable {
  const UsersState();
  @override
  List<Object?> get props => [];
}

class UsersInitial extends UsersState {
  const UsersInitial();
}

class UsersLoading extends UsersState {
  const UsersLoading();
}

class UsersLoaded extends UsersState {
  final List<AdminUser> users;
  final int total;
  final int currentPage;
  final int totalPages;
  final int limit;
  final String search;

  const UsersLoaded({
    required this.users,
    required this.total,
    required this.currentPage,
    required this.totalPages,
    required this.limit,
    required this.search,
  });

  @override
  List<Object?> get props =>
      [users, total, currentPage, totalPages, limit, search];
}

class UsersError extends UsersState {
  final String message;
  const UsersError(this.message);
  @override
  List<Object?> get props => [message];
}
