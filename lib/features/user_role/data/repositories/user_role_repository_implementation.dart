import 'package:fpdart/fpdart.dart';

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
  Future<Either<Failure, void>> create(String userId, String role) {
    // TODO: implement create
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> delete(int id) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<Profile>>> read() async {
    try {
      final response = await userRoleRemoteDatasource.readProfile();

      return Right(response);
    } catch (e) {
      return Left(
        Failure(message: e.toString()),
      );
    }
  }

  @override
  Future<Either<Failure, void>> update(int id, String role) {
    // TODO: implement update
    throw UnimplementedError();
  }
}
