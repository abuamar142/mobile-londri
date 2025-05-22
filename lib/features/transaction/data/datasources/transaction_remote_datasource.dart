import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/clean_json.dart';
import '../models/transaction_model.dart';

abstract class TransactionRemoteDatasource {
  Future<List<TransactionModel>> readTransactions();
  Future<TransactionModel> readTransactionById(String id);
  Future<void> createTransaction(TransactionModel transaction);
  Future<void> updateTransaction(TransactionModel transaction);
  Future<void> deleteTransaction(String id);
  Future<void> activateTransaction(String id);
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
      final List<Map<String, dynamic>> response =
          await supabaseClient.from('transactions').select('''
            *,
            customers (
              name
            ),
            services (
              name
            )
          ''').order('created_at', ascending: false);

      return response.map((e) => TransactionModel.fromJson(e)).toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<TransactionModel> readTransactionById(String id) async {
    try {
      final Map<String, dynamic> response =
          await supabaseClient.from('transactions').select('''
            *,
            customers (
              name
            ),
            services (
              name
            )
          ''').eq('id', id).single();

      return TransactionModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> createTransaction(TransactionModel transaction) async {
    try {
      Map<String, dynamic> data = transaction.toJson().cleanNulls();

      await supabaseClient.from('transactions').insert(data);
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
          .from('transactions')
          .update(transaction.toUpdateJson())
          .eq('id', transaction.id!);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deleteTransaction(String id) async {
    try {
      await supabaseClient.from('transactions').update({
        'deleted_at': DateTime.now().toIso8601String(),
      }).eq('id', id);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> activateTransaction(String id) async {
    try {
      await supabaseClient.from('transactions').update({
        'deleted_at': null,
      }).eq('id', id);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
