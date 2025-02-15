import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../repositories/user_role_repository.dart';

class UserRoleUpdate {
  final UserRoleRepository userRoleRepository;

  UserRoleUpdate({
    required this.userRoleRepository,
  });

  Future<Either<Failure, void>> call(
    int id,
    String role,
  ) async {
    return await userRoleRepository.update(
      id,
      role,
    );
  }
}
