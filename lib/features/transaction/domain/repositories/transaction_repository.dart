import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/payment_status.dart';
import '../entities/transaction.dart';
import '../entities/transaction_status.dart';

abstract class TransactionRepository {
  Future<Either<Failure, List<Transaction>>> getTransactions();
  Future<Either<Failure, Transaction>> getTransactionById(String id);
  Future<Either<Failure, String>> createTransaction(Transaction transaction);
  Future<Either<Failure, void>> updateTransaction(Transaction transaction);
  Future<Either<Failure, void>> deleteTransaction(String id);
  Future<Either<Failure, void>> hardDeleteTransaction(String id);
  Future<Either<Failure, void>> restoreTransaction(String id);
  Future<Either<Failure, void>> updateTransactionStatus(String id, TransactionStatus status);
  Future<Either<Failure, void>> updatePaymentStatus(String id, PaymentStatus status);
}
