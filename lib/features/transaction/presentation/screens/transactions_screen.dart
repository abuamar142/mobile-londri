import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../config/textstyle/app_colors.dart';
import '../../../../config/textstyle/app_sizes.dart';
import '../../../../config/textstyle/app_textstyle.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../../core/utils/show_snackbar.dart';
import '../../../../core/widgets/widget_empty_list.dart';
import '../../../../core/widgets/widget_error.dart';
import '../../../../core/widgets/widget_loading.dart';
import '../../../../core/widgets/widget_search_bar.dart';
import '../../../../injection_container.dart';
import '../../../../src/generated/i18n/app_localizations.dart';
import '../../../auth/domain/entities/role_manager.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_status.dart';
import '../bloc/transaction_bloc.dart';
import '../widgets/widget_activate_transaction.dart';
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
          } else if (state is TransactionStateSuccessActivateTransaction) {
            showSnackbar(context, 'Transaction activated successfully');
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              appText.transaction_screen_title,
              style: AppTextStyle.heading3,
            ),
            centerTitle: true,
          ),
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                left: AppSizes.size16,
                right: AppSizes.size16,
                bottom: AppSizes.size16,
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
                        final result =
                            await context.pushNamed('add-transaction');
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
        Expanded(
          child: WidgetSearchBar(
            controller: _searchController,
            hintText: 'Cari transaksi',
            onChanged: (value) {
              _transactionBloc.add(
                TransactionEventSearchTransaction(query: value),
              );
            },
            onClear: () {
              _transactionBloc.add(
                TransactionEventSearchTransaction(query: ''),
              );
            },
          ),
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
                final isActive = transaction.isActive ?? false;

                return ListTile(
                  title: Text(
                    transaction.customerName ?? 'No Customer',
                    style: AppTextStyle.tileTitle,
                  ),
                  subtitle: _buildSubtitle(transaction, appText),
                  leading: Icon(isActive ? Icons.receipt : Icons.receipt_long),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        (transaction.amount ?? 0).formatNumber(),
                        style: AppTextStyle.tileTrailing,
                      ),
                      SizedBox(
                        height: 2,
                      ),
                      TransactionStatusBadge(
                          status: transaction.transactionStatus ??
                              TransactionStatus.onProgress),
                    ],
                  ),
                  tileColor: isActive
                      ? null
                      : AppColors.gray.withValues(
                          alpha: 0.1,
                        ),
                  onTap: () async {
                    if (isActive) {
                      final result = await context.pushNamed(
                        'view-transaction',
                        pathParameters: {'id': transaction.id!.toString()},
                      );

                      if (result == true) {
                        _getTransactions();
                      }
                    } else {
                      showSnackbar(context, 'Transaction is not active');
                    }
                  },
                  onLongPress: () {
                    if (isActive) {
                      showSnackbar(context, 'Transaction is active');
                    } else {
                      if (RoleManager.hasPermission(
                          Permission.manageTransactions)) {
                        activateTransaction(
                          context: context,
                          transaction: transaction,
                          transactionBloc: _transactionBloc,
                        );
                      } else {
                        showSnackbar(
                          context,
                          'Please ask a super admin to activate this transaction.',
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

  Widget _buildSubtitle(Transaction transaction, AppLocalizations appText) {
    final serviceName = transaction.serviceName ?? 'No Service';

    final dateFormat = DateFormat('dd MMM yyyy');
    final startDate = transaction.startDate != null
        ? dateFormat.format(transaction.startDate!)
        : '?';
    final endDate = transaction.endDate != null
        ? dateFormat.format(transaction.endDate!)
        : '?';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          serviceName,
          style: AppTextStyle.tileSubtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        AppSizes.spaceHeight4,
        Row(
          children: [
            Icon(
              Icons.date_range,
              size: AppSizes.size12,
              color: AppColors.gray,
            ),
            AppSizes.spaceWidth8,
            Text(
              '$startDate - $endDate',
              style: AppTextStyle.tileSubtitle.copyWith(
                fontSize: AppSizes.size12,
                color: AppColors.gray,
              ),
            ),
          ],
        ),
      ],
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
