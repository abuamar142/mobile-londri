import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../config/textstyle/app_colors.dart';
import '../../../../config/textstyle/app_sizes.dart';
import '../../../../config/textstyle/app_textstyle.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/widgets/widget_app_bar.dart';
import '../../../../core/widgets/widget_dropdown_bottom_sheet.dart';
import '../../../../core/widgets/widget_dropdown_bottom_sheet_item.dart';
import '../../../../core/widgets/widget_empty_list.dart';
import '../../../../core/widgets/widget_error.dart';
import '../../../../core/widgets/widget_loading.dart';
import '../../../../core/widgets/widget_search_bar.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/transaction_status.dart';
import '../bloc/transaction_bloc.dart';
import '../widgets/widget_restore_transaction.dart';
import '../widgets/widget_transaction_card.dart';
import 'manage_transaction_screen.dart';

Future<bool> pushTransactions({
  required BuildContext context,
  String? searchQuery,
  String? tabName,
}) async {
  await context.pushNamed(
    RouteNames.transactions,
    queryParameters: {
      'search': searchQuery,
      'tabName': tabName,
    },
  );
  return true;
}

class TransactionsScreen extends StatefulWidget {
  final String? searchQuery;
  final String? tabName;

  const TransactionsScreen({
    super.key,
    this.searchQuery,
    this.tabName,
  });

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> with SingleTickerProviderStateMixin {
  late final TransactionBloc _transactionBloc;
  late final TabController _tabController;

  final TextEditingController _searchController = TextEditingController();

  List<Tab>? _tabs;

  final List<String> _tabNames = [
    'Inactive',
    'All',
    'Active',
    'On Progress',
    'Ready for Pickup',
    'Picked Up',
  ];

  void _getTransactions() => _transactionBloc.add(TransactionEventGetTransactions());

  @override
  void initState() {
    super.initState();
    _transactionBloc = serviceLocator<TransactionBloc>();
    _getTransactions();

    if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
      _searchController.text = widget.searchQuery!;
      _transactionBloc.add(
        TransactionEventFilter(
          searchQuery: widget.searchQuery!,
          isIncludeInactive: false,
        ),
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Initialize tabs when context is available
    if (_tabs == null) {
      _tabs = [
        Tab(text: context.appText.transaction_screen_tab_inactive),
        Tab(text: context.appText.transaction_screen_tab_all),
        Tab(text: context.appText.transaction_screen_tab_active),
        Tab(text: context.appText.transaction_screen_tab_on_progress),
        Tab(text: context.appText.transaction_screen_tab_ready_for_pickup),
        Tab(text: context.appText.transaction_screen_tab_picked_up),
      ];

      final int tabIndex = _tabNames.indexOf(widget.tabName ?? 'Active');

      // Initialize TabController after tabs are created
      _tabController = TabController(
        length: _tabs!.length,
        vsync: this,
        initialIndex: tabIndex >= 0 && tabIndex < _tabs!.length ? tabIndex : 2, // Default to 'Active' if invalid index
      );

      _tabController.addListener(_onTabChanged);

      // Set initial filter to show active transactions
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _transactionBloc.add(TransactionEventGetTransactions());
      });
    }
  }

  void _onTabChanged() {
    _applyFilterForCurrentTab();
  }

