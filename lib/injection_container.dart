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
    );
}
