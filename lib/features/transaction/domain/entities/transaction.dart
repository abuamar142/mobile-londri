import 'package:equatable/equatable.dart';

import 'transaction_status.dart';

class Transaction extends Equatable {
  final String? id;
  final String? userId;
  final int? customerId;
  final String? customerName;
  final int? serviceId;
  final String? serviceName;
  final double? weight;
  final int? amount;
  final String? description;
  final TransactionStatus? transactionStatus;
  final PaymentStatus? paymentStatus;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? createdAt;
  final bool? isActive;

  const Transaction({
    this.id,
    this.userId,
    this.customerId,
    this.customerName,
    this.serviceId,
    this.serviceName,
    this.weight,
    this.amount,
    this.description,
    this.transactionStatus,
    this.paymentStatus,
    this.startDate,
    this.endDate,
    this.createdAt,
    this.isActive,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        customerId,
        customerName,
        serviceId,
        serviceName,
        weight,
        amount,
        description,
        transactionStatus,
        paymentStatus,
        startDate,
        endDate,
        createdAt,
        isActive,
      ];
}
