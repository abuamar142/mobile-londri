import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/payment_status.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_status.dart';
import '../../domain/usecases/transaction_create_transaction.dart';
import '../../domain/usecases/transaction_delete_transaction.dart';
import '../../domain/usecases/transaction_get_transaction_by_id.dart';
import '../../domain/usecases/transaction_get_transactions.dart';
import '../../domain/usecases/transaction_hard_delete_transaction.dart';
import '../../domain/usecases/transaction_restore_transaction.dart';
import '../../domain/usecases/transaction_update_payment_status.dart';
import '../../domain/usecases/transaction_update_transaction.dart';
import '../../domain/usecases/transaction_update_transaction_status.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionGetTransactions transactionGetTransactions;
  final TransactionGetTransactionById transactionGetTransactionById;
  final TransactionCreateTransaction transactionCreateTransaction;
  final TransactionUpdateTransaction transactionUpdateTransaction;
  final TransactionDeleteTransaction transactionDeleteTransaction;
  final TransactionHardDeleteTransaction transactionHardDeleteTransaction;
  final TransactionRestoreTransaction transactionRestoreTransaction;
  final TransactionUpdateTransactionStatus transactionUpdateTransactionStatus;
  final TransactionUpdatePaymentStatus transactionUpdatePaymentStatus;

  late List<Transaction> _allTransactions = [];
  String _currentQuery = '';
  String _currentSortField = 'createdAt';
  bool _isAscending = false;
  TransactionStatus? _selectedStatus;
  bool? _isIncludeInactive = false;

  int _currentTabIndex = 2;
  String _currentTabName = 'Active';

  String get currentSortField => _currentSortField;
  bool get isAscending => _isAscending;
  TransactionStatus? get selectedStatus => _selectedStatus;
  bool? get includeInactive => _isIncludeInactive;
  int get currentTabIndex => _currentTabIndex;
  String get currentTabName => _currentTabName;

  TransactionBloc({
    required this.transactionGetTransactions,
    required this.transactionGetTransactionById,
    required this.transactionCreateTransaction,
    required this.transactionUpdateTransaction,
    required this.transactionDeleteTransaction,
    required this.transactionHardDeleteTransaction,
    required this.transactionRestoreTransaction,
    required this.transactionUpdateTransactionStatus,
    required this.transactionUpdatePaymentStatus,
  }) : super(TransactionStateInitial()) {
    on<TransactionEventGetTransactions>(_onTransactionEventGetTransactions);
    on<TransactionEventGetTransactionById>(_onTransactionEventGetTransactionById);
    on<TransactionEventCreateTransaction>(_onTransactionEventCreateTransaction);
    on<TransactionEventUpdateTransaction>(_onTransactionEventUpdateTransaction);
    on<TransactionEventDeleteTransaction>(_onTransactionEventDeleteTransaction);
    on<TransactionEventHardDeleteTransaction>(_onTransactionEventHardDeleteTransaction);
    on<TransactionEventRestoreTransaction>(_onTransactionEventRestoreTransaction);
    on<TransactionEventFilter>(_onTransactionEventFilter);
    on<TransactionEventUpdateTransactionStatus>(_onTransactionEventUpdateTransactionStatus);
    on<TransactionEventUpdatePaymentStatus>(_onTransactionEventUpdatePaymentStatus);
  }

  Future<void> _onTransactionEventGetTransactions(
    TransactionEventGetTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionStateLoading());

    Either<Failure, List<Transaction>> result = await transactionGetTransactions();

    result.fold((left) {
      emit(TransactionStateFailure(message: left.message));
    }, (right) {
      _allTransactions = right;

      add(TransactionEventFilter(
        searchQuery: _currentQuery,
        sortBy: _currentSortField,
        ascending: _isAscending,
        transactionStatus: _selectedStatus,
        isIncludeInactive: _isIncludeInactive,
        tabIndex: _currentTabIndex,
        tabName: _currentTabName,
      ));
    });
  }

  Future<void> _onTransactionEventGetTransactionById(
    TransactionEventGetTransactionById event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionStateLoading());

    Either<Failure, Transaction> result = await transactionGetTransactionById(event.id);

    result.fold((left) {
      emit(TransactionStateFailure(message: left.message));
    }, (right) {
      emit(TransactionStateSuccessGetTransactionById(transaction: right));
    });
  }

  Future<void> _onTransactionEventCreateTransaction(
    TransactionEventCreateTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionStateLoading());

    Either<Failure, void> result = await transactionCreateTransaction(event.transaction);

    result.fold((left) {
      emit(TransactionStateFailure(message: left.message));
    }, (right) {
      emit(TransactionStateSuccessCreateTransaction());
    });
  }

  Future<void> _onTransactionEventUpdateTransaction(
    TransactionEventUpdateTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionStateLoading());

    Either<Failure, void> result = await transactionUpdateTransaction(event.transaction);

    result.fold((left) {
      emit(TransactionStateFailure(message: left.message));
    }, (right) {
      emit(TransactionStateSuccessUpdateTransaction());
    });
  }

  Future<void> _onTransactionEventDeleteTransaction(
    TransactionEventDeleteTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionStateLoading());

    Either<Failure, void> result = await transactionDeleteTransaction(event.id);

    result.fold((left) {
      emit(TransactionStateFailure(message: left.message));
    }, (right) {
      emit(TransactionStateSuccessDeleteTransaction());
    });
  }

  Future<void> _onTransactionEventHardDeleteTransaction(
    TransactionEventHardDeleteTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionStateLoading());

    Either<Failure, void> result = await transactionHardDeleteTransaction(event.id);

    result.fold((left) {
      emit(TransactionStateFailure(message: left.message));
    }, (right) {
      emit(TransactionStateSuccessDeleteTransaction());
    });
  }

  Future<void> _onTransactionEventRestoreTransaction(
    TransactionEventRestoreTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionStateLoading());

    Either<Failure, void> result = await transactionRestoreTransaction(event.id);

    result.fold((left) {
      emit(TransactionStateFailure(message: left.message));
    }, (right) {
      emit(TransactionStateSuccessRestoreTransaction());
      add(TransactionEventGetTransactions());
    });
  }

  Future<void> _onTransactionEventFilter(
    TransactionEventFilter event,
    Emitter<TransactionState> emit,
  ) async {
    // Update filter parameters if provided
    if (event.searchQuery != null) {
      _currentQuery = event.searchQuery!;
    }
    if (event.sortBy != null) {
      _currentSortField = event.sortBy!;
    }
    if (event.ascending != null) {
      _isAscending = event.ascending!;
    }
    if (event.transactionStatus != null || event.isIncludeInactive != null) {
      _selectedStatus = event.transactionStatus;
      _isIncludeInactive = event.isIncludeInactive;
    }
    if (event.tabIndex != null) {
      _currentTabIndex = event.tabIndex!;
    }
    if (event.tabName != null) {
      _currentTabName = event.tabName!;
    }

    _isIncludeInactive = event.isIncludeInactive;

    _emitFilteredState(emit);
  }

  void _emitFilteredState(Emitter<TransactionState> emit) {
    final filteredTransactions = _applyAllFilters(_allTransactions);

    emit(TransactionStateWithFilteredTransactions(
      allTransactions: _allTransactions,
      filteredTransactions: filteredTransactions,
      searchQuery: _currentQuery,
      sortField: _currentSortField,
      isAscending: _isAscending,
      selectedStatus: _selectedStatus,
      isIncludeInactive: _isIncludeInactive,
      currentTabIndex: _currentTabIndex,
      tabName: _currentTabName,
    ));
  }

  List<Transaction> _applyAllFilters(List<Transaction> transactions) {
    List<Transaction> filtered = List.from(transactions);

    // Filter by active/inactive status
    if (_isIncludeInactive == true) {
      filtered = filtered.where((transaction) => transaction.isDeleted == true).toList();
    } else if (_isIncludeInactive == false) {
      filtered = filtered.where((transaction) => transaction.isDeleted == false).toList();
    }

    // Filter by transaction status (only apply if we have a specific status)
    if (_selectedStatus != null) {
      filtered = filtered.where((transaction) => transaction.transactionStatus == _selectedStatus).toList();
    }

    // Apply search filter
    if (_currentQuery.isNotEmpty) {
      filtered = filtered.where((transaction) {
        final customerName = transaction.customerName?.toLowerCase() ?? '';
        final serviceName = transaction.serviceName?.toLowerCase() ?? '';
        final transactionId = transaction.id?.toLowerCase() ?? '';
        final description = transaction.description?.toLowerCase() ?? '';
        final query = _currentQuery.toLowerCase();

        return customerName.contains(query) || serviceName.contains(query) || transactionId.contains(query) || description.contains(query);
      }).toList();
    }

    // Apply sorting
    return _applySorting(filtered);
  }

  List<Transaction> _applySorting(List<Transaction> transactions) {
    List<Transaction> sorted = List.from(transactions);

    sorted.sort((a, b) {
      int result;

      switch (_currentSortField) {
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
          result = (a.transactionStatus?.value ?? '').compareTo(b.transactionStatus?.value ?? '');
          break;
        case 'paymentStatus':
          result = (a.paymentStatus?.value ?? '').compareTo(b.paymentStatus?.value ?? '');
          break;
        case 'startDate':
          result = (a.startDate ?? DateTime.now()).compareTo(b.startDate ?? DateTime.now());
          break;
        case 'endDate':
          result = (a.endDate ?? DateTime.now()).compareTo(b.endDate ?? DateTime.now());
          break;
        case 'createdAt':
          result = (a.createdAt ?? DateTime.now()).compareTo(b.createdAt ?? DateTime.now());
          break;
        default:
          result = (a.createdAt ?? DateTime.now()).compareTo(b.createdAt ?? DateTime.now());
      }

      return _isAscending ? result : -result;
    });

    return sorted;
  }

  void _onTransactionEventUpdateTransactionStatus(
    TransactionEventUpdateTransactionStatus event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionStateLoading());

    Either<Failure, void> result = await transactionUpdateTransactionStatus(event.id, event.status);

    result.fold((left) {
      emit(TransactionStateFailure(message: left.message));
    }, (right) {
      emit(TransactionStateSuccessUpdateTransaction());
    });
  }

  void _onTransactionEventUpdatePaymentStatus(
    TransactionEventUpdatePaymentStatus event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionStateLoading());

    Either<Failure, void> result = await transactionUpdatePaymentStatus(event.id, event.status);

    result.fold((left) {
      emit(TransactionStateFailure(message: left.message));
    }, (right) {
      emit(TransactionStateSuccessUpdateTransaction());
    });
  }
}
