part of 'manage_employee_bloc.dart';

abstract class ManageEmployeeState extends Equatable {
  const ManageEmployeeState();

  @override
  List<Object> get props => [];
}

class ManageEmployeeInitial extends ManageEmployeeState {}

class ManageEmployeeLoading extends ManageEmployeeState {}

class ManageEmployeeSuccessGetUsers extends ManageEmployeeState {
  final List<User> users;

  const ManageEmployeeSuccessGetUsers({
    required this.users,
  });

  @override
  List<Object> get props => [
        users,
      ];
}

class ManageEmployeeStateWithFilteredUsers extends ManageEmployeeState {
  final List<User> allUsers;
  final List<User> filteredUsers;

  const ManageEmployeeStateWithFilteredUsers({
    required this.allUsers,
    required this.filteredUsers,
  });

  @override
  List<Object> get props => [allUsers, filteredUsers];
}

class ManageEmployeeFailure extends ManageEmployeeState {
  final String message;

  const ManageEmployeeFailure({
    required this.message,
  });

  @override
  List<Object> get props => [
        message,
      ];
}

class ManageEmployeeSuccessActivateEmployee extends ManageEmployeeState {
  final String name;

  const ManageEmployeeSuccessActivateEmployee({
    required this.name,
  });

  @override
  List<Object> get props => [
        name,
      ];
}

class ManageEmployeeSuccessDeactivateEmployee extends ManageEmployeeState {
  final String name;

  const ManageEmployeeSuccessDeactivateEmployee({
    required this.name,
  });

  @override
  List<Object> get props => [
        name,
      ];
}
