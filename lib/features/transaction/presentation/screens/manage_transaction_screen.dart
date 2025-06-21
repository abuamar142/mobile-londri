import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../config/textstyle/app_colors.dart';
import '../../../../config/textstyle/app_sizes.dart';
import '../../../../config/textstyle/app_textstyle.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../../core/widgets/widget_app_bar.dart';
import '../../../../core/widgets/widget_button.dart';
import '../../../../core/widgets/widget_dropdown_bottom_sheet.dart';
import '../../../../core/widgets/widget_dropdown_bottom_sheet_item.dart';
import '../../../../core/widgets/widget_loading.dart';
import '../../../../core/widgets/widget_text_form_field.dart';
import '../../../../injection_container.dart';
import '../../../customer/domain/entities/customer.dart';
import '../../../customer/domain/entities/gender.dart';
import '../../../customer/presentation/bloc/customer_bloc.dart';
import '../../../customer/presentation/widgets/widget_dropdown.dart';
import '../../../service/domain/entities/service.dart';
import '../../../service/presentation/bloc/service_bloc.dart';
import '../../domain/entities/payment_status.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_status.dart';
import '../bloc/transaction_bloc.dart';
import '../widgets/widget_bottom_bar.dart';

enum ManageTransactionMode { add, edit }

Future<bool> pushAddTransaction({
  required BuildContext context,
}) async {
  await context.pushNamed(RouteNames.addTransaction);
  return true;
}

Future<bool> pushViewTransaction({
  required BuildContext context,
  required String transactionId,
}) async {
  await context.pushNamed(
    RouteNames.viewTransaction,
    pathParameters: {
      'id': transactionId,
    },
  );
  return true;
}

Future<bool> pushEditTransaction({
  required BuildContext context,
  required String transactionId,
}) async {
  await context.pushNamed(
    RouteNames.editTransaction,
    pathParameters: {
      'id': transactionId,
    },
  );
  return true;
}

class ManageTransactionScreen extends StatefulWidget {
  final ManageTransactionMode mode;
  final String? transactionId;

  const ManageTransactionScreen({
    super.key,
    required this.mode,
    this.transactionId,
  });

  @override
  State<ManageTransactionScreen> createState() => _ManageTransactionScreenState();
}

class _ManageTransactionScreenState extends State<ManageTransactionScreen> {
  late final TransactionBloc _transactionBloc;
  late final CustomerBloc _customerBloc;
  late final ServiceBloc _serviceBloc;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _customerController = TextEditingController();
  final TextEditingController _serviceController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  int? _currentUserId;
  Customer? _selectedCustomer;
  Service? _selectedService;
  Transaction? _currentTransaction;

  TransactionStatus _transactionStatus = TransactionStatus.onProgress;
  PaymentStatus _paymentStatus = PaymentStatus.notPaidYet;

  DateTime _startDate = DateTime.now().toLocal();
  DateTime _endDate = DateTime.now().add(const Duration(days: 3)).toLocal();

  bool get _isAddMode => widget.mode == ManageTransactionMode.add;
  bool get _isEditMode => widget.mode == ManageTransactionMode.edit;

  @override
  void initState() {
    super.initState();

    _transactionBloc = serviceLocator<TransactionBloc>();
    _customerBloc = serviceLocator<CustomerBloc>();
    _serviceBloc = serviceLocator<ServiceBloc>();

    _getCurrentUserId();

    if (_isAddMode) {
      _setDefaultDates();
    } else {
      _transactionBloc.add(
        TransactionEventGetTransactionById(id: widget.transactionId!),
      );
    }

    _customerBloc.add(CustomerEventGetActiveCustomers());
    _serviceBloc.add(ServiceEventGetActiveServices());
  }

