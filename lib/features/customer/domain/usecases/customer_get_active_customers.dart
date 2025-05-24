import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/customer.dart';
import '../repositories/customer_repository.dart';

class CustomerGetActiveCustomers {
  final CustomerRepository customerRepository;

  CustomerGetActiveCustomers({
    required this.customerRepository,
  });

  Future<Either<Failure, List<Customer>>> call() async {
    return await customerRepository.getActiveCustomers();
  }
}
