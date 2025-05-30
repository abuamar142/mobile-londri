import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/clean_json.dart';
import '../../domain/entities/payment_status.dart';
import '../../domain/entities/transaction_status.dart';
import '../models/transaction_model.dart';

abstract class TransactionRemoteDatasource {
  Future<List<TransactionModel>> readTransactions();
  Future<TransactionModel> readTransactionById(String id);
  Future<void> createTransaction(TransactionModel transaction);
  Future<void> updateTransaction(TransactionModel transaction);
  Future<void> deleteTransaction(String id);
  Future<void> hardDeleteTransaction(String id);
  Future<void> restoreTransaction(String id);
  Future<void> updateTransactionStatus(String id, TransactionStatus status);
  Future<void> updatePaymentStatus(String id, PaymentStatus status);
}

class TransactionRemoteDatasourceImplementation extends TransactionRemoteDatasource {
  final SupabaseClient supabaseClient;

  TransactionRemoteDatasourceImplementation({
    required this.supabaseClient,
  });

  @override
  Future<List<TransactionModel>> readTransactions() async {
    try {
      final List<Map<String, dynamic>> response = await supabaseClient.from('transactions').select('''
            *,
            users (
              name
            ),
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
      final Map<String, dynamic> response = await supabaseClient.from('transactions').select('''
            *,
            users (
              name
            ),
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
          .update(
            transaction.toJson().cleanNulls(),
          )
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
  Future<void> hardDeleteTransaction(String id) async {
    try {
      await supabaseClient.from('transactions').delete().eq('id', id);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> restoreTransaction(String id) async {
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

  @override
  Future<void> updateTransactionStatus(String id, TransactionStatus status) async {
    try {
      await supabaseClient.from('transactions').update({
        'transaction_status': status.value,
      }).eq('id', id);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> updatePaymentStatus(String id, PaymentStatus status) async {
    try {
      await supabaseClient.from('transactions').update({
        'payment_status': status.value,
      }).eq('id', id);
    } on PostgrestException catch (e) {
      throw ServerException(message: e.message);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
