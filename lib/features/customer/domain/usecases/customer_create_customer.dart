import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/customer.dart';
import '../repositories/customer_repository.dart';

class CustomerCreateCustomer {
  final CustomerRepository customerRespository;

  CustomerCreateCustomer({
    required this.customerRespository,
  });

  Future<Either<Failure, void>> call(
    Customer customer,
  ) async {
    return await customerRespository.createCustomer(customer);
  }
}
