import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/widgets/widget_loading.dart';
import '../bloc/auth_bloc.dart';

class AuthWrapper extends StatelessWidget {
  final Widget child;

  const AuthWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthStateSuccessLogin) {
          context.go(RouteNames.home);
        } else if (state is AuthStateSuccessLogout) {
          context.go(RouteNames.login);
        } else if (state is AuthStateInitial) {
          final currentLocation = GoRouterState.of(context).uri.toString();
          if (currentLocation == '/') {
            context.go(RouteNames.splash);
          }
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthStateLoading) {
            return const Scaffold(
              body: WidgetLoading(
                usingPadding: true,
              ),
            );
          }

          return child;
        },
      ),
    );
  }
}
