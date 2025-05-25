import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../domain/repositories/manage_staff_repository.dart';
import '../datasources/manage_staff_remote_datasource.dart';
import '../models/user_model.dart';

class ManageStaffRepositoryImplementation extends ManageStaffRepository {
  final ManageStaffRemoteDatasource manageStaffRemoteDatasource;

  ManageStaffRepositoryImplementation({
    required this.manageStaffRemoteDatasource,
  });

  @override
  Future<Either<Failure, void>> activateStaff(String userId) async {
    try {
      await manageStaffRemoteDatasource.updateRoleToAdmin(userId);

      return Right(null);
    } on ServerException catch (e) {
      return Left(
        Failure(message: e.message),
      );
    } catch (e) {
      return Left(
        Failure(message: e.toString()),
      );
    }
  }

  @override
  Future<Either<Failure, List<UserModel>>> getUsers() async {
    try {
      final response = await manageStaffRemoteDatasource.readUsers();

      return Right(response);
    } on ServerException catch (e) {
      return Left(
        Failure(message: e.message),
      );
    } catch (e) {
      return Left(
        Failure(message: e.toString()),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deactivateStaff(String userId) async {
    try {
      await manageStaffRemoteDatasource.updateRoleToUser(userId);

      return Right(null);
    } on ServerException catch (e) {
      return Left(
        Failure(message: e.message),
      );
    } catch (e) {
      return Left(
        Failure(message: e.toString()),
      );
    }
  }
}
