import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/user.dart';
import '../repositories/manage_employee_repository.dart';

class ManageEmployeeGetUsers {
  final ManageEmployeeRepository manageEmployeeRepository;

  ManageEmployeeGetUsers({
    required this.manageEmployeeRepository,
  });

  Future<Either<Failure, List<User>>> call() async {
    return await manageEmployeeRepository.getUsers();
  }
}
