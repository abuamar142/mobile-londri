import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/customer/presentation/screens/customers_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/service/presentation/screens/services_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/user_role/presentation/screens/user_roles_screen.dart';

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
        path: '/user-roles',
        name: 'user-roles',
        builder: (context, state) {
          return const UserRolesScreen();
        },
      ),
      GoRoute(
        path: '/customers',
        name: 'customers',
        builder: (context, state) {
          return const CustomersScreen();
        },
      ),
    ],
  );
}
