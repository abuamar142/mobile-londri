import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/get_user_role_from_jwt.dart';
import '../../domain/entities/auth.dart';
import '../../domain/entities/role_manager.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImplementation extends AuthRepository {
  final AuthRemoteDatasource authRemoteDatasource;

  AuthRepositoryImplementation({
    required this.authRemoteDatasource,
  });

  @override
  Future<Either<Failure, Auth>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await authRemoteDatasource.login(
        email,
        password,
      );

      AuthManager.setCurrentUser(response);

      if (response.accessToken == null) {
        RoleManager.setUserRole('user');
      } else {
        final userRole = response.accessToken!.getUserRoleFromJwt();

        RoleManager.setUserRole(userRole);

        await authRemoteDatasource.saveAuth(response.id, response.accessToken!);
      }

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
  Future<Either<Failure, void>> register(
    String email,
    String password,
    String name,
  ) async {
    try {
      await authRemoteDatasource.register(
        email,
        password,
        name,
      );

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
  Future<Either<Failure, void>> logout() async {
    try {
      await authRemoteDatasource.logout();

      AuthManager.clearCurrentUser();
      RoleManager.setUserRole('');

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

  @override
  Future<Either<Failure, Auth?>> checkInitialState() async {
    try {
      final authData = await authRemoteDatasource.checkInitialState();

      if (authData != null) {
        // Set the current user in AuthManager
        AuthManager.setCurrentUser(authData);

        // Set user role from stored token
        final userRole = authData.accessToken!.getUserRoleFromJwt();
        RoleManager.setUserRole(userRole);

        return Right(authData);
      }

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
