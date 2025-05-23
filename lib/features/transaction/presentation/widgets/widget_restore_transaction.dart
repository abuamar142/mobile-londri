import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
    title: 'Restore Transaction',
    content: 'Are you sure you want to restore this transaction?',
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
