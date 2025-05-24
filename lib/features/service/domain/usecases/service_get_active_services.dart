import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/service.dart';
import '../repositories/service_repository.dart';

class ServiceGetActiveServices {
  final ServiceRepository serviceRepository;

  ServiceGetActiveServices({
    required this.serviceRepository,
  });

  Future<Either<Failure, List<Service>>> call() async {
    return await serviceRepository.getActiveServices();
  }
}
