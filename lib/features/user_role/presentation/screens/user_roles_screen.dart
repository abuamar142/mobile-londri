import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/textstyle/app_textstyle.dart';
import '../../../../core/utils/show_snackbar.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../domain/entities/profile.dart';
import '../bloc/user_role_bloc.dart';
import '../widgets/widget_activate_user.dart';
import '../widgets/widget_deactivate_user.dart';

class UserRolesScreen extends StatefulWidget {
  const UserRolesScreen({super.key});

  @override
  State<UserRolesScreen> createState() => _UserRolesScreenState();
}

class _UserRolesScreenState extends State<UserRolesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<UserRoleBloc>().add(
          UserRoleEventGetProfiles(),
        );
  }

  Future<void> _refresh() async {
    context.read<UserRoleBloc>().add(
          UserRoleEventGetProfiles(),
        );
    showSnackbar(context, 'Data refreshed');
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserRoleBloc, UserRoleState>(
      listener: (context, state) {
        if (state is UserRoleFailure) {
          showSnackbar(context, state.message.toString());
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'User Roles',
            style: AppTextstyle.title,
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                _refresh();
              },
            ),
          ],
        ),
        body: SafeArea(
          child: BlocBuilder<UserRoleBloc, UserRoleState>(
            builder: (context, state) {
              if (state is UserRoleLoading) {
                return LoadingWidget(usingPadding: true);
              } else if (state is UserRoleSuccessGetProfiles) {
                List<Profile> profiles = state.profiles;

                if (profiles.isEmpty) {
                  return Center(
                    child: Text('No profiles found'),
                  );
                }

                return ListView.builder(
                  itemCount: profiles.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(profiles[index].name),
                      subtitle: Text(profiles[index].email),
                      trailing: IconButton(
                        icon: Icon(
                          profiles[index].role == 'user'
                              ? Icons.check_circle
                              : Icons.remove_circle,
                          color: profiles[index].role == 'user'
                              ? Colors.green
                              : Colors.red,
                        ),
                        onPressed: () {
                          if (profiles[index].role == 'user') {
                            deactivateUser(
                              context: context,
                              profile: profiles[index],
                              index: index,
                            );
                          } else {
                            activateUser(
                              context: context,
                              profile: profiles[index],
                              index: index,
                            );
                          }
                        },
                      ),
                    );
                  },
                );
              } else {
                return Center(
                  child: Text('An error occurred'),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
