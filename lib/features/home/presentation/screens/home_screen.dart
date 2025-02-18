import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/show_snackbar.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../user_role/presentation/bloc/user_role_bloc.dart';
import '../../../user_role/presentation/screens/user_roles_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _logout() {
    context.read<AuthBloc>().add(
          AuthEventLogout(),
        );
  }

  void _refresh() {
    context.read<UserRoleBloc>().add(
          UserRoleEventGetProfiles(),
        );
    showSnackbar(context, 'Data refreshed');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthStateFailure) {
              showSnackbar(context, state.message.toString());
            } else if (state is AuthStateSuccessLogout) {
              showSnackbar(context, 'Logout successful');
              context.pushReplacementNamed('splash');
            }
          },
          builder: (context, state) {
            if (state is AuthStateLoading) {
              return LoadingWidget(usingPadding: true);
            } else {
              return IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  _logout();
                },
              );
            }
          },
        ),
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _refresh();
            },
          ),
        ],
      ),
      body: BlocConsumer<UserRoleBloc, UserRoleState>(
        listener: (context, state) {
          if (state is UserRoleFailure) {
            showSnackbar(context, state.message.toString());
          } else if (state is UserRoleSuccessActivateUser) {
            showSnackbar(context, 'User activated');
            _refresh();
          } else if (state is UserRoleSuccessDeactivateUser) {
            showSnackbar(context, 'User deactivated');
            _refresh();
          }
        },
        builder: (context, state) {
          if (state is UserRoleLoading) {
            return const LoadingWidget(usingPadding: true);
          } else if (state is UserRoleSuccessGetProfiles) {
            return UserRolesScreen(profiles: state.profiles);
          } else {
            return const Center(child: Text('No data'));
          }
        },
      ),
    );
  }
}
