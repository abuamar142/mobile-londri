import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../repositories/transaction_repository.dart';

class TransactionHardDeleteTransaction {
  final TransactionRepository transactionRepository;

  TransactionHardDeleteTransaction({
    required this.transactionRepository,
  });

  Future<Either<Failure, void>> call(String id) async {
    return await transactionRepository.hardDeleteTransaction(id);
  }
}
