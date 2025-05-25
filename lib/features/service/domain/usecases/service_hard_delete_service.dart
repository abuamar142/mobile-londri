import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../repositories/service_repository.dart';

class ServiceHardDeleteService {
  final ServiceRepository serviceRepository;

  ServiceHardDeleteService({
    required this.serviceRepository,
  });

  Future<Either<Failure, void>> call(String id) async {
    return serviceRepository.hardDeleteService(id);
  }
}
