import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/user_role_repository.dart';
import '../datasources/user_role_remote_datasource.dart';

class UserRoleRepositoryImplementation extends UserRoleRepository {
  final UserRoleRemoteDatasource userRoleRemoteDatasource;

  UserRoleRepositoryImplementation({
    required this.userRoleRemoteDatasource,
  });

  @override
  Future<Either<Failure, void>> activateUser(String userId, String role) async {
    try {
      await userRoleRemoteDatasource.createUserRole(userId, role);

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
  Future<Either<Failure, List<Profile>>> getProfiles() async {
    try {
      final response = await userRoleRemoteDatasource.readProfiles();

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
  Future<Either<Failure, void>> deactivateUser(String userId) async {
    try {
      await userRoleRemoteDatasource.deleteUserRole(userId);

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
