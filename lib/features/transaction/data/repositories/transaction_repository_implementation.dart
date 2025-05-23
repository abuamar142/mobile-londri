import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_status.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_remote_datasource.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImplementation extends TransactionRepository {
  final TransactionRemoteDatasource transactionRemoteDatasource;

  TransactionRepositoryImplementation({
    required this.transactionRemoteDatasource,
  });

  @override
  Future<Either<Failure, List<Transaction>>> getTransactions() async {
    try {
      final response = await transactionRemoteDatasource.readTransactions();
      return Right(response);
    } on ServerException catch (e) {
      return Left(Failure(message: e.message));
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Transaction>> getTransactionById(String id) async {
    try {
      final response =
          await transactionRemoteDatasource.readTransactionById(id);
      return Right(response);
    } on ServerException catch (e) {
      return Left(Failure(message: e.message));
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createTransaction(
      Transaction transaction) async {
    try {
      await transactionRemoteDatasource.createTransaction(
        TransactionModel(
          userId: transaction.userId,
          customerId: transaction.customerId,
          serviceId: transaction.serviceId,
          weight: transaction.weight,
          amount: transaction.amount,
          description: transaction.description,
          transactionStatus:
              transaction.transactionStatus ?? TransactionStatus.onProgress,
          paymentStatus: transaction.paymentStatus ?? PaymentStatus.notPaidYet,
          startDate: transaction.startDate ?? DateTime.now(),
          endDate: transaction.endDate ??
              DateTime.now().add(const Duration(days: 3)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      return const Right(null);
    } on ServerException catch (e) {
      return Left(Failure(message: e.message));
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateTransaction(
      Transaction transaction) async {
    try {
      await transactionRemoteDatasource.updateTransaction(
        TransactionModel(
          id: transaction.id,
          userId: transaction.userId,
          customerId: transaction.customerId,
          serviceId: transaction.serviceId,
          weight: transaction.weight,
          amount: transaction.amount,
          description: transaction.description,
          transactionStatus: transaction.transactionStatus,
          paymentStatus: transaction.paymentStatus,
          startDate: transaction.startDate,
          endDate: transaction.endDate,
          updatedAt: DateTime.now(),
        ),
      );

      return const Right(null);
    } on ServerException catch (e) {
      return Left(Failure(message: e.message));
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTransaction(String id) async {
    try {
      await transactionRemoteDatasource.deleteTransaction(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(Failure(message: e.message));
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> hardDeleteTransaction(String id) async {
    try {
      await transactionRemoteDatasource.hardDeleteTransaction(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(Failure(message: e.message));
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> restoreTransaction(String id) async {
    try {
      await transactionRemoteDatasource.restoreTransaction(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(Failure(message: e.message));
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }
}
