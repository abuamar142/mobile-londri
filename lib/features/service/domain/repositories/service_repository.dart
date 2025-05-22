import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/service.dart';

abstract class ServiceRepository {
  Future<Either<Failure, List<Service>>> getServices();
  Future<Either<Failure, Service>> getServiceById(String id);
  Future<Either<Failure, void>> createService(Service service);
  Future<Either<Failure, void>> updateService(Service service);
  Future<Either<Failure, void>> deleteService(String id);
  Future<Either<Failure, void>> activateService(String id);
}
