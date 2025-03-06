part of 'transaction_bloc.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object> get props => [];
}

class TransactionEventGetTransactions extends TransactionEvent {}

class TransactionEventCreateTransaction extends TransactionEvent {
  final Transaction transaction;

  const TransactionEventCreateTransaction({
    required this.transaction,
  });

  @override
  List<Object> get props => [
        transaction,
      ];
}
