import '../../../transaction/data/models/transaction_model.dart';
import '../../../transaction/domain/entities/payment_status.dart';
import '../../../transaction/domain/entities/transaction_status.dart';
import '../../domain/entities/export_report.dart';

class ExportReportModel extends ExportReport {
  const ExportReportModel({
    required super.transactions,
    required super.startDate,
    required super.endDate,
    required super.period,
    required super.totalRevenue,
    required super.totalTransactions,
    required super.onProgressCount,
    required super.readyForPickupCount,
    required super.pickedUpCount,
  });

  factory ExportReportModel.fromTransactionModels({
    required List<TransactionModel> transactions,
    required DateTime startDate,
    required DateTime endDate,
    required String period,
  }) {
    final totalRevenue =
        transactions.where((t) => t.paymentStatus?.value == PaymentStatus.paid.value).fold(0.0, (sum, t) => sum + (t.amount?.toDouble() ?? 0.0));
    final onProgressCount = transactions.where((t) => t.transactionStatus?.value == TransactionStatus.onProgress.value).length;
    final readyForPickupCount = transactions.where((t) => t.transactionStatus?.value == TransactionStatus.readyForPickup.value).length;
    final pickedUpCount = transactions.where((t) => t.transactionStatus?.value == TransactionStatus.pickedUp.value).length;

    return ExportReportModel(
      transactions: transactions,
      startDate: startDate,
      endDate: endDate,
      period: period,
      totalRevenue: totalRevenue,
      totalTransactions: transactions.length,
      onProgressCount: onProgressCount,
      readyForPickupCount: readyForPickupCount,
      pickedUpCount: pickedUpCount,
    );
  }
}
