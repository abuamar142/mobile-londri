import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/customer.dart';
import '../repositories/customer_repository.dart';

class CustomerGetCustomerById {
  final CustomerRepository customerRepository;

  CustomerGetCustomerById({
    required this.customerRepository,
  });

  Future<Either<Failure, Customer>> call(
    String customerId,
  ) async {
    return await customerRepository.getCustomerById(customerId);
  }
}
