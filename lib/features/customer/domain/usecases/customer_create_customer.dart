import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/customer.dart';
import '../repositories/customer_repository.dart';

class CustomerCreateCustomer {
  final CustomerRepository customerRepository;

  CustomerCreateCustomer({
    required this.customerRepository,
  });

  Future<Either<Failure, void>> call(
    Customer customer,
  ) async {
    return await customerRepository.createCustomer(customer);
  }
}
