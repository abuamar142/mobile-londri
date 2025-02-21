part of 'customer_bloc.dart';

abstract class CustomerEvent extends Equatable {
  const CustomerEvent();

  @override
  List<Object> get props => [];
}

class CustomerEventGetCustomers extends CustomerEvent {}

class CustomerEventGetCustomerById extends CustomerEvent {
  final String id;

  const CustomerEventGetCustomerById({
    required this.id,
  });

  @override
  List<Object> get props => [
        id,
      ];
}

class CustomerEventCreateCustomer extends CustomerEvent {
  final Customer customer;

  const CustomerEventCreateCustomer({
    required this.customer,
  });

  @override
  List<Object> get props => [
        customer,
      ];
}

class CustomerEventUpdateCustomer extends CustomerEvent {
  final Customer customer;

  const CustomerEventUpdateCustomer({
    required this.customer,
  });

  @override
  List<Object> get props => [
        customer,
      ];
}

class CustomerEventDeleteCustomer extends CustomerEvent {
  final String id;

  const CustomerEventDeleteCustomer({
    required this.id,
  });

  @override
  List<Object> get props => [
        id,
      ];
}
