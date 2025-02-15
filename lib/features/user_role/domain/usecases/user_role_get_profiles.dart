import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/profile.dart';
import '../repositories/user_role_repository.dart';

class UserRoleGetProfiles {
  final UserRoleRepository userRoleRepository;

  UserRoleGetProfiles({
    required this.userRoleRepository,
  });

  Future<Either<Failure, List<Profile>>> call() async {
    return await userRoleRepository.read();
  }
}
