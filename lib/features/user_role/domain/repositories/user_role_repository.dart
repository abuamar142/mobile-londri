import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/profile.dart';

abstract class UserRoleRepository {
  Future<Either<Failure, void>> create(
    String userId,
    String role,
  );
  Future<Either<Failure, List<Profile>>> read();
  Future<Either<Failure, void>> update(
    int id,
    String role,
  );
  Future<Either<Failure, void>> delete(
    int id,
  );
}
