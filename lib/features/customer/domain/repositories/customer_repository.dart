import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/customer.dart';

abstract class CustomerRepository {
  Future<Either<Failure, List<Customer>>> getCustomers();
  Future<Either<Failure, List<Customer>>> getActiveCustomers();
  Future<Either<Failure, Customer>> getCustomerById(String id);
  Future<Either<Failure, void>> createCustomer(Customer customer);
  Future<Either<Failure, void>> updateCustomer(Customer customer);
  Future<Either<Failure, void>> activateCustomer(String customerId);
  Future<Either<Failure, void>> deactivateCustomer(String customerId);
  Future<Either<Failure, void>> hardDeleteCustomer(String customerId);
}
