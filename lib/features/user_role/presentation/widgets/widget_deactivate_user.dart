import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/show_confirmation_dialog.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/profile.dart';
import '../bloc/user_role_bloc.dart';

Future<void> deactivateUser({
  required BuildContext context,
  required Profile profile,
  required int index,
  required AppLocalizations appText,
}) async {
  showConfirmationDialog(
    context: context,
    appText: appText,
    title: "Deactivate User",
    content: "Are you sure to deactivate this user: '${profile.name}'?",
    isLoading: serviceLocator<UserRoleBloc>().state is UserRoleLoading,
    onConfirm: () {
      serviceLocator<UserRoleBloc>().add(
        UserRoleEventDeactivateUser(
          userId: profile.id,
        ),
      );
      context.pushReplacementNamed('user-roles');
    },
  );
}
