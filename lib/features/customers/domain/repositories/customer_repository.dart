import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/customer.dart';

abstract class CustomerRepository {
  Future<Either<Failure, Customer>> getCustomerById(String customerId);
  Future<Either<Failure, List<Customer>>> getCustomers();
  Future<Either<Failure, void>> createCustomer(Customer customer);
  Future<Either<Failure, void>> deleteCustomer(String customerId);
}
