import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class TransactionUpdateTransaction {
  final TransactionRepository transactionRepository;

  TransactionUpdateTransaction({
    required this.transactionRepository,
  });

  Future<Either<Failure, void>> call(Transaction transaction) async {
    return await transactionRepository.updateTransaction(transaction);
  }
}
