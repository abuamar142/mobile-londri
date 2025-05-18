import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/service.dart';
import '../repositories/service_repository.dart';

class ServiceUpdateService {
  final ServiceRepository serviceRepository;

  ServiceUpdateService({
    required this.serviceRepository,
  });

  Future<Either<Failure, void>> call(Service service) async {
    return await serviceRepository.updateService(service);
  }
}
