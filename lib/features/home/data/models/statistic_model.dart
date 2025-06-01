import '../../../transaction/data/models/transaction_model.dart';
import '../../../transaction/domain/entities/payment_status.dart';
import '../../../transaction/domain/entities/transaction_status.dart';
import '../../domain/entities/statistic.dart';

class StatisticModel extends Statistic {
  const StatisticModel({
    required super.todayRevenue,
    required super.onProgressCount,
    required super.readyForPickupCount,
    required super.pickedUpCount,
  });

  factory StatisticModel.fromTransactionModels({
    required List<TransactionModel> transactions,
  }) {
    final todayRevenue = transactions.where((t) => t.paymentStatus?.value == PaymentStatus.paid.value && t.updatedAt.day == DateTime.now().day).fold(
          0.0,
          (sum, t) => sum + (t.amount?.toDouble() ?? 0.0),
        );
    final onProgressCount = transactions.where((t) => t.transactionStatus?.value == TransactionStatus.onProgress.value).length;
    final readyForPickupCount = transactions.where((t) => t.transactionStatus?.value == TransactionStatus.readyForPickup.value).length;
    final pickedUpCount = transactions.where((t) => t.transactionStatus?.value == TransactionStatus.pickedUp.value).length;

    return StatisticModel(
      todayRevenue: todayRevenue,
      onProgressCount: onProgressCount,
      readyForPickupCount: readyForPickupCount,
      pickedUpCount: pickedUpCount,
    );
  }
}
