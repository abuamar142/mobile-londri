import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest.dart' as timezone;
import 'package:timezone/timezone.dart' as timezone;

import 'app_observer.dart';
import 'config/i18n/i18n.dart';
import 'core/services/auth_service.dart';
import 'core/utils/get_timezone.dart';
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
import 'features/manage_employee/data/datasources/manage_employee_remote_datasource.dart';
import 'features/manage_employee/data/repositories/manage_employee_repository_implementation.dart';
import 'features/manage_employee/domain/repositories/manage_employee_repository.dart';
import 'features/manage_employee/domain/usecases/manage_employee_activate_employee.dart';
import 'features/manage_employee/domain/usecases/manage_employee_deactivate_employee.dart';
import 'features/manage_employee/domain/usecases/manage_employee_get_users.dart';
import 'features/manage_employee/presentation/bloc/manage_employee_bloc.dart';
import 'features/service/data/datasources/service_remote_datasource.dart';
import 'features/service/data/repositories/service_repository_implementation.dart';
import 'features/service/domain/repositories/service_repository.dart';
import 'features/service/domain/usecases/service_create_service.dart';
import 'features/service/domain/usecases/service_delete_service.dart';
import 'features/service/domain/usecases/service_get_service_by_id.dart';
import 'features/service/domain/usecases/service_get_services.dart';
import 'features/service/domain/usecases/service_update_service.dart';
import 'features/service/presentation/bloc/service_bloc.dart';
import 'features/transaction/data/datasources/transaction_local_datasource.dart';
import 'features/transaction/data/datasources/transaction_remote_datasource.dart';
import 'features/transaction/data/repositories/transaction_repository_implementation.dart';
import 'features/transaction/domain/repositories/transaction_repository.dart';
import 'features/transaction/domain/usecases/transaction_create_transaction.dart';
import 'features/transaction/domain/usecases/transaction_get_default_transaction_status.dart';
import 'features/transaction/domain/usecases/transaction_get_transactions.dart';
import 'features/transaction/domain/usecases/transaction_update_default_transaction_status.dart';
import 'features/transaction/presentation/bloc/transaction_bloc.dart';

final serviceLocator = GetIt.instance;

Future<void> initializeDependencies() async {
  // Flutter Dotenv
  await dotenv.load(fileName: ".env");

  // Timezone
  timezone.initializeTimeZones();
  timezone.setLocalLocation(
    timezone.getLocation(
      await AppTimezone.getCurrentTimezone(),
    ),
  );

  // Bloc Observer
  Bloc.observer = AppObserver();

  // SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  serviceLocator.registerLazySingleton<SharedPreferences>(
    () => sharedPreferences,
  );

  // Localization
  serviceLocator.registerLazySingleton<AppLocales>(
    () => AppLocales(
      sharedPreferences: serviceLocator(),
    ),
  );
  serviceLocator<AppLocales>().loadLocale();

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
    ..registerLazySingleton<ManageEmployeeRemoteDatasource>(
      () => ManageEmployeeRemoteDataSourceImplementation(
        supabaseClient: serviceLocator(),
      ),
    )

    // Repositories
    ..registerLazySingleton<ManageEmployeeRepository>(
      () => ManageEmployeeRepositoryImplementation(
        manageEmployeeRemoteDatasource: serviceLocator(),
      ),
    )

    // UseCases
    ..registerLazySingleton<ManageEmployeeGetUsers>(
      () => ManageEmployeeGetUsers(
        manageEmployeeRepository: serviceLocator(),
      ),
    )
    ..registerLazySingleton<ManageEmployeeActivateEmployee>(
      () => ManageEmployeeActivateEmployee(
        manageEmployeeRepository: serviceLocator(),
      ),
    )
    ..registerLazySingleton<ManageEmployeeDeactivateEmployee>(
      () => ManageEmployeeDeactivateEmployee(
        manageEmployeeRepository: serviceLocator(),
      ),
    )

    // Bloc
    ..registerFactory<ManageEmployeeBloc>(
      () => ManageEmployeeBloc(
        manageEmployeeGetUsers: serviceLocator(),
        manageEmployeeActivateEmployee: serviceLocator(),
        manageEmployeeDeactivateEmployee: serviceLocator(),
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
    ..registerLazySingleton<TransactionLocalDatasource>(
      () => TransactionLocalDatasourceImplementation(
        sharedPreferences: serviceLocator(),
      ),
    )

    // Repositories
    ..registerLazySingleton<TransactionRepository>(
      () => TransactionRepositoryImplementation(
        transactionRemoteDatasource: serviceLocator(),
        transactionLocalDatasource: serviceLocator(),
      ),
    )

    // UseCases
    ..registerLazySingleton<TransactionGetTransactions>(
      () => TransactionGetTransactions(
        transactionRepository: serviceLocator(),
      ),
    )
    ..registerLazySingleton<TransactionGetDefaultTransactionStatus>(
      () => TransactionGetDefaultTransactionStatus(
        transactionRepository: serviceLocator(),
      ),
    )
    ..registerLazySingleton<TransactionCreateTransaction>(
      () => TransactionCreateTransaction(
        transactionRepository: serviceLocator(),
      ),
    )
    ..registerLazySingleton<TransactionUpdateDefaultTransactionStatus>(
      () => TransactionUpdateDefaultTransactionStatus(
        transactionRepository: serviceLocator(),
      ),
    )

    // Bloc
    ..registerFactory(
      () => TransactionBloc(
        transactionGetTransactions: serviceLocator(),
        transactionGetDefaultTransactionStatus: serviceLocator(),
        transactionCreateTransaction: serviceLocator(),
        transactionUpdateDefaultTransactionStatus: serviceLocator(),
      ),
    );

  // Auth Listener
  await serviceLocator<AuthService>().initializeAuthListener();
}
