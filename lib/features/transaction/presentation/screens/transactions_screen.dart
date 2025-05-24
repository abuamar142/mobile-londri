import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/textstyle/app_colors.dart';
import '../../../../config/textstyle/app_sizes.dart';
import '../../../../config/textstyle/app_textstyle.dart';
import '../../../../core/utils/show_snackbar.dart';
import '../../../../core/widgets/widget_app_bar.dart';
import '../../../../core/widgets/widget_empty_list.dart';
import '../../../../core/widgets/widget_error.dart';
import '../../../../core/widgets/widget_loading.dart';
import '../../../../core/widgets/widget_search_bar.dart';
import '../../../../injection_container.dart';
import '../../../../src/generated/i18n/app_localizations.dart';
import '../../../auth/domain/entities/role_manager.dart';
import '../../domain/entities/transaction.dart';
import '../bloc/transaction_bloc.dart';
import '../widgets/widget_restore_transaction.dart';
import '../widgets/widget_transaction_card.dart';
import 'manage_transaction_screen.dart';

void pushTransactions(BuildContext context) {
  context.pushNamed('transactions');
}

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  late final TransactionBloc _transactionBloc;

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

  void _getTransactions() {
    _transactionBloc.add(TransactionEventGetTransactions());
  }

  @override
  Widget build(BuildContext context) {
    final appText = AppLocalizations.of(context)!;

    return BlocProvider.value(
      value: _transactionBloc,
      child: BlocListener<TransactionBloc, TransactionState>(
        listener: (context, state) {
          if (state is TransactionStateFailure) {
            showSnackbar(context, state.message);
          } else if (state is TransactionStateSuccessRestoreTransaction) {
            showSnackbar(context, 'Transaction restored successfully');
          }
        },
        child: Scaffold(
          appBar: WidgetAppBar(
            label: appText.transaction_screen_title,
          ),
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                left: AppSizes.size16,
                right: AppSizes.size16,
              ),
              child: Column(
                children: [
                  _buildHeader(appText, context),
                  AppSizes.spaceHeight16,
                  Expanded(
                    child: _buildTransactionList(appText),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton:
              RoleManager.hasPermission(Permission.manageTransactions)
                  ? FloatingActionButton(
                      onPressed: () async {
                        final result = await pushAddTransaction(context);
                        if (result == true) {
                          _getTransactions();
                        }
                      },
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                    )
                  : null,
        ),
      ),
    );
  }

  Row _buildHeader(AppLocalizations appText, BuildContext context) {
    return Row(
      children: [
        WidgetSearchBar(
          controller: _searchController,
          hintText: appText.transaction_search_hint,
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
        ),
        AppSizes.spaceWidth8,
        IconButton(
          icon: Icon(Icons.sort, size: AppSizes.size24),
          onPressed: () => _showSortOptions(context),
        ),
      ],
    );
  }

  Widget _buildTransactionList(AppLocalizations appText) {
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
              emptyMessage: appText.transaction_empty_message,
              onRefresh: _getTransactions,
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              _getTransactions();
            },
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
                        context,
                        transaction.id!,
                      );

                      if (result == true) {
                        _getTransactions();
                      }
                    } else {
                      showSnackbar(
                        context,
                        appText.transaction_deleted_message,
                      );
                    }
                  },
                  onLongPress: () {
                    if (!isDeleted) {
                      if (RoleManager.hasPermission(
                          Permission.manageTransactions)) {
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
            emptyMessage: appText.transaction_empty_message,
            onRefresh: _getTransactions,
          );
        }
      },
    );
  }

  void _showSortOptions(BuildContext context) {
    final blocState = _transactionBloc.state;
    String currentSortField = 'createdAt';
    bool isAscending = false;

    if (blocState is TransactionStateWithFilteredTransactions) {
      currentSortField = _transactionBloc.currentSortField;
      isAscending = _transactionBloc.isAscending;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.size16),
        ),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: AppSizes.size16,
              left: AppSizes.size16,
              right: AppSizes.size16,
            ),
            child: Row(
              children: [
                Text(
                  AppLocalizations.of(context)!.sort_text,
                  style: AppTextStyle.heading3.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  isAscending
                      ? AppLocalizations.of(context)!.sort_asc
                      : AppLocalizations.of(context)!.sort_desc,
                  style: AppTextStyle.body1.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(thickness: 1),
          Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.3,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildSortOption(
                    context: context,
                    title: 'Customer Name',
                    isSelected: currentSortField == 'customerName',
                    field: 'customerName',
                    isAscending: isAscending,
                  ),
                  _buildSortOption(
                    context: context,
                    title: 'Service Name',
                    isSelected: currentSortField == 'serviceName',
                    field: 'serviceName',
                    isAscending: isAscending,
                  ),
                  _buildSortOption(
                    context: context,
                    title: 'Amount',
                    isSelected: currentSortField == 'amount',
                    field: 'amount',
                    isAscending: isAscending,
                  ),
                  _buildSortOption(
                    context: context,
                    title: 'Transaction Status',
                    isSelected: currentSortField == 'transactionStatus',
                    field: 'transactionStatus',
                    isAscending: isAscending,
                  ),
                  _buildSortOption(
                    context: context,
                    title: 'Payment Status',
                    isSelected: currentSortField == 'paymentStatus',
                    field: 'paymentStatus',
                    isAscending: isAscending,
                  ),
                  _buildSortOption(
                    context: context,
                    title: 'Start Date',
                    isSelected: currentSortField == 'startDate',
                    field: 'startDate',
                    isAscending: isAscending,
                  ),
                  _buildSortOption(
                    context: context,
                    title: 'End Date',
                    isSelected: currentSortField == 'endDate',
                    field: 'endDate',
                    isAscending: isAscending,
                  ),
                  _buildSortOption(
                    context: context,
                    title: 'Created Date',
                    isSelected: currentSortField == 'createdAt',
                    field: 'createdAt',
                    isAscending: isAscending,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortOption({
    required BuildContext context,
    required String title,
    required bool isSelected,
    required String field,
    required bool isAscending,
  }) {
    return ListTile(
      title: Text(
        title,
        style: isSelected
            ? AppTextStyle.body1.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              )
            : AppTextStyle.body1,
      ),
      trailing: isSelected
          ? Icon(
              isAscending ? Icons.arrow_upward : Icons.arrow_downward,
              color: AppColors.primary,
            )
          : null,
      onTap: () {
        bool newAscending = isSelected ? !isAscending : true;
        _transactionBloc.add(
          TransactionEventSortTransactions(
            sortBy: field,
            ascending: newAscending,
          ),
        );
        Navigator.pop(context);
      },
    );
  }
}
