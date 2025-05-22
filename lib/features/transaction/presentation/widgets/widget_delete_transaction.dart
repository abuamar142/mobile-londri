import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/show_confirmation_dialog.dart';
import '../../../../src/generated/i18n/app_localizations.dart';
import '../../domain/entities/transaction.dart';
import '../bloc/transaction_bloc.dart';

Future<void> deleteTransaction({
  required BuildContext context,
  required Transaction transaction,
  required TransactionBloc transactionBloc,
}) async {
  final appText = AppLocalizations.of(context)!;

  showConfirmationDialog(
    context: context,
    title: appText.transaction_delete_dialog_title,
    content: 'Apakah Anda yakin ingin menghapus transaksi?',
    onConfirm: () {
      transactionBloc.add(
        TransactionEventDeleteTransaction(
          id: transaction.id.toString(),
        ),
      );

      context.pop();
    },
  );
}
