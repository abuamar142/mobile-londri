import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../repositories/service_repository.dart';

class ServiceDeleteService {
  final ServiceRepository serviceRepository;

  ServiceDeleteService({
    required this.serviceRepository,
  });

  Future<Either<Failure, void>> call(String id) async {
    return serviceRepository.deleteService(id);
  }
}
