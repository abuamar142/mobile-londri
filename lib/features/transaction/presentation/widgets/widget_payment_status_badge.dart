import 'package:flutter/material.dart';

import '../../../../config/textstyle/app_colors.dart';
import '../../../../config/textstyle/app_sizes.dart';
import '../../../../config/textstyle/app_textstyle.dart';
import '../../domain/entities/payment_status.dart';

class WidgetPaymentStatusBadge extends StatelessWidget {
  final PaymentStatus status;

  const WidgetPaymentStatusBadge({
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
        getPaymentStatusValue(context, status),
        style: AppTextStyle.caption.copyWith(
          color: AppColors.onPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
