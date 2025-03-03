import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/textstyle/app_textstyle.dart';
import '../../../../core/utils/show_snackbar.dart';
import '../../../../core/widgets/widget_loading.dart';
import '../../../../src/generated/i18n/app_localizations.dart';
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

  @override
  Widget build(BuildContext context) {
    final appText = AppLocalizations.of(context)!;

    return BlocListener<UserRoleBloc, UserRoleState>(
      listener: (context, state) {
        if (state is UserRoleFailure) {
          showSnackbar(context, state.message.toString());
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            appText.user_role_screen_title,
            style: AppTextstyle.title,
          ),
        ),
        body: SafeArea(
          child: BlocBuilder<UserRoleBloc, UserRoleState>(
            builder: (context, state) {
              if (state is UserRoleLoading) {
                return WidgetLoading(usingPadding: true);
              } else if (state is UserRoleSuccessGetProfiles) {
                List<Profile> profiles = state.profiles;

                if (profiles.isEmpty) {
                  return Center(
                    child: Text(
                      appText.user_role_empty_message,
                      style: AppTextstyle.body,
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: profiles.length,
                  itemBuilder: (context, index) {
                    Profile profile = profiles[index];
                    bool isUser = profile.role == 'user';

                    return ListTile(
                      contentPadding: const EdgeInsets.only(
                        left: 16.0,
                        right: 8,
                      ),
                      title: Text(profile.name),
                      subtitle: Text(profile.email),
                      trailing: IconButton(
                        icon: Icon(
                          isUser ? Icons.check_circle : Icons.remove_circle,
                          color: isUser ? Colors.green : Colors.red,
                        ),
                        onPressed: () {
                          if (isUser) {
                            deactivateUser(
                              context: context,
                              profile: profile,
                              index: index,
                              appText: appText,
                            );
                          } else {
                            activateUser(
                              context: context,
                              profile: profile,
                              index: index,
                              appText: appText,
                            );
                          }
                        },
                      ),
                    );
                  },
                );
              } else {
                return Center(
                  child: Text(
                    appText.error_occurred_message,
                    style: AppTextstyle.body,
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
