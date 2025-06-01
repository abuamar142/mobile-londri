import 'package:equatable/equatable.dart';

import '../../../transaction/domain/entities/transaction.dart';

class ExportReport extends Equatable {
  final List<Transaction> transactions;
  final DateTime startDate;
  final DateTime endDate;
  final String period;
  final double totalRevenue;
  final int totalTransactions;
  final int onProgressCount;
  final int readyForPickupCount;
  final int pickedUpCount;

  const ExportReport({
    required this.transactions,
    required this.startDate,
    required this.endDate,
    required this.period,
    required this.totalRevenue,
    required this.totalTransactions,
    required this.onProgressCount,
    required this.readyForPickupCount,
    required this.pickedUpCount,
  });

  @override
  List<Object?> get props => [
        transactions,
        startDate,
        endDate,
        period,
        totalRevenue,
        totalTransactions,
        onProgressCount,
        readyForPickupCount,
        pickedUpCount,
      ];
}
