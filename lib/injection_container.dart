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
import 'core/services/permission_service.dart';
import 'core/services/printer_service.dart';
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
import 'features/customer/domain/usecases/customer_get_active_customers.dart';
import 'features/customer/domain/usecases/customer_get_customer_by_id.dart';
import 'features/customer/domain/usecases/customer_get_customers.dart';
import 'features/customer/domain/usecases/customer_update_customer.dart';
import 'features/customer/presentation/bloc/customer_bloc.dart';
import 'features/manage_staff/data/datasources/manage_staff_remote_datasource.dart';
import 'features/manage_staff/data/repositories/manage_staff_repository_implementation.dart';
import 'features/manage_staff/domain/repositories/manage_staff_repository.dart';
import 'features/manage_staff/domain/usecases/manage_staff_activate_staff.dart';
import 'features/manage_staff/domain/usecases/manage_staff_deactivate_staff.dart';
import 'features/manage_staff/domain/usecases/manage_staff_get_users.dart';
import 'features/manage_staff/presentation/bloc/manage_staff_bloc.dart';
import 'features/service/data/datasources/service_remote_datasource.dart';
import 'features/service/data/repositories/service_repository_implementation.dart';
import 'features/service/domain/repositories/service_repository.dart';
import 'features/service/domain/usecases/service_activate_service.dart';
import 'features/service/domain/usecases/service_create_service.dart';
import 'features/service/domain/usecases/service_delete_service.dart';
import 'features/service/domain/usecases/service_get_active_services.dart';
import 'features/service/domain/usecases/service_get_service_by_id.dart';
import 'features/service/domain/usecases/service_get_services.dart';
import 'features/service/domain/usecases/service_update_service.dart';
import 'features/service/presentation/bloc/service_bloc.dart';
import 'features/transaction/data/datasources/transaction_remote_datasource.dart';
import 'features/transaction/data/repositories/transaction_repository_implementation.dart';
import 'features/transaction/domain/repositories/transaction_repository.dart';
import 'features/transaction/domain/usecases/transaction_create_transaction.dart';
import 'features/transaction/domain/usecases/transaction_delete_transaction.dart';
import 'features/transaction/domain/usecases/transaction_get_transaction_by_id.dart';
import 'features/transaction/domain/usecases/transaction_get_transactions.dart';
import 'features/transaction/domain/usecases/transaction_hard_delete_transaction.dart';
import 'features/transaction/domain/usecases/transaction_restore_transaction.dart';
import 'features/transaction/domain/usecases/transaction_update_transaction.dart';
import 'features/transaction/presentation/bloc/transaction_bloc.dart';

final serviceLocator = GetIt.instance;

