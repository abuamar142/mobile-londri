import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../config/textstyle/app_colors.dart';
import '../../../../config/textstyle/app_sizes.dart';
import '../../../../config/textstyle/app_textstyle.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/widgets/widget_empty_list.dart';
import '../../../../core/widgets/widget_error.dart';
import '../../../../core/widgets/widget_list_tile.dart';
import '../../../../core/widgets/widget_loading.dart';
import '../../../../core/widgets/widget_scaffold_list.dart';
import '../../../../injection_container.dart';
import '../../../../src/generated/i18n/app_localizations.dart';
import '../../domain/entities/customer.dart';
import '../bloc/customer_bloc.dart';
import '../widgets/widget_activate_customer.dart';
import 'manage_customer_screen.dart';

void pushCustomers({
  required BuildContext context,
}) {
  context.pushNamed(RouteNames.customers);
}

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  late final CustomerBloc _customerBloc;

  final TextEditingController _searchController = TextEditingController();

  void _getCustomers() => _customerBloc.add(CustomerEventGetCustomers());

  @override
  void initState() {
    super.initState();

    _customerBloc = serviceLocator<CustomerBloc>();
    _getCustomers();
  }

  @override
  void dispose() {
    _searchController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _customerBloc,
      child: BlocListener<CustomerBloc, CustomerState>(
        listener: (context, state) {
          if (state is CustomerStateFailure) {
            context.showSnackbar(state.message);
          } else if (state is CustomerStateSuccessActivateCustomer) {
            context.showSnackbar(context.appText.customer_activate_success_message);
          }
        },
        child: WidgetScaffoldList(
          title: context.appText.customer_screen_title,
          searchController: _searchController,
          searchHint: context.appText.customer_search_hint,
          onChanged: (value) {
            setState(() {
              _customerBloc.add(
                CustomerEventSearchCustomer(query: value),
              );
            });
          },
          onClear: () {
            setState(() {
              _customerBloc.add(
                CustomerEventSearchCustomer(query: ''),
              );
            });
          },
          onSortTap: () => _showSortOptions(),
          buildListItems: _buildCustomerList(),
          onFloatingActionButtonPressed: () async {
            final result = await pushAddCustomer(context: context);

            if (result == true) {
              _getCustomers();
            }
          },
        ),
      ),
    );
  }

  Widget _buildCustomerList() {
    return BlocBuilder<CustomerBloc, CustomerState>(
      builder: (context, state) {
        if (state is CustomerStateLoading) {
          return WidgetLoading(usingPadding: true);
        } else if (state is CustomerStateFailure) {
          return WidgetError(message: state.message);
        } else if (state is CustomerStateWithFilteredCustomers) {
          List<Customer> filteredCustomers = state.filteredCustomers;

          if (filteredCustomers.isEmpty) {
            return WidgetEmptyList(
              emptyMessage: context.appText.customer_empty_message,
              onRefresh: _getCustomers,
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _getCustomers(),
            child: ListView.separated(
              itemCount: filteredCustomers.length,
              separatorBuilder: (_, __) => AppSizes.spaceHeight8,
              itemBuilder: (context, index) {
                final customer = filteredCustomers[index];
                final isActive = customer.isActive ?? false;

                return WidgetListTile(
                  title: customer.name ?? '',
                  subtitle: _getCustomerSubtitle(customer),
                  trailing: (customer.phone != null && customer.phone!.isNotEmpty)
                      ? IconButton(
                          icon: Icon(
                            Icons.message,
                            color: AppColors.primary,
                          ),
                          onPressed: () => contactCustomer(customer.phone!),
                        )
                      : null,
                  leadingIcon: isActive ? customer.gender?.icon : Icons.person_off,
                  tileColor: isActive
                      ? null
                      : AppColors.gray.withValues(
                          alpha: 0.1,
                        ),
                  onTap: () async {
                    if (isActive) {
                      final result = await pushViewCustomer(
                        context: context,
                        customerId: customer.id!.toString(),
                      );

                      if (result == true) {
                        _getCustomers();
                      }
                    } else {
                      context.showSnackbar(context.appText.customer_info_activate);
                    }
                  },
                  onLongPress: () {
                    if (isActive) {
                      context.showSnackbar(context.appText.customer_info_active);
                    } else {
                      activateCustomer(
                        context: context,
                        customer: customer,
                        customerBloc: _customerBloc,
                      );
                    }
                  },
                );
              },
            ),
          );
        } else {
          return WidgetError(
            message: context.appText.customer_empty_message,
          );
        }
      },
    );
  }

  Widget _buildSortOption(
    String title,
    String field,
    String currentSortField,
    bool isAscending,
  ) {
    final bool isSelected = currentSortField == field;

    return ListTile(
      leading: Icon(
        isSelected ? (isAscending ? Icons.arrow_upward : Icons.arrow_downward) : Icons.sort,
        color: isSelected ? AppColors.primary : AppColors.gray,
      ),
      title: Text(
        title,
        style: AppTextStyle.body1.copyWith(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? AppColors.primary : AppColors.onSecondary,
        ),
      ),
      onTap: () {
        final newAscending = currentSortField == field ? !isAscending : true;

        _customerBloc.add(CustomerEventSortCustomers(
          sortBy: field,
          ascending: newAscending,
        ));

        context.pop();
      },
    );
  }

  String _getCustomerSubtitle(Customer customer) {
    final List<String> parts = [];

    if (customer.phone != null && customer.phone!.isNotEmpty) {
      parts.add(customer.phone!);
    }

    if (customer.description != null && customer.description!.isNotEmpty) {
      parts.add(customer.description!);
    }

    return parts.isEmpty ? '-' : parts.join(' • ');
  }

  void _showSortOptions() {
    final blocState = _customerBloc.state;
    String currentSortField = 'name';
    bool isAscending = true;

    if (blocState is CustomerStateWithFilteredCustomers) {
      currentSortField = _customerBloc.currentSortField;
      isAscending = _customerBloc.isAscending;
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
                  isAscending ? AppLocalizations.of(context)!.sort_asc : AppLocalizations.of(context)!.sort_desc,
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
                    AppLocalizations.of(context)!.sort_by_name,
                    'name',
                    currentSortField,
                    isAscending,
                  ),
                  _buildSortOption(
                    AppLocalizations.of(context)!.sort_by_created_at,
                    'createdAt',
                    currentSortField,
                    isAscending,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
