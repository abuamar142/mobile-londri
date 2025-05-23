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
