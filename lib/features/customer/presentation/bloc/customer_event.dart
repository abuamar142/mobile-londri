part of 'customer_bloc.dart';

abstract class CustomerEvent extends Equatable {
  const CustomerEvent();

  @override
  List<Object> get props => [];
}

class CustomerEventGetCustomers extends CustomerEvent {}

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
  final String customerId;

  const CustomerEventDeleteCustomer({
    required this.customerId,
  });

  @override
  List<Object> get props => [
        customerId,
      ];
}

class CustomerEventActivateCustomer extends CustomerEvent {
  final String customerId;

  const CustomerEventActivateCustomer({
    required this.customerId,
  });

  @override
  List<Object> get props => [
        customerId,
      ];
}