  @override
  void dispose() {
    _customerController.dispose();
    _serviceController.dispose();
    _weightController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _transactionBloc),
        BlocProvider.value(value: _customerBloc),
        BlocProvider.value(value: _serviceBloc),
      ],
      child: BlocConsumer<TransactionBloc, TransactionState>(
        listener: (context, state) {
          if (state is TransactionStateFailure) {
            context.showSnackbar(state.message);
          } else if (state is TransactionStateSuccessCreateTransaction) {
            context.showSnackbar(context.appText.transaction_add_success_message);
            context.pop();
            pushViewTransaction(
              context: context,
              transactionId: state.transactionId.toString(),
            );
          } else if (state is TransactionStateSuccessUpdateTransaction) {
            context.showSnackbar(context.appText.transaction_update_success_message);
            context.pop();
          } else if (state is TransactionStateSuccessGetTransactionById) {
            _handleTransactionDataLoaded();
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: WidgetAppBar(
              title: _getScreenTitle(),
            ),
            body: SafeArea(
              child: state is TransactionStateLoading
                  ? WidgetLoading(usingPadding: true)
                  : SingleChildScrollView(
                      padding: EdgeInsets.all(AppSizes.size16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFormFields(),
                          ],
                        ),
                      ),
                    ),
            ),
            bottomNavigationBar: WidgetBottomBar(
              content: [
                Row(
                  children: [
                    Expanded(
                      child: WidgetButton(
                        label: _isAddMode ? context.appText.button_add : context.appText.button_save,
                        isLoading: state is TransactionStateLoading,
                        onPressed: _submitForm,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getScreenTitle() {
    if (_isAddMode) {
      return context.appText.transaction_add_screen_title;
    } else {
      return context.appText.transaction_edit_screen_title;
    }
  }

  Widget _buildFormFields() {
    final bool isFormEnabled = _transactionBloc.state is! TransactionStateLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Customer Selector
        BlocBuilder<CustomerBloc, CustomerState>(
          builder: (context, state) {
            return WidgetDropdown(
              icon: _selectedCustomer?.gender?.icon ?? Gender.other.icon,
              label: _selectedCustomer?.name ?? context.appText.form_select_customer_label,
              isEnable: isFormEnabled,
              showModalBottomSheet: () => _selectCustomer(context),
            );
          },
        ),
        AppSizes.spaceHeight12,

        // Service Selector
        BlocBuilder<ServiceBloc, ServiceState>(
          builder: (context, state) {
            return WidgetDropdown(
              icon: Icons.assignment,
              label: _selectedService?.name ?? context.appText.form_select_service_label,
              isEnable: isFormEnabled,
              showModalBottomSheet: () => _selectService(context),
            );
          },
        ),
        AppSizes.spaceHeight12,

        // Weight Field
        WidgetTextFormField(
          label: context.appText.form_weight_label,
          hint: context.appText.form_weight_hint,
          controller: _weightController,
          isEnabled: isFormEnabled,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          onChanged: (value) {
            if (_selectedService != null && value.isNotEmpty) {
              final weight = double.tryParse(value) ?? 0;
              _calculateAmount(weight, _selectedService!.price ?? 0);
            } else {
              _amountController.clear();
            }
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return context.appText.form_weight_required_message;
            }
            if (double.tryParse(value) == null) {
              return context.appText.form_weight_digits_only_message;
            }
            return null;
          },
        ),
        AppSizes.spaceHeight12,

        // Amount Field
        WidgetTextFormField(
          label: context.appText.form_amount_label,
          hint: context.appText.form_amount_hint,
          controller: _amountController,
          isEnabled: isFormEnabled,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return context.appText.form_amount_required_message;
            }
            if (int.tryParse(value) == null) {
              return context.appText.form_amount_digits_only_message;
            }
            return null;
          },
        ),
        AppSizes.spaceHeight12,

        // Description Field
        WidgetTextFormField(
          label: context.appText.form_description_label,
          hint: context.appText.form_description_hint,
          controller: _descriptionController,
          isEnabled: isFormEnabled,
          maxLines: 3,
        ),

        AppSizes.spaceHeight16,

        Divider(
          thickness: 1,
          color: AppColors.primary,
        ),

        AppSizes.spaceHeight16,

        // Date Fields
        Row(
          children: [
            Expanded(
              child: WidgetTextFormField(
                label: context.appText.form_start_date_label,
                hint: context.appText.form_start_date_hint,
                controller: _startDateController,
                isEnabled: isFormEnabled,
                readOnly: true,
                suffixIcon: isFormEnabled ? IconButton(onPressed: () => _selectStartDate(context), icon: Icon(Icons.calendar_today)) : null,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return context.appText.form_start_date_required_message;
                  }
                  return null;
                },
              ),
            ),
            AppSizes.spaceWidth12,
            Expanded(
              child: WidgetTextFormField(
                label: context.appText.form_end_date_label,
                hint: context.appText.form_end_date_hint,
                controller: _endDateController,
                isEnabled: isFormEnabled,
                readOnly: true,
                suffixIcon: isFormEnabled ? IconButton(onPressed: () => _selectEndDate(context), icon: Icon(Icons.calendar_today)) : null,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return context.appText.form_end_date_required_message;
                  }
                  if (_startDate.isAfter(_endDate)) {
                    return context.appText.form_end_date_after_start_date_message;
                  }
                  return null;
                },
              ),
            ),
          ],
        ),

        AppSizes.spaceHeight12,

        // Transaction Status Selection
        WidgetDropdown(
          icon: _transactionStatus.icon,
          label: getTransactionStatusValue(context, _transactionStatus),
          isEnable: isFormEnabled,
          showModalBottomSheet: () => _showTransactionStatusOptions(),
        ),
        AppSizes.spaceHeight16,

        // Payment Status Selection
        WidgetDropdown(
          icon: _paymentStatus.icon,
          label: getPaymentStatusValue(context, _paymentStatus),
          isEnable: isFormEnabled,
          showModalBottomSheet: () => _showPaymentStatusOptions(),
        ),
      ],
    );
  }

  void _showTransactionStatusOptions() {
    return showDropdownBottomSheet(context: context, title: context.appText.form_transaction_status_hint, items: [
      WidgetDropdownBottomSheetItem(
        isSelected: _transactionStatus == TransactionStatus.onProgress,
        leadingIcon: TransactionStatus.onProgress.icon,
        title: getTransactionStatusValue(context, TransactionStatus.onProgress),
        onTap: () {
          setState(() {
            _transactionStatus = TransactionStatus.onProgress;
          });
        },
      ),
      WidgetDropdownBottomSheetItem(
        isSelected: _transactionStatus == TransactionStatus.readyForPickup,
        leadingIcon: TransactionStatus.readyForPickup.icon,
        title: getTransactionStatusValue(context, TransactionStatus.readyForPickup),
        onTap: () {
          setState(() {
            _transactionStatus = TransactionStatus.readyForPickup;
          });
        },
      ),
      WidgetDropdownBottomSheetItem(
        isSelected: _transactionStatus == TransactionStatus.pickedUp,
        leadingIcon: TransactionStatus.pickedUp.icon,
        title: getTransactionStatusValue(context, TransactionStatus.pickedUp),
        onTap: () {
          setState(() {
            _transactionStatus = TransactionStatus.pickedUp;
          });
        },
      ),
      WidgetDropdownBottomSheetItem(
        isSelected: _transactionStatus == TransactionStatus.other,
        leadingIcon: TransactionStatus.other.icon,
        title: getTransactionStatusValue(context, TransactionStatus.other),
        onTap: () {
          setState(() {
            _transactionStatus = TransactionStatus.other;
          });
        },
      ),
    ]);
  }

  void _showPaymentStatusOptions() {
    return showDropdownBottomSheet(context: context, title: context.appText.form_payment_status_hint, items: [
      WidgetDropdownBottomSheetItem(
        isSelected: _paymentStatus == PaymentStatus.notPaidYet,
        leadingIcon: PaymentStatus.notPaidYet.icon,
        title: getPaymentStatusValue(context, PaymentStatus.notPaidYet),
        onTap: () {
          setState(() {
            _paymentStatus = PaymentStatus.notPaidYet;
          });
        },
      ),
      WidgetDropdownBottomSheetItem(
        isSelected: _paymentStatus == PaymentStatus.paid,
        leadingIcon: PaymentStatus.paid.icon,
        title: getPaymentStatusValue(context, PaymentStatus.paid),
        onTap: () {
          setState(() {
            _paymentStatus = PaymentStatus.paid;
          });
        },
      ),
      WidgetDropdownBottomSheetItem(
        isSelected: _paymentStatus == PaymentStatus.other,
        leadingIcon: PaymentStatus.other.icon,
        title: getPaymentStatusValue(context, PaymentStatus.other),
        onTap: () {
          setState(() {
            _paymentStatus = PaymentStatus.other;
          });
        },
      ),
    ]);
  }

  void _selectCustomer(BuildContext context) async {
    if (_customerBloc.state is CustomerStateSuccessGetActiveCustomers) {
      final state = _customerBloc.state as CustomerStateSuccessGetActiveCustomers;
      final activeCustomers = state.activeCustomers;

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSizes.size16),
          ),
        ),
        builder: (context) {
          return DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            expand: false,
            builder: (context, scrollController) {
              return Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(AppSizes.size16),
                    child: Text(
                      context.appText.form_select_customer_hint,
                      style: AppTextStyle.heading3,
                    ),
                  ),
                  Divider(
                    thickness: 1,
                  ),
                  Expanded(
                    child: activeCustomers.isEmpty
                        ? Center(
                            child: Text(
                              context.appText.customer_empty_message,
                              style: AppTextStyle.body1,
                            ),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            itemCount: activeCustomers.length,
                            itemBuilder: (context, index) {
                              final customer = activeCustomers[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  child: Icon(
                                    _getLeadingIcon(customer),
                                    color: AppColors.primary,
                                  ),
                                ),
                                title: Text(
                                  customer.name ?? '',
                                  style: AppTextStyle.body1.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  _getCustomerSubtitle(customer),
                                  style: AppTextStyle.body2,
                                ),
                                onTap: () {
                                  setState(() {
                                    _selectedCustomer = customer;
                                    _customerController.text = customer.name ?? '';
                                  });
                                  context.pop();
                                },
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          );
        },
      );
    } else {
      _customerBloc.add(CustomerEventGetCustomers());
    }
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

  String _getServiceSubtitle(Service service) {
    final List<String> parts = [];

    if (service.price != null && service.price! > 0) {
      parts.add('${service.price!.formatNumber()}/kg');
    }

    if (service.description != null && service.description!.isNotEmpty) {
      parts.add(service.description!);
    }

    return parts.isEmpty ? '-' : parts.join(' • ');
  }

  IconData _getLeadingIcon(Customer customer) {
    if (!(customer.isActive ?? true)) {
      return Icons.person_off;
    }

    switch (customer.gender) {
      case Gender.male:
        return Icons.man;
      case Gender.female:
        return Icons.woman;
      case Gender.other:
      default:
        return Icons.person;
    }
  }

  void _selectService(BuildContext context) async {
    if (_serviceBloc.state is ServiceStateSuccessGetActiveServices) {
      final state = _serviceBloc.state as ServiceStateSuccessGetActiveServices;
      final activeServices = state.activeServices;

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSizes.size16),
          ),
        ),
        builder: (context) {
          return DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            expand: false,
            builder: (context, scrollController) {
              return Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(AppSizes.size16),
                    child: Text(
                      context.appText.form_select_service_hint,
                      style: AppTextStyle.heading3,
                    ),
                  ),
                  Divider(height: 1),
                  Expanded(
                    child: activeServices.isEmpty
                        ? Center(
                            child: Text(context.appText.service_empty_message),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            itemCount: activeServices.length,
                            itemBuilder: (context, index) {
                              final service = activeServices[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  child: Icon(
                                    Icons.assignment,
                                    color: AppColors.primary,
                                  ),
                                ),
                                title: Text(
                                  service.name ?? '',
                                  style: AppTextStyle.body1.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  _getServiceSubtitle(service),
                                  style: AppTextStyle.body2,
                                ),
                                onTap: () {
                                  setState(() {
                                    _selectedService = service;
                                    _serviceController.text = service.name ?? '';
                                    if (service.price != null && _weightController.text.isNotEmpty) {
                                      final weight = double.tryParse(_weightController.text) ?? 0;
                                      _calculateAmount(weight, service.price!);
                                    }
                                  });
                                  context.pop();
                                },
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          );
        },
      );
    } else {
      _serviceBloc.add(ServiceEventGetServices());
    }
  }

  void _getCurrentUserId() async {
    // Get the ID from public.users table
    final authService = serviceLocator<AuthService>();
    _currentUserId = await authService.getCurrentUserId();

    if (_currentUserId == null) {
      if (mounted) {
        context.showSnackbar('Error: Could not get user ID. Please try again.');
      }
    }
  }

  void _setDefaultDates() {
    _startDate = DateTime.now();
    _endDate = _startDate.add(const Duration(days: 3));
    _startDateController.text = DateFormat('yyyy-MM-dd').format(_startDate);
    _endDateController.text = DateFormat('yyyy-MM-dd').format(_endDate);
  }

  void _calculateAmount(double weight, int price) {
    final amount = (weight * price).round();
    _amountController.text = amount.toString();
  }

  void _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
        _startDateController.text = DateFormat('yyyy-MM-dd').format(_startDate);

        _endDate = _startDate.add(const Duration(days: 3));
        _endDateController.text = DateFormat('yyyy-MM-dd').format(_endDate);
      });
    }
  }

  void _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: _startDate.add(const Duration(days: 30)),
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
        _endDateController.text = DateFormat('yyyy-MM-dd').format(_endDate);
      });
    }
  }

  void _handleTransactionDataLoaded() {
    if (widget.transactionId != null) {
      final transaction = (_transactionBloc.state as TransactionStateSuccessGetTransactionById).transaction;

      if (transaction.id != null) {
        _currentTransaction = transaction;

        // Populate form fields
        _transactionStatus = transaction.transactionStatus ?? TransactionStatus.onProgress;
        _paymentStatus = transaction.paymentStatus ?? PaymentStatus.notPaidYet;
        _customerController.text = transaction.customerName ?? '';
        _serviceController.text = transaction.serviceName ?? '';
        _weightController.text = transaction.weight?.toString() ?? '';
        _amountController.text = transaction.amount?.toString() ?? '';
        _descriptionController.text = transaction.description ?? '';

        if (transaction.startDate != null) {
          _startDate = transaction.startDate!;
          _startDateController.text = DateFormat('yyyy-MM-dd').format(_startDate);
        }

        if (transaction.endDate != null) {
          _endDate = transaction.endDate!;
          _endDateController.text = DateFormat('yyyy-MM-dd').format(_endDate);
        }

        // Set selected entities
        _selectedCustomer = Customer(
          id: transaction.customerId,
          name: transaction.customerName,
        );

        _selectedService = Service(
          id: transaction.serviceId,
          name: transaction.serviceName,
        );
      } else {
        context.showSnackbar(context.appText.transaction_status_other);
        context.pop();
      }
    }
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedCustomer == null) {
        context.showSnackbar(context.appText.customer_empty_message);
        return;
      }

      if (_selectedService == null) {
        context.showSnackbar(context.appText.service_empty_message);
        return;
      }

      if (_currentUserId == null) {
        context.showSnackbar('Error: User ID not found. Please try logging in again.');
        return;
      }

      final transaction = Transaction(
        id: _isAddMode ? null : _currentTransaction!.id,
        userId: _currentUserId?.toString(),
        customerId: _selectedCustomer!.id,
        serviceId: _selectedService!.id,
        customerName: _selectedCustomer!.name,
        serviceName: _selectedService!.name,
        weight: double.tryParse(_weightController.text),
        amount: int.tryParse(_amountController.text),
        description: _descriptionController.text,
        transactionStatus: _transactionStatus,
        paymentStatus: _paymentStatus,
        startDate: _startDate,
        endDate: _endDate,
        isDeleted: _currentTransaction?.isDeleted ?? true,
      );

      if (_isAddMode) {
        _transactionBloc.add(TransactionEventCreateTransaction(transaction: transaction));
      } else if (_isEditMode) {
        _transactionBloc.add(TransactionEventUpdateTransaction(transaction: transaction));
      }
    }
  }
}
