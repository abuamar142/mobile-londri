import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../domain/entities/transaction_status.dart';

class GetTransactionStatus {
  TransactionStatus call(BuildContext context, String id) {
    final appText = AppLocalizations.of(context)!;

    switch (id) {
      case 'pending':
        return TransactionStatus(
          id: id,
          status: appText.transaction_status_pending,
          icon: Icons.access_time,
          color: Colors.orange,
        );
      case 'received':
        return TransactionStatus(
          id: id,
          status: appText.transaction_status_received,
          icon: Icons.check_circle,
          color: Colors.blue,
        );
      case 'in_progress':
        return TransactionStatus(
          id: id,
          status: appText.transaction_status_in_progress,
          icon: Icons.autorenew,
          color: Colors.purple,
        );
      case 'washing':
        return TransactionStatus(
          id: id,
          status: appText.transaction_status_washing,
          icon: Icons.local_laundry_service,
          color: Colors.teal,
        );
      case 'drying':
        return TransactionStatus(
          id: id,
          status: appText.transaction_status_drying,
          icon: Icons.waves,
          color: Colors.indigo,
        );
      case 'ironing':
        return TransactionStatus(
          id: id,
          status: appText.transaction_status_ironing,
          icon: Icons.iron,
          color: Colors.pink,
        );
      case 'ready_for_pickup':
        return TransactionStatus(
          id: id,
          status: appText.transaction_status_ready_for_pickup,
          icon: Icons.assignment_turned_in,
          color: Colors.grey,
        );
      case 'picked_up':
        return TransactionStatus(
          id: id,
          status: appText.transaction_status_picked_up,
          icon: Icons.done_all,
          color: Colors.green,
        );
      case 'cancelled':
        return TransactionStatus(
          id: id,
          status: appText.transaction_status_cancelled,
          icon: Icons.cancel,
          color: Colors.red,
        );
      case 'delayed':
        return TransactionStatus(
          id: id,
          status: appText.transaction_status_delayed,
          icon: Icons.warning,
          color: Colors.amber,
        );
      default:
        return TransactionStatus(
          id: id,
          status: appText.transaction_status_default,
          icon: Icons.help_outline,
          color: Colors.grey,
        );
    }
  }
}
