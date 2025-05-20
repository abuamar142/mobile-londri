import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/manage_employee_activate_employee.dart';
import '../../domain/usecases/manage_employee_deactivate_employee.dart';
import '../../domain/usecases/manage_employee_get_users.dart';

part 'manage_employee_event.dart';
part 'manage_employee_state.dart';

class ManageEmployeeBloc
    extends Bloc<ManageEmployeeEvent, ManageEmployeeState> {
  final ManageEmployeeGetUsers manageEmployeeGetUsers;
  final ManageEmployeeActivateEmployee manageEmployeeActivateEmployee;
  final ManageEmployeeDeactivateEmployee manageEmployeeDeactivateEmployee;

  ManageEmployeeBloc({
    required this.manageEmployeeGetUsers,
    required this.manageEmployeeActivateEmployee,
    required this.manageEmployeeDeactivateEmployee,
  }) : super(ManageEmployeeInitial()) {
    on<ManageEmployeeEventGetUsers>(
      (event, emit) => onManageEmployeeEventGetUsers(event, emit),
    );
    on<ManageEmployeeEventSearchUser>(
      (event, emit) => onManageEmployeeEventSearchUser(event, emit),
    );
    on<ManageEmployeeEventSortUsers>(
      (event, emit) => onManageEmployeeEventSortUsers(event, emit),
    );
    on<ManageEmployeeEventActivateEmployee>(
      (event, emit) => onManageEmployeeEventActivateEmployee(event, emit),
    );
    on<ManageEmployeeEventDeactivateEmployee>(
      (event, emit) => onManageEmployeeEventDeactivateEmployee(event, emit),
    );
  }

  late List<User> _allUsers;
  String _currentQuery = '';
  String _currentSortField = 'name';
  bool _isAscending = true;

  String get currentSortField => _currentSortField;
  bool get isAscending => _isAscending;

  void onManageEmployeeEventGetUsers(
    ManageEmployeeEventGetUsers event,
    Emitter<ManageEmployeeState> emit,
  ) async {
    emit(ManageEmployeeLoading());

    final result = await manageEmployeeGetUsers();

    result.fold((left) {
      emit(ManageEmployeeFailure(message: left.message));
    }, (right) {
      _allUsers = right;

      emit(ManageEmployeeStateWithFilteredUsers(
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

  void onManageEmployeeEventSearchUser(
    ManageEmployeeEventSearchUser event,
    Emitter<ManageEmployeeState> emit,
  ) {
    _currentQuery = event.query;
    final filtered = _sortAndFilter(
      _allUsers,
      _currentQuery,
      _currentSortField,
      _isAscending,
    );
    emit(ManageEmployeeStateWithFilteredUsers(
      allUsers: _allUsers,
      filteredUsers: filtered,
    ));
  }

  void onManageEmployeeEventSortUsers(
    ManageEmployeeEventSortUsers event,
    Emitter<ManageEmployeeState> emit,
  ) {
    _currentSortField = event.sortBy;
    _isAscending = event.ascending;

    final filtered = _sortAndFilter(
      _allUsers,
      _currentQuery,
      _currentSortField,
      _isAscending,
    );

    emit(ManageEmployeeStateWithFilteredUsers(
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
    List<User> filtered = users
        .where((user) =>
            user.name.toLowerCase().contains(lowerQuery) ||
            user.email.toLowerCase().contains(lowerQuery))
        .toList();

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
        case 'status':
          final aStatus = a.role == 'admin' ? 1 : 0;
          final bStatus = b.role == 'admin' ? 1 : 0;
          result = aStatus.compareTo(bStatus);
          break;
        default:
          result = a.name.compareTo(b.name);
      }

      return ascending ? result : -result;
    });

    return filtered;
  }

  void onManageEmployeeEventActivateEmployee(
    ManageEmployeeEventActivateEmployee event,
    Emitter<ManageEmployeeState> emit,
  ) async {
    emit(ManageEmployeeLoading());

    Either<Failure, void> result = await manageEmployeeActivateEmployee(
      event.user.id,
    );

    result.fold((left) {
      emit(ManageEmployeeFailure(
        message: left.message,
      ));
    }, (right) {
      emit(ManageEmployeeSuccessActivateEmployee(
        name: event.user.name,
      ));
      add(ManageEmployeeEventGetUsers());
    });
  }

  void onManageEmployeeEventDeactivateEmployee(
    ManageEmployeeEventDeactivateEmployee event,
    Emitter<ManageEmployeeState> emit,
  ) async {
    emit(ManageEmployeeLoading());

    Either<Failure, void> result = await manageEmployeeDeactivateEmployee(
      event.user.id,
    );

    result.fold((left) {
      emit(ManageEmployeeFailure(
        message: left.message,
      ));
    }, (right) {
      emit(ManageEmployeeSuccessDeactivateEmployee(
        name: event.user.name,
      ));
      add(ManageEmployeeEventGetUsers());
    });
  }
}
