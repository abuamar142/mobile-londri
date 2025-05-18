import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_status.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_local_datasource.dart';
import '../datasources/transaction_remote_datasource.dart';
import '../models/transaction_model.dart';
import '../models/transaction_status_model.dart';

class TransactionRepositoryImplementation extends TransactionRepository {
  final TransactionRemoteDatasource transactionRemoteDatasource;
  final TransactionLocalDatasource transactionLocalDatasource;

  TransactionRepositoryImplementation({
    required this.transactionRemoteDatasource,
    required this.transactionLocalDatasource,
  });

  @override
  Future<Either<Failure, List<Transaction>>> getTransactions() async {
    try {
      final response = await transactionRemoteDatasource.readTransactions();

      return Right(response);
    } on ServerException catch (e) {
      return Left(
        Failure(message: e.message),
      );
    } catch (e) {
      return Left(
        Failure(message: e.toString()),
      );
    }
  }

  @override
  Future<Either<Failure, void>> createTransaction(
    Transaction transaction,
  ) async {
    try {
      await transactionRemoteDatasource.createTransaction(TransactionModel(
        id: Uuid().v4(),
        staffId: dotenv.env['STAFF_ID']!,
        customerId: transaction.customerId,
        serviceId: transaction.serviceId,
        weight: transaction.weight,
        amount: transaction.amount,
        startDate: transaction.startDate,
        endDate: transaction.endDate,
        status: transaction.status,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      return Right(null);
    } on ServerException catch (e) {
      return Left(
        Failure(message: e.message),
      );
    } catch (e) {
      return Left(
        Failure(message: e.toString()),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteTransaction(String id) {
    // TODO: implement deleteTransaction
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> updateTransaction(Transaction transaction) {
    // TODO: implement updateTransaction
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, TransactionStatus>>
      getDefaultTransactionStatus() async {
    try {
      final response =
          await transactionLocalDatasource.getDefaultTransactionStatus();

      return Right(response);
    } on GeneralException catch (e) {
      return Left(
        Failure(message: e.message),
      );
    }
  }

  @override
  Future<Either<Failure, void>> updateDefaultTransactionStatus(
    TransactionStatus transactionStatus,
  ) async {
    try {
      await transactionLocalDatasource.updateDefaultTransactionStatus(
        TransactionStatusModel(
          id: transactionStatus.id,
          status: transactionStatus.status,
          icon: transactionStatus.icon,
          color: transactionStatus.color,
        ),
      );

      return Right(null);
    } on GeneralException catch (e) {
      return Left(
        Failure(message: e.message),
      );
    }
  }
}
