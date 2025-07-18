import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/customer.dart';
import '../../domain/usecases/customer_activate_customer.dart';
import '../../domain/usecases/customer_create_customer.dart';
import '../../domain/usecases/customer_deactivate_customer.dart';
import '../../domain/usecases/customer_get_active_customers.dart';
import '../../domain/usecases/customer_get_customer_by_id.dart';
import '../../domain/usecases/customer_get_customers.dart';
import '../../domain/usecases/customer_hard_delete_customer.dart';
import '../../domain/usecases/customer_update_customer.dart';

part 'customer_event.dart';
part 'customer_state.dart';

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final CustomerGetCustomers customerGetCustomers;
  final CustomerGetActiveCustomers customerGetActiveCustomers;
  final CustomerGetCustomerById customerGetCustomerById;
  final CustomerCreateCustomer customerCreateCustomer;
  final CustomerUpdateCustomer customerUpdateCustomer;
  final CustomerDeactivateCustomer customerDeactivateCustomer;
  final CustomerActivateCustomer customerActivateCustomer;
  final CustomerHardDeleteCustomer customerHardDeleteCustomer;

  CustomerBloc({
    required this.customerGetCustomers,
    required this.customerGetActiveCustomers,
    required this.customerGetCustomerById,
    required this.customerCreateCustomer,
    required this.customerUpdateCustomer,
    required this.customerActivateCustomer,
    required this.customerDeactivateCustomer,
    required this.customerHardDeleteCustomer,
  }) : super(CustomerStateInitial()) {
    on<CustomerEventGetCustomers>(
      (event, emit) => onCustomerEventGetCustomers(event, emit),
    );
    on<CustomerEventGetActiveCustomers>(
      (event, emit) => onCustomerEventGetActiveCustomers(event, emit),
    );
    on<CustomerEventGetCustomerById>(
      (event, emit) => onCustomerEventGetCustomerById(event, emit),
    );
    on<CustomerEventCreateCustomer>(
      (event, emit) => onCustomerEventCreateCustomer(event, emit),
    );
    on<CustomerEventUpdateCustomer>(
      (event, emit) => onCustomerEventUpdateCustomer(event, emit),
    );
    on<CustomerEventActivateCustomer>(
      (event, emit) => onCustomerEventActivateCustomer(event, emit),
    );
    on<CustomerEventDeactivateCustomer>(
      (event, emit) => onCustomerEventDeactivateCustomer(event, emit),
    );
    on<CustomerEventHardDeleteCustomer>(
      (event, emit) => onCustomerEventHardDeleteCustomer(event, emit),
    );
    on<CustomerEventSearchCustomer>(
      (event, emit) => onCustomerEventSearchCustomer(event, emit),
    );
    on<CustomerEventSortCustomers>(
      (event, emit) => onCustomerEventSortCustomers(event, emit),
    );
  }

  late List<Customer> _allCustomers;
  String _currentQuery = '';
  String _currentSortField = '';
  bool _isAscending = true;

  String get currentSortField => _currentSortField;
  bool get isAscending => _isAscending;

  void onCustomerEventGetCustomers(
    CustomerEventGetCustomers event,
    Emitter<CustomerState> emit,
  ) async {
    emit(CustomerStateLoading());

    Either<Failure, List<Customer>> result = await customerGetCustomers();

    result.fold((left) {
      emit(CustomerStateFailure(
        message: left.message,
      ));
    }, (right) {
      _allCustomers = right;
      emit(CustomerStateWithFilteredCustomers(
        allCustomers: _allCustomers,
        filteredCustomers: _sortAndFilter(
          _allCustomers,
          _currentQuery,
          _currentSortField,
          _isAscending,
        ),
      ));
    });
  }

  void onCustomerEventGetActiveCustomers(
    CustomerEventGetActiveCustomers event,
    Emitter<CustomerState> emit,
  ) async {
    emit(CustomerStateLoading());

    Either<Failure, List<Customer>> result = await customerGetActiveCustomers();

    result.fold((left) {
      emit(CustomerStateFailure(
        message: left.message,
      ));
    }, (right) {
      emit(CustomerStateSuccessGetActiveCustomers(activeCustomers: right));
    });
  }

  void onCustomerEventGetCustomerById(
    CustomerEventGetCustomerById event,
    Emitter<CustomerState> emit,
  ) async {
    emit(CustomerStateLoading());

    Either<Failure, Customer> result = await customerGetCustomerById(
      event.customerId,
    );

    result.fold((left) {
      emit(CustomerStateFailure(
        message: left.message,
      ));
    }, (right) {
      emit(CustomerStateSuccessGetCustomerById(customer: right));
    });
  }

  void onCustomerEventSearchCustomer(
    CustomerEventSearchCustomer event,
    Emitter<CustomerState> emit,
  ) {
    _currentQuery = event.query;
    final filtered = _sortAndFilter(
      _allCustomers,
      _currentQuery,
      _currentSortField,
      _isAscending,
    );
    emit(CustomerStateWithFilteredCustomers(
      allCustomers: _allCustomers,
      filteredCustomers: filtered,
    ));
  }

  void onCustomerEventSortCustomers(
    CustomerEventSortCustomers event,
    Emitter<CustomerState> emit,
  ) {
    _currentSortField = event.sortBy;
    _isAscending = event.ascending;

    final filtered = _sortAndFilter(
      _allCustomers,
      _currentQuery,
      _currentSortField,
      _isAscending,
    );

    emit(CustomerStateWithFilteredCustomers(
      allCustomers: _allCustomers,
      filteredCustomers: filtered,
    ));
  }

  List<Customer> _sortAndFilter(
    List<Customer> customers,
    String query,
    String sortField,
    bool ascending,
  ) {
    final lowerQuery = query.toLowerCase();
    List<Customer> filtered = customers
        .where((customer) =>
            (customer.name?.toLowerCase().contains(lowerQuery) ?? false) ||
            (customer.phone?.toLowerCase().contains(lowerQuery) ?? false) ||
            (customer.description?.toLowerCase().contains(lowerQuery) ?? false))
        .toList();

    filtered.sort((a, b) {
      int result;

      switch (sortField) {
        case 'name':
          result = (a.name ?? '').compareTo(b.name ?? '');
          break;
        case 'createdAt':
          result = (a.createdAt ?? DateTime.now()).compareTo(b.createdAt ?? DateTime.now());
          break;
        default:
          result = (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now());
      }

      return ascending ? result : -result;
    });

    return filtered;
  }

  void onCustomerEventCreateCustomer(
    CustomerEventCreateCustomer event,
    Emitter<CustomerState> emit,
  ) async {
    emit(CustomerStateLoading());

    Either<Failure, void> result = await customerCreateCustomer(event.customer);

    result.fold((left) {
      emit(CustomerStateFailure(
        message: left.message,
      ));
    }, (right) {
      emit(CustomerStateSuccessCreateCustomer());
    });
  }

  void onCustomerEventUpdateCustomer(
    CustomerEventUpdateCustomer event,
    Emitter<CustomerState> emit,
  ) async {
    emit(CustomerStateLoading());

    Either<Failure, void> result = await customerUpdateCustomer(event.customer);

    result.fold((left) {
      emit(CustomerStateFailure(
        message: left.message,
      ));
    }, (right) {
      emit(CustomerStateSuccessUpdateCustomer());
    });
  }

  void onCustomerEventActivateCustomer(
    CustomerEventActivateCustomer event,
    Emitter<CustomerState> emit,
  ) async {
    emit(CustomerStateLoading());

    Either<Failure, void> result = await customerActivateCustomer(
      event.customerId,
    );

    result.fold((left) {
      emit(CustomerStateFailure(
        message: left.message,
      ));
    }, (right) {
      emit(CustomerStateSuccessActivateCustomer());
      add(CustomerEventGetCustomers());
    });
  }

  void onCustomerEventDeactivateCustomer(
    CustomerEventDeactivateCustomer event,
    Emitter<CustomerState> emit,
  ) async {
    emit(CustomerStateLoading());

    Either<Failure, void> result = await customerDeactivateCustomer(
      event.customerId,
    );

    result.fold((left) {
      emit(CustomerStateFailure(
        message: left.message,
      ));
    }, (right) {
      emit(CustomerStateSuccessDeactivateCustomer());
    });
  }

  void onCustomerEventHardDeleteCustomer(
    CustomerEventHardDeleteCustomer event,
    Emitter<CustomerState> emit,
  ) async {
    emit(CustomerStateLoading());

    Either<Failure, void> result = await customerHardDeleteCustomer(
      event.customerId,
    );

    result.fold((left) {
      emit(CustomerStateFailure(
        message: left.message,
      ));
    }, (right) {
      emit(CustomerStateSuccessHardDeleteCustomer());
      add(CustomerEventGetCustomers());
    });
  }
}
