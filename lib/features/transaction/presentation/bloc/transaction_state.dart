part of 'transaction_bloc.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object> get props => [];
}

class TransactionStateInitial extends TransactionState {}

class TransactionStateLoading extends TransactionState {}

class TransactionStateWithFilteredTransactions extends TransactionState {
  final List<Transaction> allTransactions;
  final List<Transaction> filteredTransactions;

  const TransactionStateWithFilteredTransactions({
    required this.allTransactions,
    required this.filteredTransactions,
  });

  @override
  List<Object> get props => [allTransactions, filteredTransactions];
}

class TransactionStateSuccessGetTransactions extends TransactionState {
  final List<Transaction> transactions;

  const TransactionStateSuccessGetTransactions({
    required this.transactions,
  });

  @override
  List<Object> get props => [transactions];
}

class TransactionStateSuccessGetTransactionById extends TransactionState {
  final Transaction transaction;

  const TransactionStateSuccessGetTransactionById({
    required this.transaction,
  });

  @override
  List<Object> get props => [transaction];
}

class TransactionStateSuccessCreateTransaction extends TransactionState {}

class TransactionStateSuccessUpdateTransaction extends TransactionState {}

class TransactionStateSuccessDeleteTransaction extends TransactionState {}

class TransactionStateSuccessRestoreTransaction extends TransactionState {}

class TransactionStateFailure extends TransactionState {
  final String message;

  const TransactionStateFailure({
    required this.message,
  });

  @override
  List<Object> get props => [message];
}
