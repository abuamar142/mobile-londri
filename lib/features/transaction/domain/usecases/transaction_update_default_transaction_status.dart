import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/transaction_status.dart';
import '../repositories/transaction_repository.dart';

class TransactionUpdateDefaultTransactionStatus {
  final TransactionRepository transactionRepository;

  TransactionUpdateDefaultTransactionStatus({
    required this.transactionRepository,
  });

  Future<Either<Failure, void>> call(
    TransactionStatus transactionStatus,
  ) async {
    return await transactionRepository.updateDefaultTransactionStatus(
      transactionStatus,
    );
  }
}
