import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../usecases/transaction_get_transaction_status.dart';

class TransactionStatus extends Equatable {
  final TransactionStatusId? id;
  final String? status;
  final IconData? icon;
  final Color? color;

  const TransactionStatus({
    required this.id,
    required this.status,
    required this.icon,
    required this.color,
  });

  @override
  List<Object?> get props => [
        id,
        status,
        icon,
        color,
      ];
}
