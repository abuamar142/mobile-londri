import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../models/transaction_model.dart';

abstract class TransactionRemoteDatasource {
  Future<List<TransactionModel>> readTransactions();
  Future<void> createTransaction(TransactionModel transaction);
  Future<void> updateTransaction(TransactionModel transaction);
  Future<void> deleteTransaction(String id);
}

class TransactionRemoteDatasourceImplementation
    extends TransactionRemoteDatasource {
  final SupabaseClient supabaseClient;

  TransactionRemoteDatasourceImplementation({
    required this.supabaseClient,
  });

  @override
  Future<List<TransactionModel>> readTransactions() async {
    try {
      final List<Map<String, dynamic>> response = await supabaseClient
          .from(
            'transactions',
          )
          .select(
            '''
              *,
              customers(name),
              services(name)
            ''',
          )
          .filter('deleted_at', 'is', null)
          .order('created_at', ascending: false);

      print(response);

      return response.map((e) => TransactionModel.fromJson(e)).toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> createTransaction(TransactionModel transaction) async {
    try {
      await supabaseClient
          .from(
            'transactions',
          )
          .insert(transaction.toJson());
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      await supabaseClient
          .from(
            'transactions',
          )
          .update(transaction.toUpdateJson(transaction))
          .eq('id', transaction.id!);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deleteTransaction(String id) {
    try {
      return supabaseClient
          .from(
        'transactions',
      )
          .update(
        {
          'deleted_at': DateTime.now().toIso8601String(),
        },
      ).eq('id', id);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
