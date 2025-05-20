import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/user.dart';

abstract class ManageEmployeeRepository {
  Future<Either<Failure, void>> activateEmployee(
    String userId,
  );
  Future<Either<Failure, List<User>>> getUsers();
  Future<Either<Failure, void>> deactivateEmployee(
    String userId,
  );
}
