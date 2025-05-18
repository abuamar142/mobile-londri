import 'package:equatable/equatable.dart';

import '../usecases/transaction_get_transaction_status.dart';

class Transaction extends Equatable {
  final String? id;
  final String? staffId;
  final String? customerId;
  final String? customerName;
  final String? serviceId;
  final String? serviceName;
  final double? weight;
  final int? amount;
  final TransactionStatusId? status;
  final DateTime? startDate;
  final DateTime? endDate;

  const Transaction({
    this.id,
    this.staffId,
    this.customerId,
    this.customerName,
    this.serviceId,
    this.serviceName,
    this.weight,
    this.amount,
    this.status,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [
        id,
        staffId,
        customerId,
        customerName,
        serviceId,
        serviceName,
        weight,
        amount,
        status,
        startDate,
        endDate,
      ];
}
