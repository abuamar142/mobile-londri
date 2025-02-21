import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/customer.dart';
import '../../domain/repositories/customer_repository.dart';
import '../datasources/customer_remote_datasource.dart';
import '../models/customer_model.dart';

class CustomerRepositoryImplementation extends CustomerRepository {
  final CustomerRemoteDatasource customerRemoteDatasource;

  CustomerRepositoryImplementation({
    required this.customerRemoteDatasource,
  });

  @override
  Future<Either<Failure, List<CustomerModel>>> getCustomers() async {
    try {
      final response = await customerRemoteDatasource.readCustomers();

      response.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));

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
  Future<Either<Failure, CustomerModel>> getCustomerById(
      String customerId) async {
    try {
      final response =
          await customerRemoteDatasource.readCustomerById(customerId);

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
  Future<Either<Failure, void>> createCustomer(Customer customer) async {
    try {
      await customerRemoteDatasource.createCustomer(CustomerModel(
        id: Uuid().v4(),
        name: customer.name,
        phone: customer.phone,
        description: customer.description,
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
  Future<Either<Failure, void>> updateCustomer(Customer customer) async {
    try {
      await customerRemoteDatasource.updateCustomer(CustomerModel(
        id: customer.id,
        name: customer.name,
        phone: customer.phone,
        description: customer.description,
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
  Future<Either<Failure, void>> deleteCustomer(String customerId) async {
    try {
      await customerRemoteDatasource.deleteCustomer(customerId);

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
