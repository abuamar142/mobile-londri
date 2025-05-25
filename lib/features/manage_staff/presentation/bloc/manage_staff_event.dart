part of 'manage_staff_bloc.dart';

abstract class ManageStaffEvent extends Equatable {
  const ManageStaffEvent();

  @override
  List<Object> get props => [];
}

class ManageStaffEventGetUsers extends ManageStaffEvent {}

class ManageStaffEventSearchUser extends ManageStaffEvent {
  final String query;

  const ManageStaffEventSearchUser({
    required this.query,
  });

  @override
  List<Object> get props => [query];
}

class ManageStaffEventSortUsers extends ManageStaffEvent {
  final String sortBy;
  final bool ascending;

  const ManageStaffEventSortUsers({
    required this.sortBy,
    required this.ascending,
  });

  @override
  List<Object> get props => [sortBy, ascending];
}

class ManageStaffEventActivateStaff extends ManageStaffEvent {
  final User user;

  const ManageStaffEventActivateStaff({
    required this.user,
  });

  @override
  List<Object> get props => [
        user,
      ];
}

class ManageStaffEventDeactivateStaff extends ManageStaffEvent {
  final User user;

  const ManageStaffEventDeactivateStaff({
    required this.user,
  });

  @override
  List<Object> get props => [
        user,
      ];
}
