import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../config/textstyle/app_colors.dart';
import '../../../../config/textstyle/app_sizes.dart';
import '../../../../config/textstyle/app_textstyle.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../../core/utils/show_snackbar.dart';
import '../../../../core/widgets/widget_button.dart';
import '../../../../core/widgets/widget_loading.dart';
import '../../../../core/widgets/widget_text_form_field.dart';
import '../../../../injection_container.dart';
import '../../../../src/generated/i18n/app_localizations.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../customer/domain/entities/customer.dart';
import '../../../customer/presentation/bloc/customer_bloc.dart';
import '../../../service/domain/entities/service.dart';
import '../../../service/presentation/bloc/service_bloc.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_status.dart';
import '../bloc/transaction_bloc.dart';
import '../widgets/widget_delete_transaction.dart';

enum ManageTransactionMode { add, edit, view }

class ManageTransactionScreen extends StatefulWidget {
  final ManageTransactionMode mode;
  final String? transactionId;

  const ManageTransactionScreen({
    super.key,
    required this.mode,
    this.transactionId,
  });

  @override
  State<ManageTransactionScreen> createState() =>
      _ManageTransactionScreenState();
}

class _ManageTransactionScreenState extends State<ManageTransactionScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  final TextEditingController _customerController = TextEditingController();
  final TextEditingController _serviceController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  // Selected values
  Customer? _selectedCustomer;
  Service? _selectedService;
  TransactionStatus _transactionStatus = TransactionStatus.onProgress;
  PaymentStatus _paymentStatus = PaymentStatus.notPaidYet;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 3));

  bool _isLoading = true;
  Transaction? _currentTransaction;
  late final TransactionBloc _transactionBloc;
  late final CustomerBloc _customerBloc;
  late final ServiceBloc _serviceBloc;
  String? _currentUserId;

  bool get _isAddMode => widget.mode == ManageTransactionMode.add;
  bool get _isEditMode => widget.mode == ManageTransactionMode.edit;
  bool get _isViewMode => widget.mode == ManageTransactionMode.view;

  @override
  void initState() {
    super.initState();
    _transactionBloc = serviceLocator<TransactionBloc>();
    _customerBloc = serviceLocator<CustomerBloc>();
    _serviceBloc = serviceLocator<ServiceBloc>();

    _getCurrentUserId();

    if (_isAddMode) {
      _setDefaultDates();
      setState(() {
        _isLoading = false;
      });
    } else {
      _transactionBloc.add(TransactionEventGetTransactions());
    }

    // Load customers and services for selection
    _customerBloc.add(CustomerEventGetCustomers());
    _serviceBloc.add(ServiceEventGetServices());
  }

  void _getCurrentUserId() {
    final authBloc = serviceLocator<AuthBloc>();
    if (authBloc.state is AuthStateSuccessLogin) {
      final user = (authBloc.state as AuthStateSuccessLogin).auth;
      _currentUserId = user.id;
    }
  }

  void _setDefaultDates() {
    _startDate = DateTime.now();
    _endDate = _startDate.add(const Duration(days: 3));
    _startDateController.text = DateFormat('yyyy-MM-dd').format(_startDate);
    _endDateController.text = DateFormat('yyyy-MM-dd').format(_endDate);
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
    final appText = AppLocalizations.of(context)!;

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _transactionBloc),
        BlocProvider.value(value: _customerBloc),
        BlocProvider.value(value: _serviceBloc),
      ],
      child: BlocConsumer<TransactionBloc, TransactionState>(
        listener: (context, state) {
          if (state is TransactionStateFailure) {
            showSnackbar(context, state.message);
          } else if (state is TransactionStateSuccessCreateTransaction) {
            showSnackbar(context, appText.transaction_add_success_message);
            context.pop(true);
          } else if (state is TransactionStateSuccessUpdateTransaction) {
            showSnackbar(context, appText.transaction_update_success_message);
          } else if (state is TransactionStateSuccessDeleteTransaction) {
            showSnackbar(context, appText.transaction_delete_success_message);
            context.pop(true);
          } else if (state is TransactionStateWithFilteredTransactions) {
            _handleTransactionDataLoaded(state);
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                _getScreenTitle(appText),
                style: AppTextStyle.heading3,
              ),
              centerTitle: true,
              actions: [
                if (_isViewMode)
                  IconButton(
                    onPressed: () async {
                      final result = await context.pushNamed(
                        'print-transaction',
                        pathParameters: {'id': widget.transactionId!},
                      );
                      if (result == true && context.mounted) {
                        context.pop(true);
                      }
                    },
                    icon: const Icon(Icons.print),
                  ),
              ],
            ),
            body: _isLoading
                ? WidgetLoading(usingPadding: true)
                : SafeArea(
                    bottom: false,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(AppSizes.size16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFormFields(state, appText),
                            SizedBox(height: AppSizes.size80),
                          ],
                        ),
                      ),
                    ),
                  ),
            bottomNavigationBar: _buildBottomBar(context, appText, state),
          );
        },
      ),
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    AppLocalizations appText,
    TransactionState state,
  ) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(
          left: AppSizes.size16,
          right: AppSizes.size16,
          bottom: AppSizes.size16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isViewMode)
              Row(
                children: [
                  Expanded(
                    child: WidgetButton(
                      label: appText.button_edit,
                      isLoading: state is TransactionStateLoading,
                      onPressed: () async {
                        if (_currentTransaction != null) {
                          final result = await context.pushNamed(
                            'edit-transaction',
                            pathParameters: {
                              'id': _currentTransaction!.id!.toString()
                            },
                          );

                          if (result == true && context.mounted) {
                            context.pop(true);
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            if (_isAddMode || _isEditMode)
              Row(
                children: [
                  Expanded(
                    child: WidgetButton(
                      label:
                          _isAddMode ? appText.button_add : appText.button_save,
                      isLoading: state is TransactionStateLoading,
                      onPressed: _submitForm,
                    ),
                  ),
                ],
              ),
            if (_isViewMode) AppSizes.spaceHeight12,
            if (_isViewMode)
              Row(
                children: [
                  Expanded(
                    child: WidgetButton(
                      label: appText.button_delete,
                      backgroundColor: AppColors.error,
                      isLoading: state is TransactionStateLoading,
                      onPressed: () {
                        deleteTransaction(
                          context: context,
                          transaction: _currentTransaction!,
                          transactionBloc: _transactionBloc,
                        );
                      },
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _getScreenTitle(AppLocalizations appText) {
    if (_isAddMode) {
      return 'Tambah Transaksi';
    } else if (_isEditMode) {
      return 'Edit Transaksi';
    } else {
      return 'Detail Transaksi';
    }
  }

  Widget _buildFormFields(TransactionState state, AppLocalizations appText) {
    final bool isFormEnabled =
        !_isViewMode && state is! TransactionStateLoading;

    if (_isViewMode) {
      return _buildTransactionDetailView(appText);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Customer Selector
        BlocBuilder<CustomerBloc, CustomerState>(
          builder: (context, state) {
            return WidgetTextFormField(
              label: 'Select Customer',
              hint: 'Select a customer',
              controller: _customerController,
              isEnabled: isFormEnabled,
              readOnly: true,
              suffixIcon: isFormEnabled
                  ? IconButton(
                      onPressed: () => _selectCustomer(context),
                      icon: Icon(Icons.arrow_drop_down),
                    )
                  : null,
              validator: (value) {
                if (_selectedCustomer == null) {
                  return 'Customer is required';
                }
                return null;
              },
            );
          },
        ),
        AppSizes.spaceHeight12,

        // Service Selector
        BlocBuilder<ServiceBloc, ServiceState>(
          builder: (context, state) {
            return WidgetTextFormField(
              label: 'Select Service',
              hint: 'Select a service',
              controller: _serviceController,
              isEnabled: isFormEnabled,
              readOnly: true,
              suffixIcon: isFormEnabled
                  ? IconButton(
                      onPressed: () => _selectService(context),
                      icon: Icon(Icons.arrow_drop_down))
                  : null,
              validator: (value) {
                if (_selectedService == null) {
                  return 'Service is required';
                }
                return null;
              },
            );
          },
        ),
        AppSizes.spaceHeight12,

        // Weight Field
        WidgetTextFormField(
          label: 'Weight',
          hint: 'Enter weight',
          controller: _weightController,
          isEnabled: isFormEnabled,
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Weight is required';
            }
            if (double.tryParse(value) == null) {
              return 'Please enter a valid weight';
            }
            return null;
          },
        ),
        AppSizes.spaceHeight12,

        // Amount Field
        WidgetTextFormField(
          label: 'Amount',
          hint: 'Enter amount',
          controller: _amountController,
          isEnabled: isFormEnabled,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Amount is required';
            }
            if (int.tryParse(value) == null) {
              return 'Please enter a valid amount';
            }
            return null;
          },
        ),
        AppSizes.spaceHeight12,

        // Description Field
        WidgetTextFormField(
          label: appText.form_description_label,
          hint: appText.form_description_hint,
          controller: _descriptionController,
          isEnabled: isFormEnabled,
          maxLines: 3,
        ),
        AppSizes.spaceHeight12,

        // Date Fields
        Row(
          children: [
            Expanded(
              child: WidgetTextFormField(
                label: 'Start Date',
                hint: 'Select start date',
                controller: _startDateController,
                isEnabled: isFormEnabled,
                readOnly: true,
                suffixIcon: isFormEnabled
                    ? IconButton(
                        onPressed: () => _selectStartDate(context),
                        icon: Icon(Icons.calendar_today))
                    : null,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Start date is required';
                  }
                  return null;
                },
              ),
            ),
            AppSizes.spaceWidth12,
            Expanded(
              child: WidgetTextFormField(
                label: 'End Date',
                hint: 'Select end date',
                controller: _endDateController,
                isEnabled: isFormEnabled,
                readOnly: true,
                suffixIcon: isFormEnabled
                    ? IconButton(
                        onPressed: () => _selectEndDate(context),
                        icon: Icon(Icons.calendar_today))
                    : null,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'End date is required';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        AppSizes.spaceHeight16,

        // Status Selection
        if (!_isAddMode) ...[
          Text(
            'Transaction Status',
            style: AppTextStyle.label,
          ),
          AppSizes.spaceHeight8,
          _buildTransactionStatusSelector(isFormEnabled, appText),
          AppSizes.spaceHeight16,
          Text(
            'Payment Status',
            style: AppTextStyle.label,
          ),
          AppSizes.spaceHeight8,
          _buildPaymentStatusSelector(isFormEnabled, appText),
        ],
      ],
    );
  }

  Widget _buildTransactionStatusSelector(
      bool isEnabled, AppLocalizations appText) {
    return Wrap(
      spacing: AppSizes.size8,
      runSpacing: AppSizes.size8,
      children: TransactionStatus.values.map((status) {
        final isSelected = _transactionStatus == status;
        return ChoiceChip(
          label: Text(
            status.value,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.onSecondary,
            ),
          ),
          selected: isSelected,
          onSelected: isEnabled
              ? (selected) {
                  if (selected) {
                    setState(() {
                      _transactionStatus = status;
                    });
                  }
                }
              : null,
          backgroundColor: AppColors.gray.withOpacity(0.1),
          selectedColor: AppColors.primary,
        );
      }).toList(),
    );
  }

  Widget _buildPaymentStatusSelector(bool isEnabled, AppLocalizations appText) {
    return Wrap(
      spacing: AppSizes.size8,
      runSpacing: AppSizes.size8,
      children: PaymentStatus.values.map((status) {
        final isSelected = _paymentStatus == status;
        return ChoiceChip(
          label: Text(
            status.value,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.onSecondary,
            ),
          ),
          selected: isSelected,
          onSelected: isEnabled
              ? (selected) {
                  if (selected) {
                    setState(() {
                      _paymentStatus = status;
                    });
                  }
                }
              : null,
          backgroundColor: AppColors.gray.withOpacity(0.1),
          selectedColor: status == PaymentStatus.paid
              ? AppColors.success
              : AppColors.warning,
        );
      }).toList(),
    );
  }

  Widget _buildTransactionDetailView(AppLocalizations appText) {
    return Column(
      children: [
        Center(
          child: Column(
            children: [
              Container(
                width: AppSizes.size80,
                height: AppSizes.size80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.receipt_long,
                  size: AppSizes.size40,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: AppSizes.size16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TransactionStatusBadge(
                      status: _currentTransaction!.transactionStatus!),
                  SizedBox(width: AppSizes.size8),
                  _buildPaymentStatusBadge(_currentTransaction!.paymentStatus!),
                ],
              ),
              SizedBox(height: AppSizes.size8),
              Text(
                "#${_currentTransaction!.id!.substring(0, 8).toUpperCase()}",
                style: AppTextStyle.heading2.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        SizedBox(height: AppSizes.size24),

        // Customer & Service Info Card
        _buildDetailCard(
          title: 'Transaction Details',
          content: [
            _buildDetailItem(
              icon: Icons.person,
              label: 'Customer',
              value: _customerController.text,
            ),
            _buildDetailItem(
              icon: Icons.design_services,
              label: 'Service',
              value: _serviceController.text,
            ),
            _buildDetailItem(
              icon: Icons.scale,
              label: 'Weight',
              value: "${_weightController.text} kg",
            ),
            _buildDetailItem(
              icon: Icons.attach_money,
              label: 'Amount',
              value:
                  int.tryParse(_amountController.text)?.formatNumber() ?? '-',
            ),
          ],
        ),
        SizedBox(height: AppSizes.size16),

        // Dates Card
        _buildDetailCard(
          title: 'Transaction Dates',
          content: [
            _buildDetailItem(
              icon: Icons.calendar_today,
              label: 'Start Date',
              value: _startDateController.text,
            ),
            _buildDetailItem(
              icon: Icons.event,
              label: 'End Date',
              value: _endDateController.text,
            ),
            _buildDetailItem(
              icon: Icons.access_time,
              label: 'Created At',
              value: _currentTransaction?.createdAt != null
                  ? DateFormat('yyyy-MM-dd HH:mm')
                      .format(_currentTransaction!.createdAt!)
                  : '-',
            ),
          ],
        ),
        SizedBox(height: AppSizes.size16),

        // Description Card
        _buildDetailCard(
          title: 'Description',
          content: [
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppSizes.size8,
              ),
              child: Text(
                _descriptionController.text.isNotEmpty
                    ? _descriptionController.text
                    : '-',
                style: AppTextStyle.body1.copyWith(
                  color: _descriptionController.text.isNotEmpty
                      ? AppColors.onSecondary
                      : AppColors.gray,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentStatusBadge(PaymentStatus status) {
    Color backgroundColor;
    Color textColor = Colors.white;

    switch (status) {
      case PaymentStatus.paid:
        backgroundColor = AppColors.success;
        break;
      case PaymentStatus.notPaidYet:
        backgroundColor = AppColors.warning;
        break;
      default:
        backgroundColor = AppColors.gray;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.size8,
        vertical: AppSizes.size4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSizes.size16),
      ),
      child: Text(
        status.value,
        style: AppTextStyle.caption.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _selectCustomer(BuildContext context) async {
    if (_customerBloc.state is CustomerStateWithFilteredCustomers) {
      final state = _customerBloc.state as CustomerStateWithFilteredCustomers;
      final activeCustomers = state.filteredCustomers
          .where((customer) => customer.isActive ?? false)
          .toList();

      final AppLocalizations appText = AppLocalizations.of(context)!;

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
                      'Select Customer',
                      style: AppTextStyle.heading3,
                    ),
                  ),
                  Divider(height: 1),
                  Expanded(
                    child: activeCustomers.isEmpty
                        ? Center(
                            child: Text(appText.customer_empty_message),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            itemCount: activeCustomers.length,
                            itemBuilder: (context, index) {
                              final customer = activeCustomers[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      AppColors.primary.withOpacity(0.1),
                                  child: Text(
                                    customer.name?[0] ?? '',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(customer.name ?? ''),
                                subtitle: Text(customer.phone ?? ''),
                                onTap: () {
                                  setState(() {
                                    _selectedCustomer = customer;
                                    _customerController.text =
                                        customer.name ?? '';
                                  });
                                  Navigator.pop(context);
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

  void _selectService(BuildContext context) async {
    if (_serviceBloc.state is ServiceStateWithFilteredServices) {
      final state = _serviceBloc.state as ServiceStateWithFilteredServices;
      final activeServices = state.filteredServices
          .where((service) => service.isActive ?? false)
          .toList();

      final AppLocalizations appText = AppLocalizations.of(context)!;

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
                      'Select Service',
                      style: AppTextStyle.heading3,
                    ),
                  ),
                  Divider(height: 1),
                  Expanded(
                    child: activeServices.isEmpty
                        ? Center(
                            child: Text(appText.service_empty_message),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            itemCount: activeServices.length,
                            itemBuilder: (context, index) {
                              final service = activeServices[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      AppColors.primary.withOpacity(0.1),
                                  child: Icon(
                                    Icons.design_services,
                                    color: AppColors.primary,
                                  ),
                                ),
                                title: Text(service.name ?? ''),
                                subtitle: Text(
                                  service.price != null
                                      ? service.price!.formatNumber()
                                      : '-',
                                ),
                                onTap: () {
                                  setState(() {
                                    _selectedService = service;
                                    _serviceController.text =
                                        service.name ?? '';
                                    if (service.price != null &&
                                        _weightController.text.isNotEmpty) {
                                      final weight = double.tryParse(
                                              _weightController.text) ??
                                          0;
                                      _calculateAmount(weight, service.price!);
                                    }
                                  });
                                  Navigator.pop(context);
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
        // Update end date to be 3 days after start date
        _endDate = _startDate.add(const Duration(days: 3));
        _endDateController.text = DateFormat('yyyy-MM-dd').format(_endDate);
      });
    }
  }

  Widget _buildDetailCard({
    required String title,
    required List<Widget> content,
  }) {
    return Card(
      elevation: 2,
      surfaceTintColor: AppColors.primary,
      color: AppColors.onPrimary,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.size12),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          left: AppSizes.size16,
          right: AppSizes.size16,
          top: AppSizes.size16,
          bottom: AppSizes.size8,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyle.heading3.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            ...content,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.size8),
      child: Row(
        children: [
          Icon(icon, size: AppSizes.size20, color: AppColors.primary),
          SizedBox(width: AppSizes.size8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyle.body2.copyWith(
                  color: AppColors.gray,
                ),
              ),
              SizedBox(height: AppSizes.size4),
              Text(
                value,
                style: AppTextStyle.body1.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Spacer(),
          if (trailing != null) trailing,
        ],
      ),
    );
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

  void _handleTransactionDataLoaded(
      TransactionStateWithFilteredTransactions state) {
    if (widget.transactionId != null) {
      final transaction = state.allTransactions.firstWhere(
        (transaction) => transaction.id == widget.transactionId,
      );

      if (transaction.id != null) {
        _currentTransaction = transaction;

        // Populate form fields
        _transactionStatus =
            transaction.transactionStatus ?? TransactionStatus.onProgress;
        _paymentStatus = transaction.paymentStatus ?? PaymentStatus.notPaidYet;
        _customerController.text = transaction.customerName ?? '';
        _serviceController.text = transaction.serviceName ?? '';
        _weightController.text = transaction.weight?.toString() ?? '';
        _amountController.text = transaction.amount?.toString() ?? '';
        _descriptionController.text = transaction.description ?? '';

        if (transaction.startDate != null) {
          _startDate = transaction.startDate!;
          _startDateController.text =
              DateFormat('yyyy-MM-dd').format(_startDate);
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

        setState(() {
          _isLoading = false;
        });
      } else {
        showSnackbar(context, 'Transaction not found');
        context.pop();
      }
    }
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedCustomer == null) {
        showSnackbar(context, 'Customer is required');
        return;
      }

      if (_selectedService == null) {
        showSnackbar(context, 'Service is required');
        return;
      }

      final transaction = Transaction(
        id: _isAddMode ? null : _currentTransaction!.id,
        userId: _currentUserId,
        customerId: _selectedCustomer!.id,
        serviceId: _selectedService!.id,
        customerName: _selectedCustomer!.name,
        serviceName: _selectedService!.name,
        weight: double.tryParse(_weightController.text),
        amount: int.tryParse(_amountController.text),
        description: _descriptionController.text,
        transactionStatus:
            _isAddMode ? TransactionStatus.onProgress : _transactionStatus,
        paymentStatus: _isAddMode ? PaymentStatus.notPaidYet : _paymentStatus,
        startDate: _startDate,
        endDate: _endDate,
        isActive: _currentTransaction?.isActive ?? true,
      );

      if (_isAddMode) {
        _transactionBloc
            .add(TransactionEventCreateTransaction(transaction: transaction));
      } else if (_isEditMode) {
        _transactionBloc
            .add(TransactionEventUpdateTransaction(transaction: transaction));
      }
    }
  }
}

class TransactionStatusBadge extends StatelessWidget {
  final TransactionStatus status;

  const TransactionStatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor = Colors.white;

    switch (status) {
      case TransactionStatus.onProgress:
        backgroundColor = AppColors.gray;
        break;
      case TransactionStatus.readyForPickup:
        backgroundColor = AppColors.warning;
        break;
      case TransactionStatus.pickedUp:
        backgroundColor = AppColors.success;
        break;
      default:
        backgroundColor = AppColors.error;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.size8,
        vertical: AppSizes.size4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppSizes.size16),
      ),
      child: Text(
        status.value,
        style: AppTextStyle.caption.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
