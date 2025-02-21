import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../repositories/customer_repository.dart';

class CustomerDeleteCustomer {
  final CustomerRepository customerRepository;

  CustomerDeleteCustomer({
    required this.customerRepository,
  });

  Future<Either<Failure, void>> call(
    String customerId,
  ) async {
    return await customerRepository.deleteCustomer(customerId);
  }
}
