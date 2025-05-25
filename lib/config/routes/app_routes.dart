import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/customer/presentation/screens/customers_screen.dart';
import '../../features/customer/presentation/screens/manage_customer_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/home/presentation/screens/splash_screen.dart';
import '../../features/manage_staff/presentation/screens/manage_staff_screen.dart';
import '../../features/printer/presentation/screens/print_transaction_invoice_screen.dart';
import '../../features/printer/presentation/screens/printer_settings_screen.dart';
import '../../features/service/presentation/screens/manage_service_screen.dart';
import '../../features/service/presentation/screens/services_screen.dart';
import '../../features/transaction/presentation/screens/manage_transaction_screen.dart';
import '../../features/transaction/presentation/screens/track_transaction_screen.dart';
import '../../features/transaction/presentation/screens/transaction_detail_screen.dart';
import '../../features/transaction/presentation/screens/transactions_screen.dart';

class RouteNames {
  RouteNames._();

  static const String splash = 'splash';
  static const String login = 'login';
  static const String register = 'register';
  static const String home = 'home';
  static const String manageStaff = 'manage-staff';
  static const String services = 'services';
  static const String addService = 'add-service';
  static const String viewService = 'view-service';
  static const String editService = 'edit-service';
  static const String customers = 'customers';
  static const String addCustomer = 'add-customer';
  static const String viewCustomer = 'view-customer';
  static const String editCustomer = 'edit-customer';
  static const String transactions = 'transactions';
  static const String addTransaction = 'add-transaction';
  static const String viewTransaction = 'view-transaction';
  static const String editTransaction = 'edit-transaction';
  static const String printTransaction = 'print-transaction';
  static const String trackTransactions = 'track-transactions';
  static const String printerSettings = 'printer-settings';
}

class AppRoutes {
  AppRoutes._();

  static GoRouter routes = GoRouter(
    debugLogDiagnostics: true,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: RouteNames.login,
        builder: (context, state) {
          return LoginScreen();
        },
      ),
      GoRoute(
        path: '/register',
        name: RouteNames.register,
        builder: (context, state) {
          return const RegisterScreen();
        },
      ),
      GoRoute(
        path: '/home',
        name: RouteNames.home,
        builder: (context, state) {
          return const HomeScreen();
        },
      ),
      GoRoute(
        path: '/manage-staff',
        name: RouteNames.manageStaff,
        builder: (context, state) {
          return const ManageStaffScreen();
        },
      ),
      GoRoute(
        path: '/services',
        name: RouteNames.services,
        builder: (context, state) => const ServicesScreen(),
        routes: [
          GoRoute(
            path: 'add',
            name: RouteNames.addService,
            builder: (context, state) => const ManageServiceScreen(
              mode: ManageServiceMode.add,
            ),
          ),
          GoRoute(
            path: ':id/view',
            name: RouteNames.viewService,
            builder: (context, state) => ManageServiceScreen(
              mode: ManageServiceMode.view,
              serviceId: state.pathParameters['id'],
            ),
          ),
          GoRoute(
            path: ':id/edit',
            name: RouteNames.editService,
            builder: (context, state) => ManageServiceScreen(
              mode: ManageServiceMode.edit,
              serviceId: state.pathParameters['id'],
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/customers',
        name: RouteNames.customers,
        builder: (context, state) => const CustomersScreen(),
        routes: [
          GoRoute(
            path: 'add',
            name: RouteNames.addCustomer,
            builder: (context, state) => const ManageCustomerScreen(
              mode: ManageCustomerMode.add,
            ),
          ),
          GoRoute(
            path: ':id/view',
            name: RouteNames.viewCustomer,
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return ManageCustomerScreen(
                mode: ManageCustomerMode.view,
                customerId: id,
              );
            },
          ),
          GoRoute(
            path: ':id/edit',
            name: RouteNames.editCustomer,
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return ManageCustomerScreen(
                mode: ManageCustomerMode.edit,
                customerId: id,
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/transactions',
        name: RouteNames.transactions,
        builder: (context, state) => const TransactionsScreen(),
        routes: [
          GoRoute(
            path: 'add',
            name: RouteNames.addTransaction,
            builder: (context, state) => const ManageTransactionScreen(
              mode: ManageTransactionMode.add,
            ),
          ),
          GoRoute(
            path: ':id/view',
            name: RouteNames.viewTransaction,
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return TransactionDetailScreen(transactionId: id);
            },
          ),
          GoRoute(
            path: ':id/edit',
            name: RouteNames.editTransaction,
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return ManageTransactionScreen(
                mode: ManageTransactionMode.edit,
                transactionId: id,
              );
            },
          ),
          GoRoute(
            path: ':id/print',
            name: RouteNames.printTransaction,
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return PrintTransactionInvoiceScreen(transactionId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/track-transactions',
        name: RouteNames.trackTransactions,
        builder: (context, state) {
          return const TrackTransactionsScreen();
        },
      ),
      GoRoute(
        path: '/printer-settings',
        name: RouteNames.printerSettings,
        builder: (context, state) {
          return const PrinterSettingsScreen();
        },
      ),
    ],
  );
}
