import 'package:flutter/material.dart';

import '../../../../config/textstyle/app_colors.dart';
import '../../../../core/utils/context_extensions.dart';

enum PaymentStatus {
  notPaidYet(value: 'Not Paid Yet', icon: Icons.money_off, backgroundColor: AppColors.warning),
  paid(value: 'Paid', icon: Icons.attach_money, backgroundColor: AppColors.success),
  other(value: 'Other', icon: Icons.help_outline, backgroundColor: AppColors.error);

  final String value;
  final IconData icon;
  final Color backgroundColor;

  const PaymentStatus({
    required this.value,
    required this.icon,
    required this.backgroundColor,
  });

  factory PaymentStatus.fromString(String value) {
    return PaymentStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => PaymentStatus.other,
    );
  }
}

String getPaymentStatusValue(BuildContext context, PaymentStatus status) {
  switch (status) {
    case PaymentStatus.notPaidYet:
      return context.appText.transaction_payment_status_not_paid_yet;
    case PaymentStatus.paid:
      return context.appText.transaction_payment_status_paid;
    default:
      return context.appText.transaction_payment_status_other;
  }
}
