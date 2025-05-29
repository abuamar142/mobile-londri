import 'package:flutter/material.dart';

import '../../../../config/textstyle/app_colors.dart';
import '../../../../core/utils/context_extensions.dart';

enum TransactionStatus {
  onProgress(value: 'On Progress', icon: Icons.hourglass_empty, backgroundColor: AppColors.gray),
  readyForPickup(value: 'Ready for Pickup', icon: Icons.shopping_bag, backgroundColor: AppColors.warning),
  pickedUp(value: 'Picked Up', icon: Icons.check_circle, backgroundColor: AppColors.success),
  other(value: 'Other', icon: Icons.help_outline, backgroundColor: AppColors.error);

  final String value;
  final IconData icon;
  final Color backgroundColor;

  const TransactionStatus({
    required this.value,
    required this.icon,
    required this.backgroundColor,
  });

  factory TransactionStatus.fromString(String value) {
    return TransactionStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => TransactionStatus.other,
    );
  }
}

String getTransactionStatusValue(BuildContext context, TransactionStatus status) {
  switch (status) {
    case TransactionStatus.onProgress:
      return context.appText.transaction_status_on_progress;
    case TransactionStatus.readyForPickup:
      return context.appText.transaction_status_ready_for_pickup;
    case TransactionStatus.pickedUp:
      return context.appText.transaction_status_picked_up;
    default:
      return context.appText.transaction_status_other;
  }
}
