import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../domain/repositories/manage_employee_repository.dart';
import '../datasources/manage_employee_remote_datasource.dart';
import '../models/user_model.dart';

class ManageEmployeeRepositoryImplementation extends ManageEmployeeRepository {
  final ManageEmployeeRemoteDatasource manageEmployeeRemoteDatasource;

  ManageEmployeeRepositoryImplementation({
    required this.manageEmployeeRemoteDatasource,
  });

  @override
  Future<Either<Failure, void>> activateEmployee(String userId) async {
    try {
      await manageEmployeeRemoteDatasource.updateRoleToAdmin(userId);

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
      final response = await manageEmployeeRemoteDatasource.readUsers();

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
  Future<Either<Failure, void>> deactivateEmployee(String userId) async {
    try {
      await manageEmployeeRemoteDatasource.updateRoleToUser(userId);

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
