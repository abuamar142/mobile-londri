import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/usecases/transaction_get_transactions.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionGetTransactions serviceGetTransactions;

  TransactionBloc({
    required this.serviceGetTransactions,
  }) : super(TransactionStateInitial()) {
    on<TransactionEventGetTransactions>(
      (event, emit) => onTransactionEventGetTransactions(event, emit),
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
}
