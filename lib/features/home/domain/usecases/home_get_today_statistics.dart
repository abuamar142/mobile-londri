import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/statistic.dart';
import '../repositories/home_repository.dart';

class HomeGetTodayStatistics {
  final HomeRepository homeRepository;

  HomeGetTodayStatistics({
    required this.homeRepository,
  });

  Future<Either<Failure, Statistic>> call() async {
    return await homeRepository.getTodayStatistics();
  }
}
