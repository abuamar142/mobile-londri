import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/manage_staff_activate_staff.dart';
import '../../domain/usecases/manage_staff_deactivate_staff.dart';
import '../../domain/usecases/manage_staff_get_users.dart';

part 'manage_staff_event.dart';
part 'manage_staff_state.dart';

class ManageStaffBloc extends Bloc<ManageStaffEvent, ManageStaffState> {
  final ManageStaffGetUsers manageStaffGetUsers;
  final ManageStaffActivateStaff manageStaffActivateStaff;
  final ManageStaffDeactivateStaff manageStaffDeactivateStaff;

  ManageStaffBloc({
    required this.manageStaffGetUsers,
    required this.manageStaffActivateStaff,
    required this.manageStaffDeactivateStaff,
  }) : super(ManageStaffInitial()) {
    on<ManageStaffEventGetUsers>(
      (event, emit) => onManageStaffEventGetUsers(event, emit),
    );
    on<ManageStaffEventSearchUser>(
      (event, emit) => onManageStaffEventSearchUser(event, emit),
    );
    on<ManageStaffEventSortUsers>(
      (event, emit) => onManageStaffEventSortUsers(event, emit),
    );
    on<ManageStaffEventActivateStaff>(
      (event, emit) => onManageStaffEventActivateStaff(event, emit),
    );
    on<ManageStaffEventDeactivateStaff>(
      (event, emit) => onManageStaffEventDeactivateStaff(event, emit),
    );
  }

  late List<User> _allUsers;
  String _currentQuery = '';
  String _currentSortField = 'name';
  bool _isAscending = true;

  String get currentSortField => _currentSortField;
  bool get isAscending => _isAscending;

  void onManageStaffEventGetUsers(
    ManageStaffEventGetUsers event,
    Emitter<ManageStaffState> emit,
  ) async {
    emit(ManageStaffLoading());

    final result = await manageStaffGetUsers();

    result.fold((left) {
      emit(ManageStaffFailure(message: left.message));
    }, (right) {
      _allUsers = right;

      emit(ManageStaffStateWithFilteredUsers(
        allUsers: _allUsers,
        filteredUsers: _sortAndFilter(
          _allUsers,
          _currentQuery,
          _currentSortField,
          _isAscending,
        ),
      ));
    });
  }

  void onManageStaffEventSearchUser(
    ManageStaffEventSearchUser event,
    Emitter<ManageStaffState> emit,
  ) {
    _currentQuery = event.query;
    final filtered = _sortAndFilter(
      _allUsers,
      _currentQuery,
      _currentSortField,
      _isAscending,
    );
    emit(ManageStaffStateWithFilteredUsers(
      allUsers: _allUsers,
      filteredUsers: filtered,
    ));
  }

  void onManageStaffEventSortUsers(
    ManageStaffEventSortUsers event,
    Emitter<ManageStaffState> emit,
  ) {
    _currentSortField = event.sortBy;
    _isAscending = event.ascending;

    final filtered = _sortAndFilter(
      _allUsers,
      _currentQuery,
      _currentSortField,
      _isAscending,
    );

    emit(ManageStaffStateWithFilteredUsers(
      allUsers: _allUsers,
      filteredUsers: filtered,
    ));
  }

  List<User> _sortAndFilter(
    List<User> users,
    String query,
    String sortField,
    bool ascending,
  ) {
    final lowerQuery = query.toLowerCase();
    List<User> filtered = users.where((user) => user.name.toLowerCase().contains(lowerQuery) || user.email.toLowerCase().contains(lowerQuery)).toList();

    filtered.sort((a, b) {
      int result;

      switch (sortField) {
        case 'name':
          result = a.name.compareTo(b.name);
          break;
        case 'email':
          result = a.email.compareTo(b.email);
          break;
        case 'role':
          result = a.role!.compareTo(b.role!);
          break;
        default:
          result = a.name.compareTo(b.name);
      }

      return ascending ? result : -result;
    });

    return filtered;
  }

  void onManageStaffEventActivateStaff(
    ManageStaffEventActivateStaff event,
    Emitter<ManageStaffState> emit,
  ) async {
    emit(ManageStaffLoading());

    Either<Failure, void> result = await manageStaffActivateStaff(
      event.user.id,
    );

    result.fold((left) {
      emit(ManageStaffFailure(
        message: left.message,
      ));
    }, (right) {
      emit(ManageStaffSuccessActivateStaff(
        name: event.user.name,
      ));
      add(ManageStaffEventGetUsers());
    });
  }

  void onManageStaffEventDeactivateStaff(
    ManageStaffEventDeactivateStaff event,
    Emitter<ManageStaffState> emit,
  ) async {
    emit(ManageStaffLoading());

    Either<Failure, void> result = await manageStaffDeactivateStaff(
      event.user.id,
    );

    result.fold((left) {
      emit(ManageStaffFailure(
        message: left.message,
      ));
    }, (right) {
      emit(ManageStaffSuccessDeactivateStaff(
        name: event.user.name,
      ));
      add(ManageStaffEventGetUsers());
    });
  }
}
