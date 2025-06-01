import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../transaction/data/models/transaction_model.dart';
import '../models/export_report_data_model.dart';

abstract interface class ExportReportRemoteDatasource {
  Future<ExportReportDataModel> getReportData({
    required DateTime startDate,
    required DateTime endDate,
  });
}

class ExportReportRemoteDatasourceImplementation implements ExportReportRemoteDatasource {
  final SupabaseClient _supabaseClient;

  const ExportReportRemoteDatasourceImplementation(this._supabaseClient);

  @override
  Future<ExportReportDataModel> getReportData({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Format dates for SQL query
      final startDateStr = startDate.toIso8601String().split('T')[0];
      final endDateStr = endDate.toIso8601String().split('T')[0];

      final response = await _supabaseClient
          .from('transactions')
          .select('''
            *,
            customers(id, name, phone, description),
            services(id, name, description, price)
          ''')
          .gte('created_at', '${startDateStr}T00:00:00.000Z')
          .lte('created_at', '${endDateStr}T23:59:59.999Z')
          .isFilter('deleted_at', null)
          .order('created_at', ascending: false);

      final List<TransactionModel> transactions = (response as List).map((transaction) => TransactionModel.fromJson(transaction)).toList();

      // Determine period based on date range
      String period;
      final difference = endDate.difference(startDate).inDays;
      if (difference == 0) {
        period = 'daily';
      } else if (difference <= 7) {
        period = 'weekly';
      } else {
        period = 'monthly';
      }

      return ExportReportDataModel.fromTransactionModels(
        transactions: transactions,
        startDate: startDate,
        endDate: endDate,
        period: period,
      );
    } catch (e) {
      throw Exception('Failed to get report data: $e');
    }
  }
}
