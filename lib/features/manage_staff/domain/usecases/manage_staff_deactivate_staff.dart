import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../repositories/manage_staff_repository.dart';

class ManageStaffDeactivateStaff {
  final ManageStaffRepository manageStaffRepository;

  ManageStaffDeactivateStaff({
    required this.manageStaffRepository,
  });

  Future<Either<Failure, void>> call(
    String userId,
  ) async {
    return await manageStaffRepository.deactivateStaff(
      userId,
    );
  }
}
