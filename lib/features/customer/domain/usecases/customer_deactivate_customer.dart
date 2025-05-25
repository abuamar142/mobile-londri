import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../repositories/customer_repository.dart';

class CustomerDeactivateCustomer {
  final CustomerRepository customerRepository;

  CustomerDeactivateCustomer({
    required this.customerRepository,
  });

  Future<Either<Failure, void>> call(
    String customerId,
  ) async {
    return await customerRepository.deactivateCustomer(customerId);
  }
}
