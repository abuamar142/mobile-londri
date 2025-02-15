import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/profile.dart';
import '../../domain/usecases/user_role_get_profiles.dart';

part 'user_role_event.dart';
part 'user_role_state.dart';

class UserRoleBloc extends Bloc<UserRoleEvent, UserRoleState> {
  final UserRoleGetProfiles userRoleGetProfiles;

  UserRoleBloc({
    required this.userRoleGetProfiles,
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
  }
}
