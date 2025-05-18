import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/transaction_status.dart';
import '../repositories/transaction_repository.dart';

class TransactionGetDefaultTransactionStatus {
  final TransactionRepository transactionRepository;

  TransactionGetDefaultTransactionStatus({
    required this.transactionRepository,
  });

  Future<Either<Failure, TransactionStatus>> call() async {
    return await transactionRepository.getDefaultTransactionStatus();
  }
}
