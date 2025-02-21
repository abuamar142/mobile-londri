import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../repositories/customer_repository.dart';

class CustomerDeleteCustomer {
  final CustomerRepository customerRespository;

  CustomerDeleteCustomer({
    required this.customerRespository,
  });

  Future<Either<Failure, void>> call(
    String customerId,
  ) async {
    return await customerRespository.deleteCustomer(customerId);
  }
}
