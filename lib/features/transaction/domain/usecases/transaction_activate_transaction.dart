import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../repositories/transaction_repository.dart';

class TransactionActivateTransaction {
  final TransactionRepository transactionRepository;

  TransactionActivateTransaction({
    required this.transactionRepository,
  });

  Future<Either<Failure, void>> call(String id) async {
    return await transactionRepository.activateTransaction(id);
  }
}
