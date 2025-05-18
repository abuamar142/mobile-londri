import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/customer.dart';
import '../../domain/usecases/customer_activate_customer.dart';
import '../../domain/usecases/customer_create_customer.dart';
import '../../domain/usecases/customer_delete_customer.dart';
import '../../domain/usecases/customer_get_customers.dart';
import '../../domain/usecases/customer_update_customer.dart';

part 'customer_event.dart';
part 'customer_state.dart';

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final CustomerGetCustomers customerGetCustomers;
  final CustomerCreateCustomer customerCreateCustomer;
  final CustomerUpdateCustomer customerUpdateCustomer;
  final CustomerDeleteCustomer customerDeleteCustomer;
  final CustomerActivateCustomer customerActivateCustomer;

  CustomerBloc({
    required this.customerGetCustomers,
    required this.customerCreateCustomer,
    required this.customerUpdateCustomer,
    required this.customerDeleteCustomer,
    required this.customerActivateCustomer,
  }) : super(CustomerStateInitial()) {
    on<CustomerEventGetCustomers>(
      (event, emit) => onCustomerEventGetCustomers(event, emit),
    );
    on<CustomerEventCreateCustomer>(
      (event, emit) => onCustomerEventCreateCustomer(event, emit),
    );
    on<CustomerEventUpdateCustomer>(
      (event, emit) => onCustomerEventUpdateCustomer(event, emit),
    );
    on<CustomerEventDeleteCustomer>(
      (event, emit) => onCustomerEventDeleteCustomer(event, emit),
    );
    on<CustomerEventActivateCustomer>(
      (event, emit) => onCustomerEventActivateCustomer(event, emit),
    );
  }

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
      emit(CustomerStateSuccessGetCustomers(
        customers: right,
      ));
    });
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
      add(CustomerEventGetCustomers());
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
      add(CustomerEventGetCustomers());
    });
  }

  void onCustomerEventDeleteCustomer(
    CustomerEventDeleteCustomer event,
    Emitter<CustomerState> emit,
  ) async {
    emit(CustomerStateLoading());

    Either<Failure, void> result = await customerDeleteCustomer(
      event.customerId,
    );

    result.fold((left) {
      emit(CustomerStateFailure(
        message: left.message,
      ));
    }, (right) {
      emit(CustomerStateSuccessDeleteCustomer());
      add(CustomerEventGetCustomers());
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
}
