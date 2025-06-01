import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/statistic.dart';

abstract class HomeRepository {
  Future<Either<Failure, Statistic>> getTodayStatistics();
}
