part of 'transaction_bloc.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object> get props => [];
}

class TransactionEventGetTransactions extends TransactionEvent {}

class TransactionEventGetDefaultTransactionStatus extends TransactionEvent {}

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

class TransactionEventUpdateDefaultTransactionStatus extends TransactionEvent {
  final TransactionStatus transactionStatus;

  const TransactionEventUpdateDefaultTransactionStatus({
    required this.transactionStatus,
  });

  @override
  List<Object> get props => [
        transactionStatus,
      ];
}
