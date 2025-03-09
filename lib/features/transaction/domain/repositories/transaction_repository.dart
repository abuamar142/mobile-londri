import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/transaction.dart';
import '../entities/transaction_status.dart';

abstract class TransactionRepository {
  // Transactions
  Future<Either<Failure, List<Transaction>>> getTransactions();
  Future<Either<Failure, void>> createTransaction(Transaction transaction);
  Future<Either<Failure, void>> updateTransaction(Transaction transaction);
  Future<Either<Failure, void>> deleteTransaction(String id);

  // Transaction Statuses
  Future<Either<Failure, TransactionStatus>> getDefaultTransactionStatus();
  Future<Either<Failure, void>> updateDefaultTransactionStatus(TransactionStatus transactionStatus);
}