  void _applyFilterForCurrentTab({String? sortField, bool? ascending}) {
    final tabIndex = _tabController.index;
    final tabName = _tabNames[tabIndex];
    final searchQuery = _searchController.text;

    // Gunakan parameter yang diberikan atau nilai saat ini dari bloc
    final currentSortField = sortField ?? _transactionBloc.currentSortField;
    final isAscending = ascending ?? _transactionBloc.isAscending;

    switch (tabIndex) {
      case 0: // Inactive
        _transactionBloc.add(TransactionEventFilter(
          isIncludeInactive: true,
          transactionStatus: null,
          tabIndex: tabIndex,
          tabName: tabName,
          searchQuery: searchQuery.isNotEmpty ? searchQuery : null,
          sortBy: currentSortField,
          ascending: isAscending,
        ));
        break;
      case 1: // All
        _transactionBloc.add(TransactionEventFilter(
          isIncludeInactive: null,
          transactionStatus: null,
          tabIndex: tabIndex,
          tabName: tabName,
          searchQuery: searchQuery.isNotEmpty ? searchQuery : null,
          sortBy: currentSortField,
          ascending: isAscending,
        ));
        break;
      case 2: // Active
        _transactionBloc.add(TransactionEventFilter(
          isIncludeInactive: false,
          transactionStatus: null,
          tabIndex: tabIndex,
          tabName: tabName,
          searchQuery: searchQuery.isNotEmpty ? searchQuery : null,
          sortBy: currentSortField,
          ascending: isAscending,
        ));
        break;
      case 3: // On Progress
        _transactionBloc.add(TransactionEventFilter(
          isIncludeInactive: false,
          transactionStatus: TransactionStatus.onProgress,
          tabIndex: tabIndex,
          tabName: tabName,
          searchQuery: searchQuery.isNotEmpty ? searchQuery : null,
          sortBy: currentSortField,
          ascending: isAscending,
        ));
        break;
      case 4: // Ready for Pickup
        _transactionBloc.add(TransactionEventFilter(
          isIncludeInactive: false,
          transactionStatus: TransactionStatus.readyForPickup,
          tabIndex: tabIndex,
          tabName: tabName,
          searchQuery: searchQuery.isNotEmpty ? searchQuery : null,
          sortBy: currentSortField,
          ascending: isAscending,
        ));
        break;
      case 5: // Picked Up
        _transactionBloc.add(TransactionEventFilter(
          isIncludeInactive: false,
          transactionStatus: TransactionStatus.pickedUp,
          tabIndex: tabIndex,
          tabName: tabName,
          searchQuery: searchQuery.isNotEmpty ? searchQuery : null,
          sortBy: currentSortField,
          ascending: isAscending,
        ));
        break;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_tabs == null) {
      return const Scaffold(
        body: WidgetLoading(
          usingPadding: true,
        ),
      );
    }

    return BlocProvider.value(
      value: _transactionBloc,
      child: BlocListener<TransactionBloc, TransactionState>(
        listener: (context, state) {
          if (state is TransactionStateFailure) {
            context.showSnackbar(state.message);
          } else if (state is TransactionStateSuccessRestoreTransaction) {
            context.showSnackbar(context.appText.transaction_restore_success_message);

            // Change the tab to "Active" after restoring a transaction
            _tabController.index = 2;
          }
        },
        child: Scaffold(
          appBar: WidgetAppBar(
            title: context.appText.transaction_screen_title,
            action: IconButton(
              icon: Icon(Icons.sort),
              onPressed: _showSortOptions,
              tooltip: context.appText.sort_text,
            ),
            bottom: TabBar(
              controller: _tabController,
              tabs: _tabs!,
              isScrollable: true,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.gray,
              labelStyle: AppTextStyle.body2.copyWith(fontWeight: FontWeight.bold),
              unselectedLabelStyle: AppTextStyle.body2,
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Search bar
                Padding(
                  padding: EdgeInsets.all(AppSizes.size16),
                  child: Row(
                    children: [
                      WidgetSearchBar(
                        controller: _searchController,
                        hintText: context.appText.transaction_search_hint,
                        onChanged: (value) {
                          setState(() {
                            _transactionBloc.add(TransactionEventFilter(
                              searchQuery: value,
                              preserveCurrentFilters: true,
                            ));
                          });
                        },
                        onClear: () {
                          setState(() {
                            _searchController.clear();
                            _transactionBloc.add(const TransactionEventFilter(
                              searchQuery: '',
                              preserveCurrentFilters: true,
                            ));
                          });
                        },
                      ),
                    ],
                  ),
                ),

                // Transaction list
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: List.generate(
                      _tabs!.length,
                      (index) => RefreshIndicator(
                        onRefresh: () async => _getTransactions(),
                        child: _buildTransactionList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final result = await pushAddTransaction(context: context);
              if (result == true) {
                _getTransactions();
              }
            },
            child: Icon(Icons.add),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionList() {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        if (state is TransactionStateLoading) {
          return const WidgetLoading(usingPadding: true);
        } else if (state is TransactionStateFailure) {
          return WidgetError(message: state.message);
        } else if (state is TransactionStateWithFilteredTransactions) {
          final filteredTransactions = state.filteredTransactions;

          if (filteredTransactions.isEmpty) {
            return WidgetEmptyList(
              emptyMessage: _getEmptyMessageForTab(state.currentTabIndex),
              onRefresh: _getTransactions,
            );
          }

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSizes.size16),
            child: ListView.separated(
              itemCount: filteredTransactions.length,
              separatorBuilder: (_, __) => AppSizes.spaceHeight8,
              itemBuilder: (context, index) {
                final transaction = filteredTransactions[index];
                final isDeleted = transaction.isDeleted == true;

                return WidgetTransactionCard(
                  transaction: transaction,
                  onTap: () async {
                    if (!isDeleted && !state.canRestoreTransactions) {
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
                    if (_tabController.index == 1) {
                      context.showSnackbar(context.appText.transaction_deleted_on_all_tab);
                    } else if (isDeleted && state.canRestoreTransactions) {
                      restoreTransaction(
                        context: context,
                        transaction: transaction,
                        transactionBloc: _transactionBloc,
                      );
                    }
                  },
                );
              },
            ),
          );
        } else {
          return WidgetEmptyList(
            emptyMessage: _getEmptyMessageForTab(_tabController.index),
            onRefresh: _getTransactions,
          );
        }
      },
    );
  }

  String _getEmptyMessageForTab(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return context.appText.transaction_empty_inactive_message;
      case 1:
        return context.appText.transaction_empty_message;
      case 2:
        return context.appText.transaction_empty_active_message;
      case 3:
        return context.appText.transaction_empty_on_progress_message;
      case 4:
        return context.appText.transaction_empty_ready_for_pickup_message;
      case 5:
        return context.appText.transaction_empty_picked_up_message;
      default:
        return context.appText.transaction_empty_message;
    }
  }

  void _showSortOptions() {
    return showDropdownBottomSheet(
      context: context,
      title: context.appText.sort_text,
      isAscending: _transactionBloc.isAscending,
      items: [
        WidgetDropdownBottomSheetItem(
          title: context.appText.sort_by_customer_name,
          leadingIcon: Icons.person,
          isSelected: _transactionBloc.currentSortField == 'customerName',
          onTap: () {
            _applySortWithCurrentTabFilter('customerName');
          },
        ),
        WidgetDropdownBottomSheetItem(
          title: context.appText.sort_by_service_name,
          leadingIcon: Icons.local_laundry_service,
          isSelected: _transactionBloc.currentSortField == 'serviceName',
          onTap: () {
            _applySortWithCurrentTabFilter('serviceName');
          },
        ),
        WidgetDropdownBottomSheetItem(
          title: context.appText.sort_by_amount,
          leadingIcon: Icons.attach_money,
          isSelected: _transactionBloc.currentSortField == 'amount',
          onTap: () {
            _applySortWithCurrentTabFilter('amount');
          },
        ),
        WidgetDropdownBottomSheetItem(
          title: context.appText.sort_by_payment_status,
          leadingIcon: Icons.payment,
          isSelected: _transactionBloc.currentSortField == 'paymentStatus',
          onTap: () {
            _applySortWithCurrentTabFilter('paymentStatus');
          },
        ),
        WidgetDropdownBottomSheetItem(
          title: context.appText.sort_by_start_date,
          leadingIcon: Icons.date_range,
          isSelected: _transactionBloc.currentSortField == 'startDate',
          onTap: () {
            _applySortWithCurrentTabFilter('startDate');
          },
        ),
        WidgetDropdownBottomSheetItem(
          title: context.appText.sort_by_end_date,
          leadingIcon: Icons.date_range,
          isSelected: _transactionBloc.currentSortField == 'endDate',
          onTap: () {
            _applySortWithCurrentTabFilter('endDate');
          },
        ),
        WidgetDropdownBottomSheetItem(
          title: context.appText.sort_by_created_at,
          leadingIcon: Icons.date_range,
          isSelected: _transactionBloc.currentSortField == 'createdAt',
          onTap: () {
            _applySortWithCurrentTabFilter('createdAt');
          },
        ),
      ],
    );
  }

  void _applySortWithCurrentTabFilter(String sortField) {
    _applyFilterForCurrentTab(
      sortField: sortField,
      ascending: !_transactionBloc.isAscending,
    );
  }
}
