import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/auth.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImplementation extends AuthRepository {
  final AuthRemoteDatasource authRemoteDatasource;

  AuthRepositoryImplementation({
    required this.authRemoteDatasource,
  });

  @override
  Future<Either<Failure, Auth>> login(String email, String password) async {
    try {
      final response = await authRemoteDatasource.login(
        email,
        password,
      );

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
  Future<Either<Failure, Auth>> register(
    String email,
    String password,
    String name,
  ) async {
    try {
      final response = await authRemoteDatasource.register(
        email,
        password,
        name,
      );

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
  Future<Either<Failure, void>> logout() async {
    try {
      await authRemoteDatasource.logout();

      return const Right(null);
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
