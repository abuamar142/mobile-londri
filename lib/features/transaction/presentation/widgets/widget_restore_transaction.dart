import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/context_extensions.dart';
import '../../../../core/utils/show_confirmation_dialog.dart';
import '../../domain/entities/transaction.dart';
import '../bloc/transaction_bloc.dart';

Future<void> restoreTransaction({
  required BuildContext context,
  required Transaction transaction,
  required TransactionBloc transactionBloc,
}) async {
  showConfirmationDialog(
    context: context,
    title: context.appText.transaction_restore_dialog_title,
    content: context.appText.transaction_restore_confirm_message(
      transaction.id.toString(),
    ),
    onConfirm: () {
      transactionBloc.add(
        TransactionEventRestoreTransaction(
          id: transaction.id.toString(),
        ),
      );

      context.pop();
    },
  );
}
