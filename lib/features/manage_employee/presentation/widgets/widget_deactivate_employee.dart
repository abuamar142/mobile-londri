import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/show_confirmation_dialog.dart';
import '../../../../src/generated/i18n/app_localizations.dart';
import '../../domain/entities/user.dart';
import '../bloc/manage_employee_bloc.dart';

Future<void> deactivateEmployee({
  required BuildContext context,
  required User user,
}) async {
  showConfirmationDialog(
    context: context,
    title: AppLocalizations.of(context)!.manage_employee_deactivate_employee,
    content: AppLocalizations.of(context)!
        .manage_employee_deactivate_dialog_confirm_message(user.name),
    onConfirm: () {
      context.read<ManageEmployeeBloc>().add(
            ManageEmployeeEventDeactivateEmployee(
              user: user,
            ),
          );

      context.pop();
    },
  );
}
