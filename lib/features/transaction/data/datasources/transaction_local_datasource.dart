import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/usecases/transaction_get_transaction_status.dart';
import '../models/transaction_status_model.dart';

abstract class TransactionLocalDatasource {
  Future<TransactionStatusModel> getDefaultTransactionStatus();
  Future<void> updateDefaultTransactionStatus(
    TransactionStatusModel transactionStatusModel,
  );
}

class TransactionLocalDatasourceImplementation
    extends TransactionLocalDatasource {
  final SharedPreferences sharedPreferences;

  TransactionLocalDatasourceImplementation({
    required this.sharedPreferences,
  });

  @override
  Future<TransactionStatusModel> getDefaultTransactionStatus() async {
    try {
      final transactionStatus = sharedPreferences.getString(
        'defaultTransactionStatus',
      );

      if (transactionStatus != null) {
        return TransactionStatusModel.fromJson(
          jsonDecode(transactionStatus),
        );
      } else {
        return TransactionStatusModel(
          id: TransactionStatusId.default_status,
        );
      }
    } catch (e) {
      throw GeneralException(
        message: e.toString(),
      );
    }
  }

  @override
  Future<void> updateDefaultTransactionStatus(
    TransactionStatusModel transactionStatusModel,
  ) async {
    try {
      final transactionStatusJson = jsonEncode({
        'id': transactionStatusModel.id!.name,
      });

      await sharedPreferences.setString(
        'defaultTransactionStatus',
        transactionStatusJson,
      );
    } catch (e) {
      throw GeneralException(
        message: e.toString(),
      );
    }
  }
}
