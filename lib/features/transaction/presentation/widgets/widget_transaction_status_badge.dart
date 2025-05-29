import 'package:flutter/material.dart';

import '../../../../config/textstyle/app_colors.dart';
import '../../../../config/textstyle/app_sizes.dart';
import '../../../../config/textstyle/app_textstyle.dart';
import '../../domain/entities/transaction_status.dart';

class WidgetTransactionStatusBadge extends StatelessWidget {
  final TransactionStatus status;

  const WidgetTransactionStatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.size8,
        vertical: AppSizes.size4,
      ),
      decoration: BoxDecoration(
        color: status.backgroundColor,
        borderRadius: BorderRadius.circular(AppSizes.size16),
      ),
      child: Text(
        getTransactionStatusValue(context, status),
        style: AppTextStyle.caption.copyWith(
          color: AppColors.onPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
