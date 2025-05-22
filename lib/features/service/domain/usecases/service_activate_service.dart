import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../repositories/service_repository.dart';

class ServiceActivateService {
  final ServiceRepository serviceRepository;

  ServiceActivateService({
    required this.serviceRepository,
  });

  Future<Either<Failure, void>> call(String id) async {
    return serviceRepository.activateService(id);
  }
}
