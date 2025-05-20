import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_status.dart';
import '../../domain/usecases/transaction_create_transaction.dart';
import '../../domain/usecases/transaction_get_default_transaction_status.dart';
import '../../domain/usecases/transaction_get_transactions.dart';
import '../../domain/usecases/transaction_update_default_transaction_status.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionGetTransactions transactionGetTransactions;
  final TransactionGetDefaultTransactionStatus
      transactionGetDefaultTransactionStatus;
  final TransactionCreateTransaction transactionCreateTransaction;
  final TransactionUpdateDefaultTransactionStatus
      transactionUpdateDefaultTransactionStatus;

  TransactionBloc({
    required this.transactionGetTransactions,
    required this.transactionGetDefaultTransactionStatus,
    required this.transactionCreateTransaction,
    required this.transactionUpdateDefaultTransactionStatus,
  }) : super(TransactionStateInitial()) {
    on<TransactionEventGetTransactions>(
      (event, emit) => onTransactionEventGetTransactions(event, emit),
    );
    on<TransactionEventGetDefaultTransactionStatus>(
      (event, emit) =>
          onTransactionEventGetDefaultTransactionStatus(event, emit),
    );
    on<TransactionEventCreateTransaction>(
      (event, emit) => onTransactionEventCreateTransaction(event, emit),
    );
    on<TransactionEventUpdateDefaultTransactionStatus>(
      (event, emit) => onTransactionEventUpdateDefaultTransactionStatus(
        event,
        emit,
      ),
    );
  }

  void onTransactionEventGetTransactions(
    TransactionEventGetTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionStateLoading());

    Either<Failure, List<Transaction>> result =
        await transactionGetTransactions();

    result.fold((left) {
      emit(TransactionStateFailure(
        message: left.message,
      ));
    }, (right) {
      emit(TransactionStateSuccessGetTransactions(
        transactions: right,
      ));
    });
  }

  void onTransactionEventGetDefaultTransactionStatus(
    TransactionEventGetDefaultTransactionStatus event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionStateLoading());

    Either<Failure, TransactionStatus> result =
        await transactionGetDefaultTransactionStatus();

    result.fold((left) {
      emit(TransactionStateFailure(
        message: left.message,
      ));
    }, (right) {
      emit(TransactionStateSuccessGetDefaultTransactionStatus(
        transactionStatus: right,
      ));
    });
  }

  void onTransactionEventCreateTransaction(
    TransactionEventCreateTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionStateLoading());

    Either<Failure, void> result = await transactionCreateTransaction(
      event.transaction,
    );

    result.fold((left) {
      emit(TransactionStateFailure(
        message: left.message,
      ));
    }, (right) {
      emit(TransactionStateSuccessCreateTransaction());
      add(TransactionEventGetTransactions());
    });
  }

  void onTransactionEventUpdateDefaultTransactionStatus(
    TransactionEventUpdateDefaultTransactionStatus event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionStateLoading());

    Either<Failure, void> result =
        await transactionUpdateDefaultTransactionStatus(
      event.transactionStatus,
    );

    result.fold((left) {
      emit(TransactionStateFailure(
        message: left.message,
      ));
    }, (right) {
      emit(TransactionStateSuccessUpdateDefaultTransactionStatus());
      add(TransactionEventGetDefaultTransactionStatus());
    });
  }
}
