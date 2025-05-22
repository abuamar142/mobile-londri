import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/show_confirmation_dialog.dart';
import '../../../../src/generated/i18n/app_localizations.dart';
import '../../domain/entities/service.dart';
import '../bloc/service_bloc.dart';

Future<void> activateService({
  required BuildContext context,
  required Service service,
  required ServiceBloc serviceBloc,
}) async {
  final appText = AppLocalizations.of(context)!;

  showConfirmationDialog(
    context: context,
    title: appText.service_activate_dialog_title,
    content: appText.service_activate_confirm_message(service.name!),
    onConfirm: () {
      serviceBloc.add(
        ServiceEventActivateService(
          id: service.id.toString(),
        ),
      );

      context.pop();
    },
  );
}
