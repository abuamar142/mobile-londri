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
    Color backgroundColor;
    Color textColor = Colors.white;

    switch (status) {
      case TransactionStatus.onProgress:
        backgroundColor = AppColors.gray;
        break;
      case TransactionStatus.readyForPickup:
        backgroundColor = AppColors.warning;
        break;
      case TransactionStatus.pickedUp:
        backgroundColor = AppColors.success;
        break;
      default:
        backgroundColor = AppColors.error;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.size8,
        vertical: AppSizes.size4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSizes.size16),
      ),
      child: Text(
        status.value,
        style: AppTextStyle.caption.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
