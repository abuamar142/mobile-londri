import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/usecases/transaction_activate_transaction.dart';
import '../../domain/usecases/transaction_create_transaction.dart';
import '../../domain/usecases/transaction_delete_transaction.dart';
import '../../domain/usecases/transaction_get_transaction_by_id.dart';
import '../../domain/usecases/transaction_get_transactions.dart';
import '../../domain/usecases/transaction_update_transaction.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionGetTransactions transactionGetTransactions;
  final TransactionGetTransactionById transactionGetTransactionById;
  final TransactionCreateTransaction transactionCreateTransaction;
  final TransactionUpdateTransaction transactionUpdateTransaction;
  final TransactionDeleteTransaction transactionDeleteTransaction;
  final TransactionActivateTransaction transactionActivateTransaction;

  late List<Transaction> _allTransactions;
  String _currentQuery = '';
  String _currentSortField = 'createdAt';
  bool _isAscending = false;

  String get currentSortField => _currentSortField;
  bool get isAscending => _isAscending;

  TransactionBloc({
    required this.transactionGetTransactions,
    required this.transactionGetTransactionById,
    required this.transactionCreateTransaction,
    required this.transactionUpdateTransaction,
    required this.transactionDeleteTransaction,
    required this.transactionActivateTransaction,
  }) : super(TransactionStateInitial()) {
    on<TransactionEventGetTransactions>(
      (event, emit) => onTransactionEventGetTransactions(event, emit),
    );
    on<TransactionEventGetTransactionById>(
      (event, emit) => onTransactionEventGetTransactionById(event, emit),
    );
    on<TransactionEventCreateTransaction>(
      (event, emit) => onTransactionEventCreateTransaction(event, emit),
    );
    on<TransactionEventUpdateTransaction>(
      (event, emit) => onTransactionEventUpdateTransaction(event, emit),
    );
    on<TransactionEventDeleteTransaction>(
      (event, emit) => onTransactionEventDeleteTransaction(event, emit),
    );
    on<TransactionEventActivateTransaction>(
      (event, emit) => onTransactionEventActivateTransaction(event, emit),
    );
    on<TransactionEventSearchTransaction>(
      (event, emit) => onTransactionEventSearchTransaction(event, emit),
    );
    on<TransactionEventSortTransactions>(
      (event, emit) => onTransactionEventSortTransactions(event, emit),
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
      _allTransactions = right;
      emit(TransactionStateWithFilteredTransactions(
        allTransactions: _allTransactions,
        filteredTransactions: _sortAndFilter(
          _allTransactions,
          _currentQuery,
          _currentSortField,
          _isAscending,
        ),
      ));
    });
  }

  void onTransactionEventGetTransactionById(
    TransactionEventGetTransactionById event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionStateLoading());

    Either<Failure, Transaction> result =
        await transactionGetTransactionById(event.id);

    result.fold((left) {
      emit(TransactionStateFailure(
        message: left.message,
      ));
    }, (right) {
      emit(TransactionStateSuccessGetTransactionById(
        transaction: right,
      ));
    });
  }

  void onTransactionEventCreateTransaction(
    TransactionEventCreateTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionStateLoading());

    Either<Failure, void> result =
        await transactionCreateTransaction(event.transaction);

    result.fold((left) {
      emit(TransactionStateFailure(
        message: left.message,
      ));
    }, (right) {
      emit(TransactionStateSuccessCreateTransaction());
    });
  }

  void onTransactionEventUpdateTransaction(
    TransactionEventUpdateTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionStateLoading());

    Either<Failure, void> result =
        await transactionUpdateTransaction(event.transaction);

    result.fold((left) {
      emit(TransactionStateFailure(
        message: left.message,
      ));
    }, (right) {
      emit(TransactionStateSuccessUpdateTransaction());
    });
  }

  void onTransactionEventDeleteTransaction(
    TransactionEventDeleteTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionStateLoading());

    Either<Failure, void> result = await transactionDeleteTransaction(event.id);

    result.fold((left) {
      emit(TransactionStateFailure(
        message: left.message,
      ));
    }, (right) {
      emit(TransactionStateSuccessDeleteTransaction());
    });
  }

  void onTransactionEventActivateTransaction(
    TransactionEventActivateTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionStateLoading());

    Either<Failure, void> result =
        await transactionActivateTransaction(event.id);

    result.fold((left) {
      emit(TransactionStateFailure(
        message: left.message,
      ));
    }, (right) {
      emit(TransactionStateSuccessActivateTransaction());
      add(
        TransactionEventGetTransactions(),
      );
    });
  }

  void onTransactionEventSearchTransaction(
    TransactionEventSearchTransaction event,
    Emitter<TransactionState> emit,
  ) {
    _currentQuery = event.query;
    final filtered = _sortAndFilter(
      _allTransactions,
      _currentQuery,
      _currentSortField,
      _isAscending,
    );

    emit(TransactionStateWithFilteredTransactions(
      allTransactions: _allTransactions,
      filteredTransactions: filtered,
    ));
  }

  void onTransactionEventSortTransactions(
    TransactionEventSortTransactions event,
    Emitter<TransactionState> emit,
  ) {
    _currentSortField = event.sortBy;
    _isAscending = event.ascending;

    final filtered = _sortAndFilter(
      _allTransactions,
      _currentQuery,
      _currentSortField,
      _isAscending,
    );

    emit(TransactionStateWithFilteredTransactions(
      allTransactions: _allTransactions,
      filteredTransactions: filtered,
    ));
  }

  List<Transaction> _sortAndFilter(
    List<Transaction> transactions,
    String query,
    String sortField,
    bool ascending,
  ) {
    final lowerQuery = query.toLowerCase();
    List<Transaction> filtered = transactions
        .where((transaction) =>
            (transaction.customerName?.toLowerCase().contains(lowerQuery) ??
                false) ||
            (transaction.serviceName?.toLowerCase().contains(lowerQuery) ??
                false) ||
            (transaction.description?.toLowerCase().contains(lowerQuery) ??
                false))
        .toList();

    filtered.sort((a, b) {
      int result;

      switch (sortField) {
        case 'customerName':
          result = (a.customerName ?? '').compareTo(b.customerName ?? '');
          break;
        case 'serviceName':
          result = (a.serviceName ?? '').compareTo(b.serviceName ?? '');
          break;
        case 'amount':
          result = (a.amount ?? 0).compareTo(b.amount ?? 0);
          break;
        case 'transactionStatus':
          result = (a.transactionStatus?.value ?? '')
              .compareTo(b.transactionStatus?.value ?? '');
          break;
        case 'paymentStatus':
          result = (a.paymentStatus?.value ?? '')
              .compareTo(b.paymentStatus?.value ?? '');
          break;
        case 'startDate':
          result = (a.startDate ?? DateTime.now())
              .compareTo(b.startDate ?? DateTime.now());
          break;
        case 'endDate':
          result = (a.endDate ?? DateTime.now())
              .compareTo(b.endDate ?? DateTime.now());
          break;
        case 'createdAt':
          result = (a.createdAt ?? DateTime.now())
              .compareTo(b.createdAt ?? DateTime.now());
          break;
        default:
          result = (a.createdAt ?? DateTime.now())
              .compareTo(b.createdAt ?? DateTime.now());
      }

      return ascending ? result : -result;
    });

    return filtered;
  }
}
