import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/textstyle/app_textstyle.dart';
import '../../../../core/utils/show_snackbar.dart';
import '../../../../core/widgets/widget_button.dart';
import '../../../../core/widgets/widget_loading.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

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
              return WidgetLoading(usingPadding: true);
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
        title: Text(
          'Home',
          style: AppTextstyle.title,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                WidgetButton(
                  label: 'User Roles',
                  onPressed: () => context.pushNamed('user-roles'),
                ),
                const SizedBox(height: 16),
                WidgetButton(
                  label: 'Services',
                  onPressed: () => context.pushNamed('services'),
                ),
                const SizedBox(height: 16),
                WidgetButton(
                  label: 'Customers',
                  onPressed: () => context.pushNamed('customers'),
                ),
                const SizedBox(height: 16),
                WidgetButton(
                  label: 'Transactions',
                  onPressed: () => context.pushNamed('transactions'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
