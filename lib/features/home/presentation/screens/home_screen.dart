import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/textstyle/app_textstyle.dart';
import '../../../../core/utils/show_snackbar.dart';
import '../../../../core/widgets/loading_widget.dart';
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
        title: Text(
          'Home',
          style: AppTextstyle.title,
        ),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            context.pushNamed('user-roles');
          },
          child: const Text('User Roles'),
        ),
      ),
    );
  }
}
