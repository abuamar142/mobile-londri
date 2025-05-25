import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../repositories/customer_repository.dart';

class CustomerHardDeleteCustomer {
  final CustomerRepository customerRepository;

  CustomerHardDeleteCustomer({
    required this.customerRepository,
  });

  Future<Either<Failure, void>> call(String customerId) async {
    return await customerRepository.hardDeleteCustomer(customerId);
  }
}
