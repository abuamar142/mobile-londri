import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../../../transaction/data/models/transaction_model.dart';
import '../models/statistic_model.dart';

abstract class HomeRemoteDatasource {
  Future<StatisticModel> getTodayStatistics();
}

class HomeRemoteDatasourceImplementation extends HomeRemoteDatasource {
  final SupabaseClient supabaseClient;

  HomeRemoteDatasourceImplementation({required this.supabaseClient});

  @override
  Future<StatisticModel> getTodayStatistics() async {
    try {
      final transactionsOnProgress = await supabaseClient
          .from('transactions')
          .select('''
            id, amount, created_at, payment_status, transaction_status, updated_at
          ''')
          .isFilter(
            'deleted_at',
            null,
          )
          .or(
            'transaction_status.eq.On Progress,transaction_status.eq.Ready for Pickup',
          );

      final List<TransactionModel> transactions = (transactionsOnProgress as List).map((transaction) => TransactionModel.fromJson(transaction)).toList();

      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final startDateStr = startOfDay.toIso8601String();
      final endDateStr = endOfDay.toIso8601String();

      final otherTransactions = await supabaseClient
          .from('transactions')
          .select('''
            id, amount, created_at, payment_status, transaction_status, updated_at
          ''')
          .gte(
            'created_at',
            startDateStr,
          )
          .lte(
            'created_at',
            endDateStr,
          )
          .isFilter(
            'deleted_at',
            null,
          )
          .filter(
            'transaction_status',
            'eq',
            'Picked Up',
          )
          .order(
            'created_at',
            ascending: false,
          );

      transactions.addAll((otherTransactions as List).map((transaction) => TransactionModel.fromJson(transaction)).toList());

      return StatisticModel.fromTransactionModels(transactions: transactions);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
