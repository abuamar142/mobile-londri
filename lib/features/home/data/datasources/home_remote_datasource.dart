import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../models/statistic_model.dart';

abstract class HomeRemoteDatasource {
  Future<StatisticModel> getTodayStatistics();
}

class HomeRemoteDatasourceImplementation extends HomeRemoteDatasource {
  final SupabaseClient supabaseClient;

  HomeRemoteDatasourceImplementation({
    required this.supabaseClient,
  });

  @override
  Future<StatisticModel> getTodayStatistics() async {
    try {
      // Get transaction status counts for last 3 days
      final response = await supabaseClient.rpc('get_transaction_status_count_last_3_days');
      final List<Map<String, dynamic>> statusCounts = (response as List).cast<Map<String, dynamic>>();

      // Get total income for last 3 days
      final last3DaysIncome = await supabaseClient.rpc('get_total_income_last_3_days');

      // Create StatisticModel using RPC data
      return StatisticModel.fromRpcData(
        statusCounts: statusCounts,
        totalIncome: last3DaysIncome as int,
      );
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
