import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_observer.dart';
import 'core/services/auth_service.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_implementation.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/auth_login.dart';
import 'features/auth/domain/usecases/auth_logout.dart';
import 'features/auth/domain/usecases/auth_register.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/customer/data/datasources/customer_remote_datasource.dart';
import 'features/customer/data/repositories/customer_repository_implementation.dart';
import 'features/customer/domain/repositories/customer_repository.dart';
import 'features/customer/domain/usecases/customer_activate_customer.dart';
import 'features/customer/domain/usecases/customer_create_customer.dart';
import 'features/customer/domain/usecases/customer_delete_customer.dart';
import 'features/customer/domain/usecases/customer_get_customers.dart';
import 'features/customer/domain/usecases/customer_update_customer.dart';
import 'features/customer/presentation/bloc/customer_bloc.dart';
import 'features/service/data/datasources/service_remote_datasource.dart';
import 'features/service/data/repositories/service_repository_implementation.dart';
import 'features/service/domain/repositories/service_repository.dart';
import 'features/service/domain/usecases/service_create_service.dart';
import 'features/service/domain/usecases/service_delete_service.dart';
import 'features/service/domain/usecases/service_get_service_by_id.dart';
import 'features/service/domain/usecases/service_get_services.dart';
import 'features/service/domain/usecases/service_update_service.dart';
import 'features/service/presentation/bloc/service_bloc.dart';
import 'features/transaction/data/datasources/transaction_remote_datasource.dart';
import 'features/transaction/data/repositories/transaction_repository_implementation.dart';
import 'features/transaction/domain/repositories/transaction_repository.dart';
import 'features/transaction/domain/usecases/transaction_get_transactions.dart';
import 'features/transaction/presentation/bloc/transaction_bloc.dart';
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
        authOptions: const AuthClientOptions(
          authFlowType: AuthFlowType.implicit,
        ),
      ),
    )

    // Auth Service
    ..registerLazySingleton<AuthService>(
      () => AuthService(
        supabaseClient: serviceLocator(),
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
    )

    // Feature - Service
    // DataSources
    ..registerLazySingleton<ServiceRemoteDatasource>(
      () => ServiceRemoteDatasourceImplementation(
        supabaseClient: serviceLocator(),
      ),
    )

    // Repositories
    ..registerLazySingleton<ServiceRepository>(
      () => ServiceRepositoryImplementation(
        serviceRemoteDatasource: serviceLocator(),
      ),
    )

    // UseCases
    ..registerLazySingleton<ServiceGetServices>(
      () => ServiceGetServices(
        serviceRepository: serviceLocator(),
      ),
    )
    ..registerLazySingleton<ServiceGetServiceById>(
      () => ServiceGetServiceById(
        serviceRepository: serviceLocator(),
      ),
    )
    ..registerLazySingleton<ServiceCreateService>(
      () => ServiceCreateService(
        serviceRepository: serviceLocator(),
      ),
    )
    ..registerLazySingleton<ServiceUpdateService>(
      () => ServiceUpdateService(
        serviceRepository: serviceLocator(),
      ),
    )
    ..registerLazySingleton<ServiceDeleteService>(
      () => ServiceDeleteService(
        serviceRepository: serviceLocator(),
      ),
    )

    // Bloc
    ..registerFactory(
      () => ServiceBloc(
        serviceGetServices: serviceLocator(),
        serviceGetServiceById: serviceLocator(),
        serviceCreateService: serviceLocator(),
        serviceUpdateService: serviceLocator(),
        serviceDeleteService: serviceLocator(),
      ),
    )

    // Feature - Customer
    // DataSources
    ..registerLazySingleton<CustomerRemoteDatasource>(
      () => CustomerRemoteDatasourceImplementation(
        supabaseClient: serviceLocator(),
      ),
    )

    // Repositories
    ..registerLazySingleton<CustomerRepository>(
      () => CustomerRepositoryImplementation(
        customerRemoteDatasource: serviceLocator(),
      ),
    )

    // UseCases
    ..registerLazySingleton<CustomerGetCustomers>(
      () => CustomerGetCustomers(
        customerRepository: serviceLocator(),
      ),
    )
    ..registerLazySingleton<CustomerCreateCustomer>(
      () => CustomerCreateCustomer(
        customerRepository: serviceLocator(),
      ),
    )
    ..registerLazySingleton<CustomerUpdateCustomer>(
      () => CustomerUpdateCustomer(
        customerRepository: serviceLocator(),
      ),
    )
    ..registerLazySingleton<CustomerDeleteCustomer>(
      () => CustomerDeleteCustomer(
        customerRepository: serviceLocator(),
      ),
    )
    ..registerLazySingleton<CustomerActivateCustomer>(
      () => CustomerActivateCustomer(
        customerRepository: serviceLocator(),
      ),
    )

    // Bloc
    ..registerFactory(
      () => CustomerBloc(
        customerGetCustomers: serviceLocator(),
        customerCreateCustomer: serviceLocator(),
        customerUpdateCustomer: serviceLocator(),
        customerDeleteCustomer: serviceLocator(),
        customerActivateCustomer: serviceLocator(),
      ),
    )

    // Feature - Transaction
    // DataSources
    ..registerLazySingleton<TransactionRemoteDatasource>(
      () => TransactionRemoteDatasourceImplementation(
        supabaseClient: serviceLocator(),
      ),
    )

    // Repositories
    ..registerLazySingleton<TransactionRepository>(
      () => TransactionRepositoryImplementation(
        transactionRemoteDatasource: serviceLocator(),
      ),
    )

    // UseCases
    ..registerLazySingleton<TransactionGetTransactions>(
      () => TransactionGetTransactions(
        transactionRepository: serviceLocator(),
      ),
    )

    // Bloc
    ..registerFactory(
      () => TransactionBloc(
        serviceGetTransactions: serviceLocator(),
      ),
    );

  // Auth Listener
  await serviceLocator<AuthService>().initializeAuthListener();
}
