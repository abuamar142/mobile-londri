import 'package:flutter/material.dart';

import '../../domain/entities/transaction.dart';
import '../../domain/usecases/transaction_get_transaction_status.dart';
import 'transaction_item_content.dart';
import 'transaction_item_title.dart';

class TransactionItem extends StatelessWidget {
  final List<Transaction> transactions;

  const TransactionItem({
    super.key,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final Transaction transaction = transactions[index];

        final getTransactionStatus = GetTransactionStatus();
        final status = getTransactionStatus(
          context,
          transaction.status ?? '',
        );

        return Card(
          margin: const EdgeInsets.only(
            top: 16,
            right: 16,
            left: 16,
          ),
          elevation: 2,
          child: ListTile(
            key: ValueKey(transaction.id),
            title: TransactionItemTitle(
              transaction: transaction,
            ),
            subtitle: TransactionItemContent(
              transaction: transaction,
              status: status,
            ),
          ),
        );
      },
    );
  }
}
