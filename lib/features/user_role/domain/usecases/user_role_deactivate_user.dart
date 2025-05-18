import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../repositories/user_role_repository.dart';

class UserRoleDeactivateUser {
  final UserRoleRepository userRoleRepository;

  UserRoleDeactivateUser({
    required this.userRoleRepository,
  });

  Future<Either<Failure, void>> call(
    String userId,
  ) async {
    return await userRoleRepository.deactivateUser(
      userId,
    );
  }
}
