part of 'transaction_bloc.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
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

class TransactionEventFilter extends TransactionEvent {
  final String? searchQuery;
  final String? sortBy;
  final bool? ascending;
  final TransactionStatus? transactionStatus;
  final bool? isIncludeInactive;
  final int? tabIndex;
  final String? tabName;

  const TransactionEventFilter({
    this.searchQuery,
    this.sortBy,
    this.ascending,
    this.transactionStatus,
    this.isIncludeInactive,
    this.tabIndex,
    this.tabName,
  });

  @override
  List<Object?> get props => [
        searchQuery,
        sortBy,
        ascending,
        transactionStatus,
        isIncludeInactive,
        tabIndex,
        tabName,
      ];
}

class TransactionEventUpdateTransactionStatus extends TransactionEvent {
  final String id;
  final TransactionStatus status;

  const TransactionEventUpdateTransactionStatus({
    required this.id,
    required this.status,
  });

  @override
  List<Object> get props => [id, status];
}

class TransactionEventUpdatePaymentStatus extends TransactionEvent {
  final String id;
  final PaymentStatus status;

  const TransactionEventUpdatePaymentStatus({
    required this.id,
    required this.status,
  });

  @override
  List<Object> get props => [id, status];
}
