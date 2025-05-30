import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/payment_status.dart';
import '../repositories/transaction_repository.dart';

class TransactionUpdatePaymentStatus {
  final TransactionRepository transactionRepository;

  TransactionUpdatePaymentStatus({
    required this.transactionRepository,
  });

  Future<Either<Failure, void>> call(String id, PaymentStatus status) async {
    return await transactionRepository.updatePaymentStatus(id, status);
  }
}
