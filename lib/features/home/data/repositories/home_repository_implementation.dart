import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/statistic.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_datasource.dart';

class HomeRepositoryImplementation extends HomeRepository {
  final HomeRemoteDatasource homeRemoteDatasource;

  HomeRepositoryImplementation({
    required this.homeRemoteDatasource,
  });

  @override
  Future<Either<Failure, Statistic>> getTodayStatistics() async {
    try {
      final response = await homeRemoteDatasource.getTodayStatistics();
      return Right(response);
    } on ServerException catch (e) {
      return Left(Failure(message: e.message));
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }
}
