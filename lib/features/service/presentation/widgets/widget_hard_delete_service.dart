import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/context_extensions.dart';
import '../../../../core/utils/show_confirmation_dialog.dart';
import '../../domain/entities/service.dart';
import '../bloc/service_bloc.dart';

Future<void> hardDeleteService({
  required BuildContext context,
  required Service service,
  required ServiceBloc serviceBloc,
}) async {
  showConfirmationDialog(
    context: context,
    title: context.appText.service_hard_delete_dialog_title,
    content: context.appText.service_hard_delete_confirm_message(service.name!),
    onConfirm: () {
      serviceBloc.add(
        ServiceEventHardDeleteService(
          id: service.id.toString(),
        ),
      );

      context.pop();
    },
  );
}
