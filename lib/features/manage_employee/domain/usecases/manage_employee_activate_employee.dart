import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../repositories/manage_employee_repository.dart';

class ManageEmployeeActivateEmployee {
  final ManageEmployeeRepository manageEmployeeRepository;

  ManageEmployeeActivateEmployee({
    required this.manageEmployeeRepository,
  });

  Future<Either<Failure, void>> call(
    String userId,
  ) async {
    return await manageEmployeeRepository.activateEmployee(
      userId,
    );
  }
}
