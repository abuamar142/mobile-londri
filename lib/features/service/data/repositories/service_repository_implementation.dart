import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/service.dart';
import '../../domain/repositories/service_repository.dart';
import '../datasources/service_local_datasource.dart';
import '../datasources/service_remote_datasource.dart';
import '../models/service_model.dart';

class ServiceRepositoryImplementation extends ServiceRepository {
  final ServiceRemoteDatasource serviceRemoteDatasource;
  final ServiceLocalDatasource serviceLocalDatasource;

  ServiceRepositoryImplementation({
    required this.serviceRemoteDatasource,
    required this.serviceLocalDatasource,
  });

  @override
  Future<Either<Failure, List<Service>>> getServices() async {
    try {
      final response = await serviceRemoteDatasource.readServices();
      return Right(response);
    } on ServerException catch (e) {
      return Left(Failure(message: e.message));
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Service>>> getActiveServices() async {
    try {
      final response = await serviceRemoteDatasource.readActiveServices();
      return Right(response);
    } on ServerException catch (e) {
      return Left(Failure(message: e.message));
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Service>> getServiceById(String id) async {
    try {
      final response = await serviceRemoteDatasource.readServiceById(id);
      return Right(response);
    } on ServerException catch (e) {
      return Left(Failure(message: e.message));
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createService(Service service) async {
    try {
      await serviceRemoteDatasource.createService(ServiceModel(
        name: service.name,
        description: service.description,
        price: service.price,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      return Right(null);
    } on ServerException catch (e) {
      return Left(Failure(message: e.message));
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateService(Service service) async {
    try {
      await serviceRemoteDatasource.updateService(ServiceModel(
        id: service.id,
        name: service.name,
        description: service.description,
        price: service.price,
        updatedAt: DateTime.now(),
      ));

      return Right(null);
    } on ServerException catch (e) {
      return Left(Failure(message: e.message));
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> activateService(String id) async {
    try {
      await serviceRemoteDatasource.activateService(id);
      return Right(null);
    } on ServerException catch (e) {
      return Left(Failure(message: e.message));
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deactivateService(String id) async {
    try {
      await serviceRemoteDatasource.deactivateService(id);
      return Right(null);
    } on ServerException catch (e) {
      return Left(Failure(message: e.message));
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> hardDeleteService(String id) async {
    try {
      await serviceRemoteDatasource.hardDeleteService(id);
      return Right(null);
    } on ServerException catch (e) {
      return Left(Failure(message: e.message));
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Service>> readDefaultService() async {
    try {
      final response = await serviceLocalDatasource.readDefaultService();
      return Right(response);
    } on ServerException catch (e) {
      return Left(Failure(message: e.message));
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createDefaultService(Service service) async {
    try {
      await serviceLocalDatasource.createDefaultService(
        ServiceModel(
          id: service.id,
          name: service.name,
          description: service.description,
          price: service.price,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      return Right(null);
    } on ServerException catch (e) {
      return Left(Failure(message: e.message));
    } catch (e) {
      return Left(Failure(message: e.toString()));
    }
  }
}
