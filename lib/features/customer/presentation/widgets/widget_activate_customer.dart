import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/show_confirmation_dialog.dart';
import '../../../../src/generated/i18n/app_localizations.dart';
import '../../domain/entities/customer.dart';
import '../bloc/customer_bloc.dart';

Future<void> activateCustomer({
  required BuildContext context,
  required Customer customer,
  required CustomerBloc customerBloc,
}) async {
  showConfirmationDialog(
    context: context,
    title: AppLocalizations.of(context)!.customer_activate_dialog_title,
    content: AppLocalizations.of(context)!.customer_activate_confirm_message(
      customer.name!,
    ),
    onConfirm: () {
      customerBloc.add(
        CustomerEventActivateCustomer(
          customerId: customer.id.toString(),
        ),
      );

      context.pop();
    },
  );
}
