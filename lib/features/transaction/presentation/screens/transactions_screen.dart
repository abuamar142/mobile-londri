import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../config/textstyle/app_sizes.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/widgets/widget_dropdown_bottom_sheet.dart';
import '../../../../core/widgets/widget_dropdown_bottom_sheet_item.dart';
import '../../../../core/widgets/widget_empty_list.dart';
import '../../../../core/widgets/widget_error.dart';
import '../../../../core/widgets/widget_loading.dart';
import '../../../../core/widgets/widget_scaffold_list.dart';
import '../../../../injection_container.dart';
import '../../../auth/domain/entities/role_manager.dart';
import '../../domain/entities/transaction.dart';
import '../bloc/transaction_bloc.dart';
import '../widgets/widget_restore_transaction.dart';
import '../widgets/widget_transaction_card.dart';
import 'manage_transaction_screen.dart';

void pushTransactions({
  required BuildContext context,
}) {
  context.pushNamed(RouteNames.transactions);
}

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  late final TransactionBloc _transactionBloc;

  final TextEditingController _searchController = TextEditingController();

  void _getTransactions() => _transactionBloc.add(TransactionEventGetTransactions());

  @override
  void initState() {
    super.initState();

    _transactionBloc = serviceLocator<TransactionBloc>();
    _getTransactions();
  }

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _transactionBloc,
      child: BlocListener<TransactionBloc, TransactionState>(
        listener: (context, state) {
          if (state is TransactionStateFailure) {
            context.showSnackbar(state.message);
          } else if (state is TransactionStateSuccessRestoreTransaction) {
            context.showSnackbar(context.appText.transaction_restore_success_message);
          }
        },
        child: WidgetScaffoldList(
          title: context.appText.transaction_screen_title,
          searchController: _searchController,
          searchHint: context.appText.transaction_search_hint,
          onChanged: (value) {
            setState(() {
              _transactionBloc.add(
                TransactionEventSearchTransaction(query: value),
              );
            });
          },
          onClear: () {
            setState(() {
              _transactionBloc.add(
                TransactionEventSearchTransaction(query: ''),
              );
            });
          },
          onSortTap: _showSortOptions,
          buildListItems: _buildTransactionList(),
          onFloatingActionButtonPressed: () async {
            final result = await pushAddTransaction(
              context: context,
            );

            if (result == true) {
              _getTransactions();
            }
          },
        ),
      ),
    );
  }

  Widget _buildTransactionList() {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        if (state is TransactionStateLoading) {
          return WidgetLoading(usingPadding: true);
        } else if (state is TransactionStateFailure) {
          return WidgetError(message: state.message);
        } else if (state is TransactionStateWithFilteredTransactions) {
          List<Transaction> filteredTransactions = state.filteredTransactions;

          if (filteredTransactions.isEmpty) {
            return WidgetEmptyList(
              emptyMessage: context.appText.transaction_empty_message,
              onRefresh: _getTransactions,
            );
          }
          return RefreshIndicator(
            onRefresh: () async => _getTransactions(),
            child: ListView.separated(
              itemCount: filteredTransactions.length,
              separatorBuilder: (_, __) => AppSizes.spaceHeight8,
              itemBuilder: (context, index) {
                final transaction = filteredTransactions[index];
                final isDeleted = transaction.isDeleted ?? false;

                return WidgetTransactionCard(
                  transaction: transaction,
                  onTap: () async {
                    if (isDeleted) {
                      final result = await pushViewTransaction(
                        context: context,
                        transactionId: transaction.id!,
                      );

                      if (result == true) {
                        _getTransactions();
                      }
                    } else {
                      context.showSnackbar(context.appText.transaction_deleted_message);
                    }
                  },
                  onLongPress: () {
                    if (!isDeleted) {
                      if (RoleManager.hasPermission(Permission.manageTransactions)) {
                        restoreTransaction(
                          context: context,
                          transaction: transaction,
                          transactionBloc: _transactionBloc,
                        );
                      }
                    }
                  },
                );
              },
            ),
          );
        } else {
          return WidgetEmptyList(
            emptyMessage: context.appText.transaction_empty_message,
            onRefresh: _getTransactions,
          );
        }
      },
    );
  }

  void _showSortOptions() {
    return showDropdownBottomSheet(
      context: context,
      title: context.appText.sort_text,
      items: [
        WidgetDropdownBottomSheetItem(
          title: context.appText.sort_by_customer_name,
          leadingIcon: Icons.person,
          isSelected: _transactionBloc.currentSortField == 'customerName',
          onTap: () {
            _transactionBloc.add(
              TransactionEventSortTransactions(
                sortBy: 'customerName',
                ascending: !_transactionBloc.isAscending,
              ),
            );

            context.pop();
          },
        ),
        WidgetDropdownBottomSheetItem(
          title: context.appText.sort_by_service_name,
          leadingIcon: Icons.local_laundry_service,
          isSelected: _transactionBloc.currentSortField == 'serviceName',
          onTap: () {
            _transactionBloc.add(
              TransactionEventSortTransactions(
                sortBy: 'serviceName',
                ascending: !_transactionBloc.isAscending,
              ),
            );

            context.pop();
          },
        ),
        WidgetDropdownBottomSheetItem(
          title: context.appText.sort_by_amount,
          leadingIcon: Icons.attach_money,
          isSelected: _transactionBloc.currentSortField == 'amount',
          onTap: () {
            _transactionBloc.add(
              TransactionEventSortTransactions(
                sortBy: 'amount',
                ascending: !_transactionBloc.isAscending,
              ),
            );
            context.pop();
          },
        ),
        WidgetDropdownBottomSheetItem(
          title: context.appText.sort_by_payment_status,
          leadingIcon: Icons.payment,
          isSelected: _transactionBloc.currentSortField == 'paymentStatus',
          onTap: () {
            _transactionBloc.add(
              TransactionEventSortTransactions(
                sortBy: 'paymentStatus',
                ascending: !_transactionBloc.isAscending,
              ),
            );
            context.pop();
          },
        ),
        WidgetDropdownBottomSheetItem(
          title: context.appText.sort_by_start_date,
          leadingIcon: Icons.date_range,
          isSelected: _transactionBloc.currentSortField == 'startDate',
          onTap: () {
            _transactionBloc.add(
              TransactionEventSortTransactions(
                sortBy: 'startDate',
                ascending: !_transactionBloc.isAscending,
              ),
            );
            context.pop();
          },
        ),
        WidgetDropdownBottomSheetItem(
          title: context.appText.sort_by_end_date,
          leadingIcon: Icons.date_range,
          isSelected: _transactionBloc.currentSortField == 'endDate',
          onTap: () {
            _transactionBloc.add(
              TransactionEventSortTransactions(
                sortBy: 'endDate',
                ascending: !_transactionBloc.isAscending,
              ),
            );
            context.pop();
          },
        ),
        WidgetDropdownBottomSheetItem(
          title: context.appText.sort_by_created_at,
          leadingIcon: Icons.date_range,
          isSelected: _transactionBloc.currentSortField == 'createdAt',
          onTap: () {
            _transactionBloc.add(
              TransactionEventSortTransactions(
                sortBy: 'createdAt',
                ascending: !_transactionBloc.isAscending,
              ),
            );
            context.pop();
          },
        ),
      ],
    );
  }
}
