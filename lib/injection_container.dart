import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_observer.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_implementation.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/auth_login.dart';
import 'features/auth/domain/usecases/auth_logout.dart';
import 'features/auth/domain/usecases/auth_register.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/user_role/data/datasources/user_role_remote_datasource.dart';
import 'features/user_role/data/repositories/user_role_repository_implementation.dart';
import 'features/user_role/domain/repositories/user_role_repository.dart';
import 'features/user_role/domain/usecases/user_role_activate_user.dart';
import 'features/user_role/domain/usecases/user_role_deactivate_user.dart';
import 'features/user_role/domain/usecases/user_role_get_profiles.dart';
import 'features/user_role/presentation/bloc/user_role_bloc.dart';

final serviceLocator = GetIt.instance;

Future<void> initializeDependencies() async {
  // Flutter Dotenv
  await dotenv.load(fileName: ".env");

  // Bloc Observer
  Bloc.observer = AppObserver();

  // Feature - Auth
  // Supabase
  serviceLocator
    ..registerLazySingleton<SupabaseClient>(
      () => SupabaseClient(
        dotenv.env['SUPABASE_URL']!,
        dotenv.env['SUPABASE_KEY']!,
        headers: {
          'Authorization': 'Bearer ${dotenv.env['SUPABASE_TOKEN']!}',
        },
        authOptions: const AuthClientOptions(
          authFlowType: AuthFlowType.implicit,
        ),
      ),
    )

    // DataSources
    ..registerLazySingleton<AuthRemoteDatasource>(
      () => AuthRemoteDatasourceImplementation(
        supabaseClient: serviceLocator(),
      ),
    )

    // Repositories
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImplementation(
        authRemoteDatasource: serviceLocator(),
      ),
    )

    // UseCases
    ..registerLazySingleton<AuthLogin>(
      () => AuthLogin(
        authRepository: serviceLocator(),
      ),
    )
    ..registerLazySingleton<AuthRegister>(
      () => AuthRegister(
        authRepository: serviceLocator(),
      ),
    )
    ..registerLazySingleton<AuthLogout>(
      () => AuthLogout(
        authRepository: serviceLocator(),
      ),
    )

    // Bloc
    ..registerFactory<AuthBloc>(
      () => AuthBloc(
        authLogin: serviceLocator(),
        authRegister: serviceLocator(),
        authLogout: serviceLocator(),
      ),
    )

    // Feature - User Role
    // DataSources
    ..registerLazySingleton<UserRoleRemoteDatasource>(
      () => UserRoleRemoteDataSourceImplementation(
        supabaseClient: serviceLocator(),
      ),
    )

    // Repositories
    ..registerLazySingleton<UserRoleRepository>(
      () => UserRoleRepositoryImplementation(
        userRoleRemoteDatasource: serviceLocator(),
      ),
    )

    // UseCases
    ..registerLazySingleton<UserRoleGetProfiles>(
      () => UserRoleGetProfiles(
        userRoleRepository: serviceLocator(),
      ),
    )
    ..registerLazySingleton<UserRoleActivateUser>(
      () => UserRoleActivateUser(
        userRoleRepository: serviceLocator(),
      ),
    )
    ..registerLazySingleton<UserRoleDeactivateUser>(
      () => UserRoleDeactivateUser(
        userRoleRepository: serviceLocator(),
      ),
    )

    // Bloc
    ..registerFactory<UserRoleBloc>(
      () => UserRoleBloc(
        userRoleGetProfiles: serviceLocator(),
        userRoleActivateUser: serviceLocator(),
        userRoleDeactivateUser: serviceLocator(),
      ),
    );
}
