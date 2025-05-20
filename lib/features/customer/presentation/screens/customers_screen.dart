import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/textstyle/app_colors.dart';
import '../../../../config/textstyle/app_sizes.dart';
import '../../../../config/textstyle/app_textstyle.dart';
import '../../../../core/utils/launch_whatsapp.dart';
import '../../../../core/utils/show_confirmation_dialog.dart';
import '../../../../core/utils/show_snackbar.dart';
import '../../../../core/widgets/widget_button.dart';
import '../../../../core/widgets/widget_empty_list.dart';
import '../../../../core/widgets/widget_error.dart';
import '../../../../core/widgets/widget_list_tile.dart';
import '../../../../core/widgets/widget_loading.dart';
import '../../../../core/widgets/widget_search_bar.dart';
import '../../../../core/widgets/widget_text_button.dart';
import '../../../../injection_container.dart';
import '../../../../src/generated/i18n/app_localizations.dart';
import '../../../service/presentation/widgets/widget_text_form_field.dart';
import '../../domain/entities/customer.dart';
import '../bloc/customer_bloc.dart';

void pushCustomers(BuildContext context) {
  context.pushNamed('customers');
}

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  late final CustomerBloc _customerBloc;

  @override
  void initState() {
    super.initState();
    _customerBloc = serviceLocator<CustomerBloc>();
    _getCustomers();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _getCustomers() {
    _customerBloc.add(CustomerEventGetCustomers());
  }

  @override
  Widget build(BuildContext context) {
    final appText = AppLocalizations.of(context)!;

    return BlocProvider.value(
      value: _customerBloc,
      child: BlocListener<CustomerBloc, CustomerState>(
        listener: (context, state) {
          if (state is CustomerStateFailure) {
            showSnackbar(context, state.message);
          } else if (state is CustomerStateSuccessCreateCustomer) {
            showSnackbar(context, appText.customer_add_success_message);
          } else if (state is CustomerStateSuccessUpdateCustomer) {
            showSnackbar(context, appText.customer_update_success_message);
          } else if (state is CustomerStateSuccessDeleteCustomer) {
            showSnackbar(context, appText.customer_delete_success_message);
          } else if (state is CustomerStateSuccessActivateCustomer) {
            showSnackbar(context, appText.customer_activate_success_message);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              appText.customer_screen_title,
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
                    child: _buildCustomerList(appText),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => addCustomer(appText: appText),
            child: const Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Row _buildHeader(AppLocalizations appText, BuildContext context) {
    return Row(
      children: [
        WidgetSearchBar(
          controller: _searchController,
          hintText: appText.customer_search_hint,
          onChanged: (value) {
            setState(() {
              _customerBloc.add(
                CustomerEventSearchCustomer(
                  query: value,
                ),
              );
            });
          },
          onClear: () {
            setState(() {
              _customerBloc.add(
                CustomerEventSearchCustomer(
                  query: '',
                ),
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

  Widget _buildCustomerList(AppLocalizations appText) {
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
              emptyMessage: appText.customer_empty_message,
              onRefresh: _getCustomers,
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              _getCustomers();
            },
            child: ListView.separated(
              itemCount: filteredCustomers.length,
              separatorBuilder: (_, __) => AppSizes.spaceHeight8,
              itemBuilder: (context, index) {
                final customer = filteredCustomers[index];
                final isActive = customer.isActive ?? false;

                return WidgetListTile(
                  title: customer.name ?? '',
                  subtitle: customer.description ?? '-',
                  trailing: customer.phone != null
                      ? IconButton(
                          icon: Icon(Icons.send),
                          onPressed: () {
                            launchWhatsapp(phone: customer.phone!, message: '');
                          },
                        )
                      : null,
                  leadingIcon: isActive ? Icons.person : Icons.person_off,
                  tileColor: isActive
                      ? null
                      : Colors.grey.withValues(
                          alpha: 0.2,
                        ),
                  onTap: () {
                    if (isActive) {
                      editCustomer(
                        customer: customer,
                        appText: appText,
                      );
                    } else {
                      showSnackbar(context, appText.customer_info_activate);
                    }
                  },
                  onLongPress: () {
                    if (isActive) {
                      showSnackbar(context, appText.customer_info_active);
                    } else {
                      activateCustomer(
                        customer: customer,
                        appText: appText,
                      );
                    }
                  },
                );
              },
            ),
          );
        } else {
          return WidgetEmptyList(
            emptyMessage: appText.customer_empty_message,
            onRefresh: _getCustomers,
          );
        }
      },
    );
  }

  void _showSortOptions(BuildContext context) {
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
                    AppLocalizations.of(context)!.sort_by_name,
                    'name',
                    currentSortField,
                    isAscending,
                  ),
                  _buildSortOption(
                    'Phone',
                    'phone',
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

  Widget _buildSortOption(
    String title,
    String field,
    String currentSortField,
    bool isAscending,
  ) {
    final bool isSelected = currentSortField == field;

    return ListTile(
      leading: Icon(
        isSelected
            ? (isAscending ? Icons.arrow_upward : Icons.arrow_downward)
            : Icons.sort,
        color: isSelected ? AppColors.primary : Colors.grey,
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

        _customerBloc.add(
          CustomerEventSortCustomers(
            sortBy: field,
            ascending: newAscending,
          ),
        );

        Navigator.pop(context);
      },
    );
  }

  void addCustomer({
    required AppLocalizations appText,
  }) {
    _showCustomerDialog(
      context: context,
      appText: appText,
      title: appText.customer_add_dialog_title,
      onSubmit: (Customer customer) {
        _customerBloc.add(CustomerEventCreateCustomer(customer: customer));
        context.pop();
      },
    );
  }

  void editCustomer({
    required Customer customer,
    required AppLocalizations appText,
  }) {
    _showCustomerDialog(
      context: context,
      appText: appText,
      title: appText.customer_edit_dialog_title,
      customer: customer,
      showDeleteButton: true,
      onSubmit: (Customer newCustomer) {
        _customerBloc.add(CustomerEventUpdateCustomer(customer: newCustomer));
        context.pop();
      },
    );
  }

  void _showCustomerDialog({
    required BuildContext context,
    required AppLocalizations appText,
    required String title,
    Customer? customer,
    required Function(Customer) onSubmit,
    bool showDeleteButton = false,
  }) {
    if (customer != null) {
      _nameController.text = customer.name ?? '';
      _phoneController.text = customer.phone ?? '';
      _descriptionController.text = customer.description ?? '';
    } else {
      _nameController.clear();
      _phoneController.clear();
      _descriptionController.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        content: Form(
          key: _formKey,
          child: BlocBuilder<CustomerBloc, CustomerState>(
            builder: (context, state) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: AppTextStyle.title),
                  SizedBox(height: 8),
                  WidgetTextFormField(
                    label: appText.form_name_label,
                    enabled: state is! CustomerStateLoading,
                    controller: _nameController,
                    validator: (value) =>
                        value?.isEmpty ?? true ? appText.form_name_hint : null,
                  ),
                  WidgetTextFormField(
                    label: appText.form_phone_label,
                    enabled: state is! CustomerStateLoading,
                    controller: _phoneController,
                    textInputType: TextInputType.phone,
                    validator: (value) =>
                        value?.isEmpty ?? true ? appText.form_phone_hint : null,
                  ),
                  WidgetTextFormField(
                    label: appText.form_description_label,
                    enabled: state is! CustomerStateLoading,
                    maxLines: 3,
                    controller: _descriptionController,
                  ),
                  const SizedBox(height: 4),
                  WidgetButton(
                    label: appText.button_submit,
                    isLoading: state is CustomerStateLoading,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final newCustomer = Customer(
                          id: customer?.id,
                          name: _nameController.text,
                          description: _descriptionController.text,
                          phone: _phoneController.text,
                          isActive: customer?.isActive ?? true,
                        );

                        onSubmit(newCustomer);
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  if (showDeleteButton)
                    WidgetTextButton(
                      label: appText.button_delete,
                      isLoading: state is CustomerStateLoading,
                      onPressed: () => deleteCustomer(
                        customer: customer!,
                        appText: appText,
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void deleteCustomer({
    required Customer customer,
    required AppLocalizations appText,
  }) {
    context.pop();

    showConfirmationDialog(
      context: context,
      title: appText.customer_delete_dialog_title,
      content: appText.customer_delete_confirm_message,
      onConfirm: () {
        _customerBloc.add(
          CustomerEventDeleteCustomer(
            customerId: customer.id.toString(),
          ),
        );
        context.pop();
      },
    );
  }

  void activateCustomer({
    required Customer customer,
    required AppLocalizations appText,
  }) {
    showConfirmationDialog(
      context: context,
      title: appText.customer_activate_dialog_title,
      content: appText.customer_activate_confirm_message,
      onConfirm: () {
        _customerBloc.add(
          CustomerEventActivateCustomer(
            customerId: customer.id.toString(),
          ),
        );
        context.pop();
      },
    );
  }
}
