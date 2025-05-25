import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/user.dart';

abstract class ManageStaffRepository {
  Future<Either<Failure, void>> activateStaff(
    String userId,
  );
  Future<Either<Failure, List<User>>> getUsers();
  Future<Either<Failure, void>> deactivateStaff(
    String userId,
  );
}
