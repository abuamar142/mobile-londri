import 'package:flutter/material.dart';

import '../../../../config/textstyle/app_colors.dart';
import '../../../../config/textstyle/app_sizes.dart';
import '../../../../config/textstyle/app_textstyle.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_status.dart';
import 'widget_payment_status_badge.dart';
import 'widget_transaction_status_badge.dart';

class WidgetTransactionCard extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const WidgetTransactionCard({
    super.key,
    required this.transaction,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final isDeleted = transaction.isDeleted ?? false;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: isDeleted ? Colors.white : AppColors.gray.withAlpha(50),
          borderRadius: BorderRadius.circular(AppSizes.size12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withAlpha(75),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.size12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nota ID row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Transaction status
                  WidgetTransactionStatusBadge(
                    status: transaction.transactionStatus ?? TransactionStatus.onProgress,
                  ),

                  // Payment status
                  WidgetPaymentStatusBadge(
                    status: transaction.paymentStatus ?? PaymentStatus.notPaidYet,
                  ),
                ],
              ),

              AppSizes.spaceHeight8,

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Customer name
                        Text(
                          transaction.customerName ?? 'No Customer',
                          style: AppTextStyle.tileTitle.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        AppSizes.spaceHeight4,

                        // Service name
                        Text(
                          transaction.serviceName ?? 'No Service',
                          style: AppTextStyle.tileSubtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Amount
                      Text(
                        (transaction.amount ?? 0).formatNumber(),
                        style: AppTextStyle.tileTrailing.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),

                      AppSizes.spaceHeight4,

                      // Weight
                      Text(
                        "${transaction.weight ?? 0} kg",
                        style: AppTextStyle.tileSubtitle.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Divider
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSizes.size8),
                child: Divider(
                  height: 1,
                  color: AppColors.gray.withAlpha(50),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Start date
                  Text(
                    transaction.startDate != null ? transaction.startDate!.formatDateOnly() : '?',
                    style: AppTextStyle.tileSubtitle.copyWith(
                      fontSize: AppSizes.size12,
                      color: AppColors.gray,
                    ),
                  ),

                  if (transaction.endDate != null)
                    Icon(
                      Icons.arrow_forward,
                      size: AppSizes.size16,
                      color: AppColors.gray,
                    ),

                  // End date
                  Text(
                    transaction.endDate != null ? transaction.endDate!.formatDateOnly() : '-',
                    style: AppTextStyle.tileSubtitle.copyWith(
                      fontSize: AppSizes.size12,
                      color: AppColors.gray,
                    ),
                  ),
                ],
              ),

              AppSizes.spaceHeight4,

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Invoice ID
                  Text(
                    "Invoice: ${transaction.id ?? 'N/A'}",
                    style: AppTextStyle.tileSubtitle.copyWith(
                      fontSize: AppSizes.size12,
                      color: AppColors.gray,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Staff ID
                  Text(
                    "Staff: ${transaction.userName ?? 'N/A'}",
                    style: AppTextStyle.tileSubtitle.copyWith(
                      fontSize: AppSizes.size12,
                      color: AppColors.gray,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
