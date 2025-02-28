import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../config/textstyle/app_textstyle.dart';
import '../../domain/entities/transaction.dart';

class TransactionItemTitle extends StatelessWidget {
  const TransactionItemTitle({
    super.key,
    required this.transaction,
  });

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    final appText = AppLocalizations.of(context)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            transaction.customerName ??
                appText.transaction_item_empty_customer_name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextstyle.tileTitle,
          ),
        ),
        SizedBox(width: 8),
        Text(
          'Rp ${transaction.amount?.toStringAsFixed(0) ?? '0'}',
          style: AppTextstyle.tileTitle.copyWith(
            color: Colors.green,
          ),
        ),
      ],
    );
  }
}
