import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/transaction_status.dart';
import '../repositories/transaction_repository.dart';

class TransactionUpdateTransactionStatus {
  final TransactionRepository transactionRepository;

  TransactionUpdateTransactionStatus({
    required this.transactionRepository,
  });

  Future<Either<Failure, void>> call(String id, TransactionStatus status) async {
    return await transactionRepository.updateTransactionStatus(id, status);
  }
}
