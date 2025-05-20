part of 'manage_employee_bloc.dart';

abstract class ManageEmployeeEvent extends Equatable {
  const ManageEmployeeEvent();

  @override
  List<Object> get props => [];
}

class ManageEmployeeEventGetUsers extends ManageEmployeeEvent {}

class ManageEmployeeEventSearchUser extends ManageEmployeeEvent {
  final String query;

  const ManageEmployeeEventSearchUser({
    required this.query,
  });

  @override
  List<Object> get props => [query];
}

class ManageEmployeeEventSortUsers extends ManageEmployeeEvent {
  final String sortBy;
  final bool ascending;

  const ManageEmployeeEventSortUsers({
    required this.sortBy,
    required this.ascending,
  });

  @override
  List<Object> get props => [sortBy, ascending];
}

class ManageEmployeeEventActivateEmployee extends ManageEmployeeEvent {
  final User user;

  const ManageEmployeeEventActivateEmployee({
    required this.user,
  });

  @override
  List<Object> get props => [
        user,
      ];
}

class ManageEmployeeEventDeactivateEmployee extends ManageEmployeeEvent {
  final User user;

  const ManageEmployeeEventDeactivateEmployee({
    required this.user,
  });

  @override
  List<Object> get props => [
        user,
      ];
}
