import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../repositories/user_role_repository.dart';

class UserRoleDelete {
  final UserRoleRepository userRoleRepository;

  UserRoleDelete({
    required this.userRoleRepository,
  });

  Future<Either<Failure, void>> call(
    int id,
  ) async {
    return await userRoleRepository.delete(
      id,
    );
  }
}
