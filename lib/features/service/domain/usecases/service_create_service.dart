
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/service.dart';
import '../repositories/service_repository.dart';

class ServiceCreateService {
  final ServiceRepository serviceRepository;

  ServiceCreateService({
    required this.serviceRepository,
  });

  Future<Either<Failure, void>> call(Service service) async {
    return await serviceRepository.createService(service);
  }
}
