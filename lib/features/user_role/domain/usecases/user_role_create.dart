import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../repositories/user_role_repository.dart';

class UserRoleCreate {
  final UserRoleRepository userRoleRepository;

  UserRoleCreate({
    required this.userRoleRepository,
  });

  Future<Either<Failure, void>> call(
    String userId,
    String role,
  ) async {
    return await userRoleRepository.create(
      userId,
      role,
    );
  }
}
