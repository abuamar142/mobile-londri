import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/usecases/transaction_create_transaction.dart';
import '../../domain/usecases/transaction_get_transactions.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionGetTransactions serviceGetTransactions;
  final TransactionCreateTransaction serviceCreateTransaction;

  TransactionBloc({
    required this.serviceGetTransactions,
    required this.serviceCreateTransaction,
  }) : super(TransactionStateInitial()) {
    on<TransactionEventGetTransactions>(
      (event, emit) => onTransactionEventGetTransactions(event, emit),
    );
    on<TransactionEventCreateTransaction>(
      (event, emit) => onTransactionEventCreateTransaction(event, emit),
    );
  }

  void onTransactionEventGetTransactions(
    TransactionEventGetTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionStateLoading());

    Either<Failure, List<Transaction>> result = await serviceGetTransactions();

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

  void onTransactionEventCreateTransaction(
    TransactionEventCreateTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionStateLoading());

    Either<Failure, void> result = await serviceCreateTransaction(
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
}
