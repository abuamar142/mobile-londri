import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../repositories/service_repository.dart';

class ServiceDeactivateService {
  final ServiceRepository serviceRepository;

  ServiceDeactivateService({
    required this.serviceRepository,
  });

  Future<Either<Failure, void>> call(String id) async {
    return serviceRepository.deactivateService(id);
  }
}
