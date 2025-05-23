import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../repositories/transaction_repository.dart';

class TransactionRestoreTransaction {
  final TransactionRepository transactionRepository;

  TransactionRestoreTransaction({
    required this.transactionRepository,
  });

  Future<Either<Failure, void>> call(String id) async {
    return await transactionRepository.restoreTransaction(id);
  }
}
