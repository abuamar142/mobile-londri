part of 'user_role_bloc.dart';

abstract class UserRoleState extends Equatable {
  const UserRoleState();

  @override
  List<Object> get props => [];
}

class UserRoleInitial extends UserRoleState {}

class UserRoleLoading extends UserRoleState {}

class UserRoleSuccessGetProfiles extends UserRoleState {
  final List<Profile> profiles;

  const UserRoleSuccessGetProfiles({
    required this.profiles,
  });

  @override
  List<Object> get props => [
        profiles,
      ];
}

class UserRoleFailure extends UserRoleState {
  final String message;

  const UserRoleFailure({
    required this.message,
  });

  @override
  List<Object> get props => [
        message,
      ];
}

class UserRoleSuccessActivateUser extends UserRoleState {}

class UserRoleSuccessDeactivateUser extends UserRoleState {}