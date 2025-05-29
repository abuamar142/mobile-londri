import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/service.dart';
import '../repositories/service_repository.dart';

class ServiceGetDefaultService {
  final ServiceRepository serviceRepository;

  ServiceGetDefaultService({required this.serviceRepository});

  Future<Either<Failure, Service>> call() async {
    return await serviceRepository.readDefaultService();
  }
}
