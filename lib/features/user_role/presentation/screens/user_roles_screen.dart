import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/show_snackbar.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../injection_container.dart';
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
        } else if (state is UserRoleSuccessActivateUser) {
          showSnackbar(context, 'User activated');
        } else if (state is UserRoleSuccessDeactivateUser) {
          showSnackbar(context, 'User deactivated');
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
                subtitle: Text(state.profiles[index].email),
                trailing: IconButton(
                  icon: Icon(
                    state.profiles[index].role == 'user'
                        ? Icons.check_circle
                        : Icons.remove_circle,
                    color: state.profiles[index].role == 'user'
                        ? Colors.green
                        : Colors.red,
                  ),
                  onPressed: () {
                    if (state.profiles[index].role == 'user') {
                      deactivateUser(
                        context: context,
                        state: state,
                        index: index,
                      );
                    } else {
                      activateUser(
                        context: context,
                        state: state,
                        index: index,
                      );
                    }
                  },
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

Future<void> activateUser({
  required BuildContext context,
  required UserRoleSuccessGetProfiles state,
  required int index,
}) async {
  showConfirmationDialog(
    context: context,
    title: "Activate User",
    content:
        "Are you sure to activate this user: '${state.profiles[index].name}'?",
    isLoading: serviceLocator<UserRoleBloc>().state is UserRoleLoading,
    onConfirm: () {
      serviceLocator<UserRoleBloc>().add(
        UserRoleEventActivateUser(
          userId: state.profiles[index].id,
          role: 'user',
        ),
      );
      context.pushReplacementNamed('home');
    },
  );
}

Future<void> deactivateUser({
  required BuildContext context,
  required UserRoleSuccessGetProfiles state,
  required int index,
}) async {
  showConfirmationDialog(
    context: context,
    title: "Deactivate User",
    content:
        "Are you sure to deactivate this user: '${state.profiles[index].name}'?",
    isLoading: serviceLocator<UserRoleBloc>().state is UserRoleLoading,
    onConfirm: () {
      serviceLocator<UserRoleBloc>().add(
        UserRoleEventDeactivateUser(
          userId: state.profiles[index].id,
        ),
      );
      context.pushReplacementNamed('home');
    },
  );
}
