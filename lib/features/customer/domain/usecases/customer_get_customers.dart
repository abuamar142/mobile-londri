import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/customer.dart';
import '../repositories/customer_repository.dart';

class CustomerGetCustomers {
  final CustomerRepository customerRepository;

  CustomerGetCustomers({
    required this.customerRepository,
  });

  Future<Either<Failure, List<Customer>>> call() async {
    return await customerRepository.getCustomers();
  }
}
