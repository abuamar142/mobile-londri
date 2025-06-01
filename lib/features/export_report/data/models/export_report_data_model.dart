import '../../../transaction/data/models/transaction_model.dart';
import '../../domain/entities/export_report_data.dart';

class ExportReportDataModel extends ExportReportData {
  const ExportReportDataModel({
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

  factory ExportReportDataModel.fromTransactionModels({
    required List<TransactionModel> transactions,
    required DateTime startDate,
    required DateTime endDate,
    required String period,
  }) {
    final totalRevenue = transactions.where((t) => t.paymentStatus?.value == 'Paid').fold(0.0, (sum, t) => sum + (t.amount?.toDouble() ?? 0.0));

    final onProgressCount = transactions.where((t) => t.transactionStatus?.value == 'On Progress').length;

    final readyForPickupCount = transactions.where((t) => t.transactionStatus?.value == 'Ready for Pickup').length;

    final pickedUpCount = transactions.where((t) => t.transactionStatus?.value == 'Picked Up').length;

    return ExportReportDataModel(
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
