import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class TransactionGetTransactions {
  final TransactionRepository transactionRepository;

  TransactionGetTransactions({
    required this.transactionRepository,
  });

  Future<Either<Failure, List<Transaction>>> call() async {
    return await transactionRepository.getTransactions();
  }
}
