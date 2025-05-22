import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class TransactionGetTransactionById {
  final TransactionRepository transactionRepository;

  TransactionGetTransactionById({
    required this.transactionRepository,
  });

  Future<Either<Failure, Transaction>> call(String id) async {
    return await transactionRepository.getTransactionById(id);
  }
}
