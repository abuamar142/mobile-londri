import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/user.dart';
import '../repositories/manage_staff_repository.dart';

class ManageStaffGetUsers {
  final ManageStaffRepository manageStaffRepository;

  ManageStaffGetUsers({
    required this.manageStaffRepository,
  });

  Future<Either<Failure, List<User>>> call() async {
    return await manageStaffRepository.getUsers();
  }
}
