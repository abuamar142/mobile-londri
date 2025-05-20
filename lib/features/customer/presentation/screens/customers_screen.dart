import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/textstyle/app_textstyle.dart';
import '../../../../core/utils/show_confirmation_dialog.dart';
import '../../../../core/utils/show_snackbar.dart';
import '../../../../core/widgets/widget_button.dart';
import '../../../../core/widgets/widget_loading.dart';
import '../../../../core/widgets/widget_text_button.dart';
import '../../../../src/generated/i18n/app_localizations.dart';
import '../../../service/presentation/widgets/widget_text_form_field.dart';
import '../../domain/entities/customer.dart';
import '../bloc/customer_bloc.dart';

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

  @override
  void initState() {
    super.initState();
    context.read<CustomerBloc>().add(
          CustomerEventGetCustomers(),
        );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appText = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          appText.customer_screen_title,
          style: AppTextStyle.title,
        ),
      ),
      body: BlocConsumer<CustomerBloc, CustomerState>(
        listener: (context, state) {
          if (state is CustomerStateFailure) {
            showSnackbar(context, state.message.toString());
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
        builder: (context, state) {
          if (state is CustomerStateLoading) {
            return WidgetLoading(usingPadding: true);
          } else if (state is CustomerStateSuccessGetCustomers) {
            return SafeArea(
              child: ListView.builder(
                itemCount: state.customers.length,
                itemBuilder: (context, index) {
                  final Customer customer = state.customers[index];

                  return ListTile(
                    key: ValueKey(customer.id),
                    title: Text(
                      customer.name!,
                      style: AppTextStyle.tileTitle.copyWith(
                        color: customer.isActive! ? null : Colors.grey,
                      ),
                    ),
                    subtitle: Text(
                      customer.description ?? '-',
                      style: AppTextStyle.tileSubtitle.copyWith(
                        color: customer.isActive! ? null : Colors.grey,
                      ),
                    ),
                    trailing: Text(
                      customer.phone.toString(),
                      style: AppTextStyle.tileTrailing.copyWith(
                        color: customer.isActive! ? null : Colors.grey,
                      ),
                    ),
                    onTap: () {
                      if (customer.isActive!) {
                        editCustomer(
                          customer: customer,
                          appText: appText,
                        );
                      } else {
                        showSnackbar(context, appText.customer_info_activate);
                      }
                    },
                    onLongPress: () {
                      if (customer.isActive!) {
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
            return Center(
              child: Text(
                appText.customer_empty_message,
                style: AppTextStyle.body,
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => addCustomer(
          appText: appText,
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
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
        context
            .read<CustomerBloc>()
            .add(CustomerEventCreateCustomer(customer: customer));
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
        context
            .read<CustomerBloc>()
            .add(CustomerEventUpdateCustomer(customer: newCustomer));
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
    showDeleteButton = false,
  }) {
    if (customer != null) {
      _nameController.text = customer.name!;
      _phoneController.text = customer.phone.toString();
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
        context.read<CustomerBloc>().add(
              CustomerEventDeleteCustomer(
                customerId: customer.id!,
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
        context.read<CustomerBloc>().add(
              CustomerEventActivateCustomer(
                customerId: customer.id!,
              ),
            );

        context.pop();
      },
    );
  }
}
