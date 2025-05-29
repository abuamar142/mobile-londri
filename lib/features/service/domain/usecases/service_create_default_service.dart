import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/service.dart';
import '../repositories/service_repository.dart';

class ServiceCreateDefaultService {
  final ServiceRepository serviceRepository;

  ServiceCreateDefaultService({required this.serviceRepository});

  Future<Either<Failure, void>> call(Service service) async {
    return await serviceRepository.createDefaultService(service);
  }
}
