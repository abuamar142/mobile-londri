import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/customer/presentation/screens/customers_screen.dart';
import '../../features/customer/presentation/screens/manage_customer_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/home/presentation/screens/splash_screen.dart';
import '../../features/manage_employee/presentation/screens/manage_employee_screen.dart';
import '../../features/service/presentation/screens/manage_service_screen.dart';
import '../../features/service/presentation/screens/services_screen.dart';
import '../../features/transaction/presentation/screens/manage_transaction_screen.dart';
import '../../features/transaction/presentation/screens/print_transaction_note_screen.dart';
import '../../features/transaction/presentation/screens/track_transaction_screen.dart';
import '../../features/transaction/presentation/screens/transactions_screen.dart';

class AppRoutes {
  AppRoutes._();

  static GoRouter routes = GoRouter(
    debugLogDiagnostics: true,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) {
          return LoginScreen();
        },
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) {
          return const RegisterScreen();
        },
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) {
          return const HomeScreen();
        },
      ),
      GoRoute(
        path: '/services',
        name: 'services',
        builder: (context, state) {
          return const ServicesScreen();
        },
      ),
      GoRoute(
        path: '/manage-employee',
        name: 'manage-employee',
        builder: (context, state) {
          return const ManageEmployeeScreen();
        },
      ),
      GoRoute(
        path: '/customers',
        name: 'customers',
        builder: (context, state) {
          return const CustomersScreen();
        },
        routes: [
          GoRoute(
            path: 'add',
            name: 'add-customer',
            builder: (context, state) {
              return const ManageCustomerScreen(mode: ManageCustomerMode.add);
            },
          ),
          GoRoute(
            path: 'view/:id',
            name: 'view-customer',
            builder: (context, state) {
              final customerId = state.pathParameters['id']!;
              return ManageCustomerScreen(
                mode: ManageCustomerMode.view,
                customerId: customerId,
              );
            },
          ),
          GoRoute(
            path: 'edit/:id',
            name: 'edit-customer',
            builder: (context, state) {
              final customerId = state.pathParameters['id']!;
              return ManageCustomerScreen(
                mode: ManageCustomerMode.edit,
                customerId: customerId,
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/transactions',
        name: 'transactions',
        builder: (context, state) {
          return const TransactionsScreen();
        },
        routes: [
          GoRoute(
            path: 'add',
            name: 'add-transaction',
            builder: (context, state) {
              return const ManageTransactionScreen(
                  mode: ManageTransactionMode.add);
            },
          ),
          GoRoute(
            path: 'view/:id',
            name: 'view-transaction',
            builder: (context, state) {
              final transactionId = state.pathParameters['id']!;
              return ManageTransactionScreen(
                mode: ManageTransactionMode.view,
                transactionId: transactionId,
              );
            },
          ),
          GoRoute(
            path: 'edit/:id',
            name: 'edit-transaction',
            builder: (context, state) {
              final transactionId = state.pathParameters['id']!;
              return ManageTransactionScreen(
                mode: ManageTransactionMode.edit,
                transactionId: transactionId,
              );
            },
          ),
          GoRoute(
            path: 'print/:id',
            name: 'print-transaction',
            builder: (context, state) {
              final transactionId = state.pathParameters['id']!;
              return PrintTransactionNoteScreen(
                transactionId: transactionId,
              );
            },
          )
        ],
      ),
      GoRoute(
        path: '/track-transactions',
        name: 'track-transactions',
        builder: (context, state) {
          return const TrackTransactionsScreen();
        },
      ),
      GoRoute(
        path: '/services/add',
        name: 'add-service',
        builder: (context, state) => const ManageServiceScreen(
          mode: ManageServiceMode.add,
        ),
      ),
      GoRoute(
        path: '/services/:id',
        name: 'view-service',
        builder: (context, state) => ManageServiceScreen(
          mode: ManageServiceMode.view,
          serviceId: state.pathParameters['id'],
        ),
      ),
      GoRoute(
        path: '/services/:id/edit',
        name: 'edit-service',
        builder: (context, state) => ManageServiceScreen(
          mode: ManageServiceMode.edit,
          serviceId: state.pathParameters['id'],
        ),
      ),
    ],
  );
}
