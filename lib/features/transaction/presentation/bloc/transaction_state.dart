part of 'transaction_bloc.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object?> get props => [];
}

class TransactionStateInitial extends TransactionState {}

class TransactionStateLoading extends TransactionState {}

class TransactionStateWithFilteredTransactions extends TransactionState {
  final List<Transaction> allTransactions;
  final List<Transaction> filteredTransactions;
  final String searchQuery;
  final String sortField;
  final bool isAscending;
  final TransactionStatus? selectedStatus;
  final bool? isIncludeInactive;
  final int currentTabIndex; // Tambahkan metadata tab
  final String tabName; // Tambahkan nama tab untuk debugging

  const TransactionStateWithFilteredTransactions({
    required this.allTransactions,
    required this.filteredTransactions,
    required this.searchQuery,
    required this.sortField,
    required this.isAscending,
    this.selectedStatus,
    this.isIncludeInactive,
    required this.currentTabIndex,
    required this.tabName,
  });

  @override
  List<Object?> get props => [
        allTransactions,
        filteredTransactions,
        searchQuery,
        sortField,
        isAscending,
        selectedStatus,
        isIncludeInactive,
        currentTabIndex,
        tabName,
      ];

  bool get isInactiveTab => currentTabIndex == 0;
  bool get isAllTab => currentTabIndex == 1;
  bool get isActiveTab => currentTabIndex == 2;
  bool get isOnProgressTab => currentTabIndex == 3;
  bool get isReadyTab => currentTabIndex == 4;
  bool get isPickedUpTab => currentTabIndex == 5;

  bool get canRestoreTransactions => isInactiveTab || isAllTab;
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
