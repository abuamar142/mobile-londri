import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../../../transaction/data/models/transaction_model.dart';
import '../models/export_report_data_model.dart';

abstract class ExportReportRemoteDatasource {
  Future<ExportReportModel> getReportData(DateTime startDate, DateTime endDate);
}

class ExportReportRemoteDatasourceImplementation extends ExportReportRemoteDatasource {
  final SupabaseClient supabaseClient;

  ExportReportRemoteDatasourceImplementation({required this.supabaseClient});

  @override
  Future<ExportReportModel> getReportData(DateTime startDate, DateTime endDate) async {
    try {
      final startDateStr = startDate.toIso8601String().split('T')[0];
      final endDateStr = endDate.toIso8601String().split('T')[0];

      final response = await supabaseClient
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

      String period;
      final difference = endDate.difference(startDate).inDays;
      if (difference == 0) {
        period = 'daily';
      } else if (difference <= 7) {
        period = 'weekly';
      } else {
        period = 'monthly';
      }

      return ExportReportModel.fromTransactionModels(
        transactions: transactions,
        startDate: startDate,
        endDate: endDate,
        period: period,
      );
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
