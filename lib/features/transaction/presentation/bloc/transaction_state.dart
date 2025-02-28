part of 'transaction_bloc.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object> get props => [];
}

class TransactionStateInitial extends TransactionState {}

class TransactionStateLoading extends TransactionState {}

class TransactionStateSuccessGetTransactions extends TransactionState {
  final List<Transaction> transactions;

  const TransactionStateSuccessGetTransactions({
    required this.transactions,
  });

  @override
  List<Object> get props => [
        transactions,
      ];
}

class TransactionStateFailure extends TransactionState {
  final String message;

  const TransactionStateFailure({
    required this.message,
  });

  @override
  List<Object> get props => [
        message,
      ];
}
