part of 'customer_bloc.dart';

abstract class CustomerEvent extends Equatable {
  const CustomerEvent();

  @override
  List<Object> get props => [];
}

class CustomerEventGetCustomers extends CustomerEvent {}

class CustomerEventGetActiveCustomers extends CustomerEvent {}

class CustomerEventGetCustomerById extends CustomerEvent {
  final String customerId;

  const CustomerEventGetCustomerById({
    required this.customerId,
  });

  @override
  List<Object> get props => [customerId];
}

class CustomerEventSearchCustomer extends CustomerEvent {
  final String query;

  const CustomerEventSearchCustomer({
    required this.query,
  });

  @override
  List<Object> get props => [query];
}

class CustomerEventSortCustomers extends CustomerEvent {
  final String sortBy;
  final bool ascending;

  const CustomerEventSortCustomers({
    required this.sortBy,
    required this.ascending,
  });

  @override
  List<Object> get props => [sortBy, ascending];
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

class CustomerEventDeactivateCustomer extends CustomerEvent {
  final String customerId;

  const CustomerEventDeactivateCustomer({
    required this.customerId,
  });

  @override
  List<Object> get props => [
        customerId,
      ];
}

class CustomerEventHardDeleteCustomer extends CustomerEvent {
  final String customerId;

  const CustomerEventHardDeleteCustomer({
    required this.customerId,
  });

  @override
  List<Object> get props => [
        customerId,
      ];
}
