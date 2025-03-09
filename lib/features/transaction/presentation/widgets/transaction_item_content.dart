import 'package:flutter/material.dart';

import '../../../../config/textstyle/app_textstyle.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../src/generated/i18n/app_localizations.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_status.dart';

class TransactionItemContent extends StatelessWidget {
  const TransactionItemContent({
    super.key,
    required this.transaction,
    required this.status,
  });

  final Transaction transaction;
  final TransactionStatus status;

  @override
  Widget build(BuildContext context) {
    final appText = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appText.transaction_item_service_label(
                          transaction.serviceName ??
                              appText.transaction_item_empty_service_name,
                        ),
                        style: AppTextstyle.tileSubtitle,
                      ),
                      SizedBox(height: 4),
                      Text(
                        appText.transaction_item_weight_label(
                          transaction.weight?.toStringAsFixed(2) ?? '0,00',
                        ),
                        style: AppTextstyle.tileSubtitle,
                      ),
                    ],
                  ),
                ],
              ),
              CircleAvatar(
                backgroundColor: status.color,
                child: Icon(
                  status.icon,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appText.transaction_item_start_date_label(
                      transaction.startDate?.formatDateTime() ?? '',
                    ),
                    style: AppTextstyle.tileSubtitleSmall.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  if (transaction.endDate != null)
                    Text(
                      appText.transaction_item_end_date_label(
                        transaction.endDate?.formatDateTime() ?? '',
                      ),
                      style: AppTextstyle.tileSubtitleSmall.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),
              SizedBox(width: 8),
              Text(
                status.status!,
                style: TextStyle(
                  fontSize: 12,
                  color: status.color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
