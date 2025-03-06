import '../../domain/entities/transaction.dart';

class TransactionModel extends Transaction {
  final DateTime? createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const TransactionModel({
    super.id,
    super.staffId,
    super.customerId,
    super.customerName,
    super.serviceId,
    super.serviceName,
    super.weight,
    super.amount,
    super.status,
    super.startDate,
    super.endDate,
    this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      staffId: json['staff_id'],
      customerId: json['customer_id'],
      customerName:
          json['customers'] != null ? json['customers']['name'] : null,
      serviceId: json['service_id'],
      serviceName: json['services'] != null ? json['services']['name'] : null,
      weight: double.tryParse(json['weight'].toString()),
      amount: json['amount'],
      status: json['status'],
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'])
          : null,
      endDate:
          json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: DateTime.parse(json['updated_at']),
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'staff_id': staffId,
      'customer_id': customerId,
      'service_id': serviceId,
      'weight': weight,
      'amount': amount,
      'status': status,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
    };
  }

  Map<String, dynamic> toUpdateJson(TransactionModel service) {
    Map<String, dynamic> data = service.toJson();

    data.removeWhere((key, value) => value == null);

    return data;
  }
}
