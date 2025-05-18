import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../repositories/user_role_repository.dart';

class UserRoleActivateUser {
  final UserRoleRepository userRoleRepository;

  UserRoleActivateUser({
    required this.userRoleRepository,
  });

  Future<Either<Failure, void>> call(
    String userId,
    String role,
  ) async {
    return await userRoleRepository.activateUser(
      userId,
    );
  }
}
