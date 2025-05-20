import '../../domain/entities/transaction_status.dart';
import '../../domain/usecases/transaction_get_transaction_status.dart';

class TransactionStatusModel extends TransactionStatus {
  const TransactionStatusModel({
    super.id,
    super.status,
    super.icon,
    super.color,
  });

  factory TransactionStatusModel.fromJson(Map<String, dynamic> json) {
    return TransactionStatusModel(
      id: TransactionStatusId.values.firstWhere(
        (e) => e.name == json['id'],
      ),
      status: json['status'],
      icon: json['icon'],
      color: json['color'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'icon': icon,
      'color': color,
    };
  }
}
