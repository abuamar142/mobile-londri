import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/service.dart';

abstract class ServiceRepository {
  Future<Either<Failure, List<Service>>> getServices();
  Future<Either<Failure, Service>> getServiceById(String id);
  Future<Either<Failure, List<Service>>> getActiveServices();
  Future<Either<Failure, void>> createService(Service service);
  Future<Either<Failure, void>> updateService(Service service);
  Future<Either<Failure, void>> activateService(String id);
  Future<Either<Failure, void>> deactivateService(String id);
  Future<Either<Failure, void>> hardDeleteService(String id);
  Future<Either<Failure, Service>> readDefaultService();
  Future<Either<Failure, void>> createDefaultService(Service service);
}