Future<void> initializeDependencies() async {
  // Flutter Dotenv
  await dotenv.load(fileName: ".env");

  // Timezone
  timezone.initializeTimeZones();
  timezone.setLocalLocation(
    timezone.getLocation(await AppTimezone.getCurrentTimezone()),
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
    () => AppLocales(sharedPreferences: serviceLocator()),
  );
  serviceLocator<AppLocales>().loadLocale();

  // Feature - Auth
  // Supabase
  serviceLocator
    ..registerLazySingleton<SupabaseClient>(
      () => SupabaseClient(
        dotenv.env['SUPABASE_URL']!,
        dotenv.env['SUPABASE_KEY']!,
        authOptions: const AuthClientOptions(authFlowType: AuthFlowType.implicit),
      ),
    )

    // Auth Service
    ..registerLazySingleton<AuthService>(
      () => AuthService(supabaseClient: serviceLocator()),
    )

    // DataSources
    ..registerLazySingleton<AuthRemoteDatasource>(
      () => AuthRemoteDatasourceImplementation(supabaseClient: serviceLocator()),
    )

    // Repositories
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImplementation(authRemoteDatasource: serviceLocator()),
    )

    // UseCases
    ..registerLazySingleton<AuthLogin>(
      () => AuthLogin(authRepository: serviceLocator()),
    )
    ..registerLazySingleton<AuthRegister>(
      () => AuthRegister(authRepository: serviceLocator()),
    )
    ..registerLazySingleton<AuthLogout>(
      () => AuthLogout(authRepository: serviceLocator()),
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
    ..registerLazySingleton<ManageStaffRemoteDatasource>(
      () => ManageStaffRemoteDataSourceImplementation(supabaseClient: serviceLocator()),
    )

    // Repositories
    ..registerLazySingleton<ManageStaffRepository>(
      () => ManageStaffRepositoryImplementation(manageStaffRemoteDatasource: serviceLocator()),
    )

    // UseCases
    ..registerLazySingleton<ManageStaffGetUsers>(
      () => ManageStaffGetUsers(manageStaffRepository: serviceLocator()),
    )
    ..registerLazySingleton<ManageStaffActivateStaff>(
      () => ManageStaffActivateStaff(manageStaffRepository: serviceLocator()),
    )
    ..registerLazySingleton<ManageStaffDeactivateStaff>(
      () => ManageStaffDeactivateStaff(manageStaffRepository: serviceLocator()),
    )

    // Bloc
    ..registerFactory<ManageStaffBloc>(
      () => ManageStaffBloc(
        manageStaffGetUsers: serviceLocator(),
        manageStaffActivateStaff: serviceLocator(),
        manageStaffDeactivateStaff: serviceLocator(),
      ),
    )

    // Feature - Service
    // DataSources
    ..registerLazySingleton<ServiceRemoteDatasource>(
      () => ServiceRemoteDatasourceImplementation(supabaseClient: serviceLocator()),
    )

    // Repositories
    ..registerLazySingleton<ServiceRepository>(
      () => ServiceRepositoryImplementation(serviceRemoteDatasource: serviceLocator()),
    )

    // UseCases
    ..registerLazySingleton<ServiceGetServices>(
      () => ServiceGetServices(serviceRepository: serviceLocator()),
    )
    ..registerLazySingleton<ServiceGetActiveServices>(
      () => ServiceGetActiveServices(serviceRepository: serviceLocator()),
    )
    ..registerLazySingleton<ServiceGetServiceById>(
      () => ServiceGetServiceById(serviceRepository: serviceLocator()),
    )
    ..registerLazySingleton<ServiceCreateService>(
      () => ServiceCreateService(serviceRepository: serviceLocator()),
    )
    ..registerLazySingleton<ServiceUpdateService>(
      () => ServiceUpdateService(serviceRepository: serviceLocator()),
    )
    ..registerLazySingleton<ServiceDeleteService>(
      () => ServiceDeleteService(serviceRepository: serviceLocator()),
    )
    ..registerLazySingleton<ServiceActivateService>(
      () => ServiceActivateService(serviceRepository: serviceLocator()),
    )

    // Bloc
    ..registerFactory(
      () => ServiceBloc(
        serviceGetServices: serviceLocator(),
        serviceGetActiveServices: serviceLocator(),
        serviceGetServiceById: serviceLocator(),
        serviceCreateService: serviceLocator(),
        serviceUpdateService: serviceLocator(),
        serviceDeleteService: serviceLocator(),
        serviceActivateService: serviceLocator(),
      ),
    )

    // Feature - Customer
    // DataSources
    ..registerLazySingleton<CustomerRemoteDatasource>(
      () => CustomerRemoteDatasourceImplementation(supabaseClient: serviceLocator()),
    )

    // Repositories
    ..registerLazySingleton<CustomerRepository>(
      () => CustomerRepositoryImplementation(customerRemoteDatasource: serviceLocator()),
    )

    // UseCases
    ..registerLazySingleton<CustomerGetCustomers>(
      () => CustomerGetCustomers(customerRepository: serviceLocator()),
    )
    ..registerLazySingleton<CustomerGetActiveCustomers>(
      () => CustomerGetActiveCustomers(customerRepository: serviceLocator()),
    )
    ..registerLazySingleton<CustomerGetCustomerById>(
      () => CustomerGetCustomerById(customerRepository: serviceLocator()),
    )
    ..registerLazySingleton<CustomerCreateCustomer>(
      () => CustomerCreateCustomer(customerRepository: serviceLocator()),
    )
    ..registerLazySingleton<CustomerUpdateCustomer>(
      () => CustomerUpdateCustomer(customerRepository: serviceLocator()),
    )
    ..registerLazySingleton<CustomerDeleteCustomer>(
      () => CustomerDeleteCustomer(customerRepository: serviceLocator()),
    )
    ..registerLazySingleton<CustomerActivateCustomer>(
      () => CustomerActivateCustomer(customerRepository: serviceLocator()),
    )

    // Bloc
    ..registerFactory(
      () => CustomerBloc(
        customerGetCustomers: serviceLocator(),
        customerGetActiveCustomers: serviceLocator(),
        customerGetCustomerById: serviceLocator(),
        customerCreateCustomer: serviceLocator(),
        customerUpdateCustomer: serviceLocator(),
        customerDeleteCustomer: serviceLocator(),
        customerActivateCustomer: serviceLocator(),
      ),
    )

    // Feature - Transaction
    // Permission Service
    ..registerLazySingleton<PermissionService>(
      () => PermissionService(),
    )

    // Printer Service
    ..registerLazySingleton<PrinterService>(
      () => PrinterService(),
    )
    // DataSources
    ..registerLazySingleton<TransactionRemoteDatasource>(
      () => TransactionRemoteDatasourceImplementation(supabaseClient: serviceLocator()),
    )

    // Repositories
    ..registerLazySingleton<TransactionRepository>(
      () => TransactionRepositoryImplementation(transactionRemoteDatasource: serviceLocator()),
    )

    // UseCases
    ..registerLazySingleton<TransactionGetTransactions>(
      () => TransactionGetTransactions(transactionRepository: serviceLocator()),
    )
    ..registerLazySingleton<TransactionGetTransactionById>(
      () => TransactionGetTransactionById(transactionRepository: serviceLocator()),
    )
    ..registerLazySingleton<TransactionCreateTransaction>(
      () => TransactionCreateTransaction(transactionRepository: serviceLocator()),
    )
    ..registerLazySingleton<TransactionUpdateTransaction>(
      () => TransactionUpdateTransaction(transactionRepository: serviceLocator()),
    )
    ..registerLazySingleton<TransactionRestoreTransaction>(
      () => TransactionRestoreTransaction(transactionRepository: serviceLocator()),
    )
    ..registerLazySingleton<TransactionDeleteTransaction>(
      () => TransactionDeleteTransaction(transactionRepository: serviceLocator()),
    )
    ..registerLazySingleton<TransactionHardDeleteTransaction>(
      () => TransactionHardDeleteTransaction(transactionRepository: serviceLocator()),
    )

    // Bloc
    ..registerFactory(
      () => TransactionBloc(
        transactionGetTransactions: serviceLocator(),
        transactionGetTransactionById: serviceLocator(),
        transactionCreateTransaction: serviceLocator(),
        transactionUpdateTransaction: serviceLocator(),
        transactionDeleteTransaction: serviceLocator(),
        transactionHardDeleteTransaction: serviceLocator(),
        transactionRestoreTransaction: serviceLocator(),
      ),
    );

  // Auth Listener
  await serviceLocator<AuthService>().initializeAuthListener();
}
