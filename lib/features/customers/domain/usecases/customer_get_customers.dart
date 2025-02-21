import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../entities/customer.dart';
import '../repositories/customer_repository.dart';

class CustomerGetCustomers {
  final CustomerRepository customerRespository;

  CustomerGetCustomers({
    required this.customerRespository,
  });

  Future<Either<Failure, List<Customer>>> call() async {
    return await customerRespository.getCustomers();
  }
}
