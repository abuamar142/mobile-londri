import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/service.dart';
import '../../domain/repositories/service_repository.dart';
import '../datasources/service_remote_datasource.dart';
import '../models/service_model.dart';

class ServiceRepositoryImplementation extends ServiceRepository {
  final ServiceRemoteDatasourceImplementation
      serviceRemoteDatasourceImplementation;

  ServiceRepositoryImplementation({
    required this.serviceRemoteDatasourceImplementation,
  });

  @override
  Future<Either<Failure, List<Service>>> getServices() async {
    try {
      final response =
          await serviceRemoteDatasourceImplementation.readServices();

      return Right(response);
    } on ServerException catch (e) {
      return Left(
        Failure(message: e.message),
      );
    } catch (e) {
      return Left(
        Failure(message: e.toString()),
      );
    }
  }

  @override
  Future<Either<Failure, Service>> getServiceById(String id) async {
    try {
      final response =
          await serviceRemoteDatasourceImplementation.readServiceById(id);

      return Right(response);
    } on ServerException catch (e) {
      return Left(
        Failure(message: e.message),
      );
    } catch (e) {
      return Left(
        Failure(message: e.toString()),
      );
    }
  }

  @override
  Future<Either<Failure, void>> createService(Service service) async {
    try {
      await serviceRemoteDatasourceImplementation.createService(ServiceModel(
        id: Uuid().v4(),
        name: service.name,
        description: service.description,
        price: service.price,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      return Right(null);
    } on ServerException catch (e) {
      return Left(
        Failure(message: e.message),
      );
    } catch (e) {
      return Left(
        Failure(message: e.toString()),
      );
    }
  }

  @override
  Future<Either<Failure, void>> updateService(Service service) async {
    try {
      await serviceRemoteDatasourceImplementation.updateService(ServiceModel(
        id: service.id,
        name: service.name,
        description: service.description,
        price: service.price,
        updatedAt: DateTime.now(),
      ));

      return Right(null);
    } on ServerException catch (e) {
      return Left(
        Failure(message: e.message),
      );
    } catch (e) {
      return Left(
        Failure(message: e.toString()),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteService(String id) async {
    try {
      await serviceRemoteDatasourceImplementation.deleteService(id);

      return Right(null);
    } on ServerException catch (e) {
      return Left(
        Failure(message: e.message),
      );
    } catch (e) {
      return Left(
        Failure(message: e.toString()),
      );
    }
  }
}
