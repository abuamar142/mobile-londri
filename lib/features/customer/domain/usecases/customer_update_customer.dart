import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/customer.dart';
import '../repositories/customer_repository.dart';

class CustomerUpdateCustomer {
  final CustomerRepository customerRepository;

  CustomerUpdateCustomer({
    required this.customerRepository,
  });

  Future<Either<Failure, void>> call(
    Customer customer,
  ) async {
    return await customerRepository.updateCustomer(customer);
  }
}
