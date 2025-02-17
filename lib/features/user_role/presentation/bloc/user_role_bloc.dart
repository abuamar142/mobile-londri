import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/profile.dart';
import '../../domain/usecases/user_role_activate_user.dart';
import '../../domain/usecases/user_role_deactivate_user.dart';
import '../../domain/usecases/user_role_get_profiles.dart';

part 'user_role_event.dart';
part 'user_role_state.dart';

class UserRoleBloc extends Bloc<UserRoleEvent, UserRoleState> {
  final UserRoleGetProfiles userRoleGetProfiles;
  final UserRoleActivateUser userRoleActivateUser;
  final UserRoleDeactivateUser userRoleDeactivateUser;

  UserRoleBloc({
    required this.userRoleGetProfiles,
    required this.userRoleActivateUser,
    required this.userRoleDeactivateUser,
  }) : super(UserRoleInitial()) {
    on<UserRoleEventGetProfiles>((event, emit) async {
      emit(UserRoleLoading());

      Either<Failure, List<Profile>> result = await userRoleGetProfiles();

      result.fold((left) {
        emit(UserRoleFailure(
          message: left.message,
        ));
      }, (right) {
        emit(UserRoleSuccessGetProfiles(
          profiles: right,
        ));
      });
    });
    on<UserRoleEventActivateUser>((event, emit) async {
      emit(UserRoleLoading());

      Either<Failure, void> result = await userRoleActivateUser(
        event.userId,
        event.role,
      );

      result.fold((left) {
        emit(UserRoleFailure(
          message: left.message,
        ));
      }, (right) {
        emit(UserRoleSuccessActivateUser());
      });
    });
    on<UserRoleEventDeactivateUser>((event, emit) async {
      emit(UserRoleLoading());

      Either<Failure, void> result = await userRoleDeactivateUser(
        event.userId,
      );

      result.fold((left) {
        emit(UserRoleFailure(
          message: left.message,
        ));
      }, (right) {
        emit(UserRoleSuccessDeactivateUser());
      });
    });
  }
}
