import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class TransactionCreateTransaction {
  final TransactionRepository transactionRepository;

  TransactionCreateTransaction({
    required this.transactionRepository,
  });

  Future<Either<Failure, String>> call(Transaction transaction) async {
    return await transactionRepository.createTransaction(transaction);
  }
}
