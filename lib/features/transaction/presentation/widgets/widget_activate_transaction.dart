import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/show_confirmation_dialog.dart';
import '../../domain/entities/transaction.dart';
import '../bloc/transaction_bloc.dart';

Future<void> activateTransaction({
  required BuildContext context,
  required Transaction transaction,
  required TransactionBloc transactionBloc,
}) async {
  showConfirmationDialog(
    context: context,
    title: 'Activate Transaction',
    content: 'Are you sure you want to activate this transaction?',
    onConfirm: () {
      transactionBloc.add(
        TransactionEventActivateTransaction(
          id: transaction.id.toString(),
        ),
      );

      context.pop();
    },
  );
}
