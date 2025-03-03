import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/show_confirmation_dialog.dart';
import '../../../../src/generated/i18n/app_localizations.dart';
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
    onConfirm: () {
      context.read<UserRoleBloc>().add(
            UserRoleEventDeactivateUser(
              userId: profile.id,
            ),
          );

      context.pop();
    },
  );
}
