part of 'user_role_bloc.dart';

abstract class UserRoleEvent extends Equatable {
  const UserRoleEvent();

  @override
  List<Object> get props => [];
}

class UserRoleEventGetProfiles extends UserRoleEvent {}

class UserRoleEventActivateUser extends UserRoleEvent {
  final String userId;
  final String role;

  const UserRoleEventActivateUser({
    required this.userId,
    required this.role,
  });

  @override
  List<Object> get props => [
        userId,
        role,
      ];
}

class UserRoleEventDeactivateUser extends UserRoleEvent {
  final String userId;

  const UserRoleEventDeactivateUser({
    required this.userId,
  });

  @override
  List<Object> get props => [
        userId,
      ];
}
