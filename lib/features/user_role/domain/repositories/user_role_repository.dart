import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/profile.dart';

abstract class UserRoleRepository {
  Future<Either<Failure, void>> activateUser(
    String userId,
    String role,
  );
  Future<Either<Failure, List<Profile>>> getProfiles();
  Future<Either<Failure, void>> deactivateUser(
    String userId,
  );
}
