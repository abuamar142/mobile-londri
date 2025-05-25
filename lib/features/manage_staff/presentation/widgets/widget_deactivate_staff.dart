import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/show_confirmation_dialog.dart';
import '../../../../src/generated/i18n/app_localizations.dart';
import '../../domain/entities/user.dart';
import '../bloc/manage_staff_bloc.dart';

Future<void> deactivateStaff({
  required BuildContext context,
  required User user,
}) async {
  showConfirmationDialog(
    context: context,
    title: AppLocalizations.of(context)!.manage_staff_deactivate_staff,
    content: AppLocalizations.of(context)!.manage_staff_deactivate_dialog_confirm_message(user.name),
    onConfirm: () {
      context.read<ManageStaffBloc>().add(
            ManageStaffEventDeactivateStaff(
              user: user,
            ),
          );

      context.pop();
    },
  );
}
