part of 'manage_staff_bloc.dart';

abstract class ManageStaffState extends Equatable {
  const ManageStaffState();

  @override
  List<Object> get props => [];
}

class ManageStaffInitial extends ManageStaffState {}

class ManageStaffLoading extends ManageStaffState {}

class ManageStaffSuccessGetUsers extends ManageStaffState {
  final List<User> users;

  const ManageStaffSuccessGetUsers({
    required this.users,
  });

  @override
  List<Object> get props => [
        users,
      ];
}

class ManageStaffStateWithFilteredUsers extends ManageStaffState {
  final List<User> allUsers;
  final List<User> filteredUsers;

  const ManageStaffStateWithFilteredUsers({
    required this.allUsers,
    required this.filteredUsers,
  });

  @override
  List<Object> get props => [allUsers, filteredUsers];
}

class ManageStaffFailure extends ManageStaffState {
  final String message;

  const ManageStaffFailure({
    required this.message,
  });

  @override
  List<Object> get props => [
        message,
      ];
}

class ManageStaffSuccessActivateStaff extends ManageStaffState {
  final String name;

  const ManageStaffSuccessActivateStaff({
    required this.name,
  });

  @override
  List<Object> get props => [
        name,
      ];
}

class ManageStaffSuccessDeactivateStaff extends ManageStaffState {
  final String name;

  const ManageStaffSuccessDeactivateStaff({
    required this.name,
  });

  @override
  List<Object> get props => [
        name,
      ];
}
