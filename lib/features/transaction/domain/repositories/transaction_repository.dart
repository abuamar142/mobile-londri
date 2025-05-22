import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/transaction.dart';

abstract class TransactionRepository {
  Future<Either<Failure, List<Transaction>>> getTransactions();
  Future<Either<Failure, Transaction>> getTransactionById(String id);
  Future<Either<Failure, void>> createTransaction(Transaction transaction);
  Future<Either<Failure, void>> updateTransaction(Transaction transaction);
  Future<Either<Failure, void>> deleteTransaction(String id);
  Future<Either<Failure, void>> activateTransaction(String id);
}
