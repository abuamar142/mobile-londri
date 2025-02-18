import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/service.dart';
import '../repositories/service_repository.dart';

class ServiceGetServiceById {
  final ServiceRepository serviceRepository;

  ServiceGetServiceById({
    required this.serviceRepository,
  });

  Future<Either<Failure, Service>> call(String id) async {
    return await serviceRepository.getServiceById(id);
  }
}
