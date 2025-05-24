part of 'transaction_bloc.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object> get props => [];
}

class TransactionEventGetTransactions extends TransactionEvent {}

class TransactionEventGetTransactionById extends TransactionEvent {
  final String id;

  const TransactionEventGetTransactionById({
    required this.id,
  });

  @override
  List<Object> get props => [id];
}

class TransactionEventCreateTransaction extends TransactionEvent {
  final Transaction transaction;

  const TransactionEventCreateTransaction({
    required this.transaction,
  });

  @override
  List<Object> get props => [transaction];
}

class TransactionEventUpdateTransaction extends TransactionEvent {
  final Transaction transaction;

  const TransactionEventUpdateTransaction({
    required this.transaction,
  });

  @override
  List<Object> get props => [transaction];
}

class TransactionEventDeleteTransaction extends TransactionEvent {
  final String id;

  const TransactionEventDeleteTransaction({
    required this.id,
  });

  @override
  List<Object> get props => [id];
}

class TransactionEventHardDeleteTransaction extends TransactionEvent {
  final String id;

  const TransactionEventHardDeleteTransaction({
    required this.id,
  });

  @override
  List<Object> get props => [id];
}

class TransactionEventRestoreTransaction extends TransactionEvent {
  final String id;

  const TransactionEventRestoreTransaction({
    required this.id,
  });

  @override
  List<Object> get props => [id];
}

class TransactionEventSearchTransaction extends TransactionEvent {
  final String query;

  const TransactionEventSearchTransaction({
    required this.query,
  });

  @override
  List<Object> get props => [query];
}

class TransactionEventSortTransactions extends TransactionEvent {
  final String sortBy;
  final bool ascending;

  const TransactionEventSortTransactions({
    required this.sortBy,
    required this.ascending,
  });

  @override
  List<Object> get props => [sortBy, ascending];
}
