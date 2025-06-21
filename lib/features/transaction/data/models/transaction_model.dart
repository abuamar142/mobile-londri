import '../../domain/entities/payment_status.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_status.dart';

class TransactionModel extends Transaction {
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final DateTime? paidAt;

  const TransactionModel({
    super.id,
    super.userId,
    super.userName,
    super.customerId,
    super.customerName,
    super.serviceId,
    super.serviceName,
    super.weight,
    super.amount,
    super.description,
    super.transactionStatus,
    super.paymentStatus,
    super.startDate,
    super.endDate,
    super.createdAt,
    required this.updatedAt,
    this.paidAt,
    this.deletedAt,
  }) : super(
          isDeleted: deletedAt != null,
        );

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      userId: json['staff_id']?.toString(),
      userName: json['users'] != null ? json['users']['name'] : null,
      customerId: json['customer_id'],
      customerName: json['customers'] != null ? json['customers']['name'] : null,
      serviceId: json['service_id'],
      serviceName: json['services'] != null ? json['services']['name'] : null,
      weight: json['weight'] != null ? double.parse(json['weight'].toString()) : null,
      amount: json['amount'],
      description: json['description'],
      transactionStatus: json['transaction_status'] != null ? TransactionStatus.fromString(json['transaction_status']) : TransactionStatus.onProgress,
      paymentStatus: json['payment_status'] != null ? PaymentStatus.fromString(json['payment_status']) : PaymentStatus.notPaidYet,
      startDate: json['start_date'] != null ? DateTime.parse(json['start_date']) : null,
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : DateTime.now(),
      paidAt: json['paid_at'] != null ? DateTime.parse(json['paid_at']) : null,
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'staff_id': userId != null ? int.tryParse(userId!) : null,
      'customer_id': customerId,
      'service_id': serviceId,
      'weight': weight,
      'amount': amount,
      'description': description,
      'transaction_status': transactionStatus?.value,
      'payment_status': paymentStatus?.value,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'paid_at': paidAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }
}
