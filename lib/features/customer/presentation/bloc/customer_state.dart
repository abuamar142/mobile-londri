part of 'customer_bloc.dart';

abstract class CustomerState extends Equatable {
  const CustomerState();

  @override
  List<Object> get props => [];
}

class CustomerStateInitial extends CustomerState {}

class CustomerStateLoading extends CustomerState {}

class CustomerStateSuccessGetCustomers extends CustomerState {
  final List<Customer> customers;

  const CustomerStateSuccessGetCustomers({
    required this.customers,
  });

  @override
  List<Object> get props => [customers];
}

class CustomerStateSuccessGetActiveCustomers extends CustomerState {
  final List<Customer> activeCustomers;

  const CustomerStateSuccessGetActiveCustomers({
    required this.activeCustomers,
  });

  @override
  List<Object> get props => [activeCustomers];
}

class CustomerStateSuccessGetCustomerById extends CustomerState {
  final Customer customer;

  const CustomerStateSuccessGetCustomerById({
    required this.customer,
  });

  @override
  List<Object> get props => [customer];
}

class CustomerStateWithFilteredCustomers extends CustomerState {
  final List<Customer> allCustomers;
  final List<Customer> filteredCustomers;

  const CustomerStateWithFilteredCustomers({
    required this.allCustomers,
    required this.filteredCustomers,
  });

  @override
  List<Object> get props => [allCustomers, filteredCustomers];
}

class CustomerStateSuccessCreateCustomer extends CustomerState {}

class CustomerStateSuccessUpdateCustomer extends CustomerState {}

class CustomerStateSuccessDeleteCustomer extends CustomerState {}

class CustomerStateSuccessActivateCustomer extends CustomerState {}

class CustomerStateFailure extends CustomerState {
  final String message;

  const CustomerStateFailure({
    required this.message,
  });

  @override
  List<Object> get props => [message];
}
