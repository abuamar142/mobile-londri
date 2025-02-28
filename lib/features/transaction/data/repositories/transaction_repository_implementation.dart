import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_remote_datasource.dart';

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
  Future<Either<Failure, void>> createTransaction(Transaction transaction) {
    // TODO: implement createTransaction
    throw UnimplementedError();
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

}
