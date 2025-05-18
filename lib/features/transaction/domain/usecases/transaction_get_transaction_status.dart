// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

import '../../../../src/generated/i18n/app_localizations.dart';
import '../../domain/entities/transaction_status.dart';

enum TransactionStatusId {
  pending,
  received,
  in_progress,
  washing,
  drying,
  ironing,
  ready_for_pickup,
  picked_up,
  cancelled,
  delayed,
  default_status,
}

class GetTransactionStatus {
  TransactionStatus call(BuildContext context, TransactionStatusId id) {
    final appText = AppLocalizations.of(context)!;

    switch (id) {
      case TransactionStatusId.pending:
        return TransactionStatus(
          id: id,
          status: appText.transaction_status_pending,
          icon: Icons.access_time,
          color: Colors.orange,
        );
      case TransactionStatusId.received:
        return TransactionStatus(
          id: id,
          status: appText.transaction_status_received,
          icon: Icons.check_circle,
          color: Colors.blue,
        );
      case TransactionStatusId.in_progress:
        return TransactionStatus(
          id: id,
          status: appText.transaction_status_in_progress,
          icon: Icons.autorenew,
          color: Colors.purple,
        );
      case TransactionStatusId.washing:
        return TransactionStatus(
          id: id,
          status: appText.transaction_status_washing,
          icon: Icons.local_laundry_service,
          color: Colors.teal,
        );
      case TransactionStatusId.drying:
        return TransactionStatus(
          id: id,
          status: appText.transaction_status_drying,
          icon: Icons.waves,
          color: Colors.indigo,
        );
      case TransactionStatusId.ironing:
        return TransactionStatus(
          id: id,
          status: appText.transaction_status_ironing,
          icon: Icons.iron,
          color: Colors.pink,
        );
      case TransactionStatusId.ready_for_pickup:
        return TransactionStatus(
          id: id,
          status: appText.transaction_status_ready_for_pickup,
          icon: Icons.assignment_turned_in,
          color: Colors.grey,
        );
      case TransactionStatusId.picked_up:
        return TransactionStatus(
          id: id,
          status: appText.transaction_status_picked_up,
          icon: Icons.done_all,
          color: Colors.green,
        );
      case TransactionStatusId.cancelled:
        return TransactionStatus(
          id: id,
          status: appText.transaction_status_cancelled,
          icon: Icons.cancel,
          color: Colors.red,
        );
      case TransactionStatusId.delayed:
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
