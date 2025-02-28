import 'package:flutter/material.dart';

import '../../../../core/utils/launch_whatsapp.dart';
import '../../../../core/utils/show_snackbar.dart';
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
            onLongPress: () async {
              if (transaction.status != 'ready_for_pickup') {
                showSnackbar(
                  context,
                  'Transaction not ready for pickup',
                );
              } else if (transaction.customerPhone == null) {
                showSnackbar(
                  context,
                  'No phone number available',
                );
              } else {
                final phone = transaction.customerPhone.toString();
                final phonePattern = RegExp(r'^62\d{10,12}$');

                if (!phonePattern.hasMatch(phone)) {
                  showSnackbar(
                    context,
                    'Phone number must start with 62 and have 10-12 digits after it',
                  );
                } else {
                  try {
                    await launchWhatsapp(
                      phone: phone,
                      message:
                          'Laundry atas nama ${transaction.customerName} sudah selesai dan bisa diambil',
                    );
                  } catch (e) {
                    showSnackbar(
                      context,
                      'Failed to open WhatsApp',
                    );
                  }
                }
              }
            },
          ),
        );
      },
    );
  }
}
