import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/show_snackbar.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../bloc/user_role_bloc.dart';

class UserRolesScreen extends StatefulWidget {
  const UserRolesScreen({super.key});

  @override
  State<UserRolesScreen> createState() => _UserRolesScreenState();
}

class _UserRolesScreenState extends State<UserRolesScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserRoleBloc, UserRoleState>(
      bloc: BlocProvider.of(context)
        ..add(
          UserRoleEventGetProfiles(),
        ),
      listener: (context, state) {
        if (state is UserRoleFailure) {
          showSnackbar(context, state.message.toString());
        }
      },
      builder: (context, state) {
        if (state is UserRoleLoading) {
          return const LoadingWidget(
            usingPadding: true,
          );
        } else if (state is UserRoleSuccessGetProfiles) {
          return ListView.builder(
            itemCount: state.profiles.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(state.profiles[index].name),
                subtitle: Text('Role: ${state.profiles[index].email}'),
                trailing: IconButton(
                  icon: Icon(
                    state.profiles[index].role == 'user'
                        ? Icons.check_circle
                        : Icons.remove_circle,
                  ),
                  onPressed: () {},
                ),
              );
            },
          );
        } else {
          return const Center(
            child: Text('No data'),
          );
        }
      },
    );
  }
}
