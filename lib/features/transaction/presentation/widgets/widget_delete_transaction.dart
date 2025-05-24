import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/context_extensions.dart';
import '../../../../core/utils/show_confirmation_dialog.dart';
import '../../domain/entities/transaction.dart';
import '../bloc/transaction_bloc.dart';

Future<void> deleteTransaction({
  required BuildContext context,
  required Transaction transaction,
  required TransactionBloc transactionBloc,
  bool isHardDelete = false,
}) async {
  showConfirmationDialog(
    context: context,
    title: context.appText.transaction_delete_dialog_title,
    content: context.appText.transaction_delete_confirm_message(
      transaction.id.toString(),
    ),
    onConfirm: () {
      if (isHardDelete) {
        transactionBloc.add(
          TransactionEventHardDeleteTransaction(
            id: transaction.id.toString(),
          ),
        );
      } else {
        transactionBloc.add(
          TransactionEventDeleteTransaction(
            id: transaction.id.toString(),
          ),
        );
      }

      context.pop();
    },
  );
}
