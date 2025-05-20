import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/textstyle/app_textstyle.dart';
import '../../../../core/utils/show_snackbar.dart';
import '../../../../core/widgets/widget_button.dart';
import '../../../../core/widgets/widget_loading.dart';
import '../../../../core/widgets/widget_text_button.dart';
import '../../../../src/generated/i18n/app_localizations.dart';
import '../../../customer/domain/entities/customer.dart';
import '../../../service/domain/entities/service.dart';
import '../../../service/presentation/bloc/service_bloc.dart';
import '../../../transaction/domain/entities/transaction.dart';
import '../../domain/usecases/transaction_get_transaction_status.dart';
import '../bloc/transaction_bloc.dart';
import '../widgets/transaction_item.dart';

void pushTransactions(BuildContext context) {
  context.pushNamed('transactions');
}

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _serviceController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<TransactionBloc>().add(
          TransactionEventGetTransactions(),
        );
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _serviceController.dispose();
    _weightController.dispose();
    _amountController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appText = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          appText.transaction_screen_title,
          style: AppTextStyle.title,
        ),
      ),
      body: BlocConsumer<TransactionBloc, TransactionState>(
        listener: (context, state) {
          if (state is TransactionStateFailure) {
            showSnackbar(context, state.message.toString());
          }
        },
        builder: (context, state) {
          if (state is TransactionStateLoading) {
            return WidgetLoading(usingPadding: true);
          } else if (state is TransactionStateSuccessGetTransactions) {
            return SafeArea(
              child: TransactionItem(
                transactions: state.transactions,
              ),
            );
          } else {
            return Center(
              child: Text(
                appText.transaction_empty_message,
                style: AppTextStyle.body,
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => addTransaction(
          appText: appText,
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  void addTransaction({
    required AppLocalizations appText,
  }) {
    _showTransactionDialog(
      context: context,
      appText: appText,
      title: appText.transaction_add_dialog_title,
      onSubmit: (Transaction transaction) {
        context.read<TransactionBloc>().add(
              TransactionEventCreateTransaction(
                transaction: transaction,
              ),
            );

        context.pop();
      },
    );
  }

  void _showTransactionDialog({
    required BuildContext context,
    required AppLocalizations appText,
    required String title,
    Transaction? transaction,
    required Function(Transaction) onSubmit,
    showDeleteButton = false,
  }) {
    if (transaction != null) {
      _customerNameController.text = transaction.customerName!;
      _serviceController.text = transaction.serviceName!;
      _weightController.text = transaction.weight.toString();
      _amountController.text = transaction.amount.toString();
      _startDateController.text = transaction.startDate!.toString();
      _endDateController.text = transaction.endDate!.toString();
      _statusController.text = transaction.status!.name;
    } else {
      _customerNameController.clear();
      _serviceController.clear();
      _weightController.clear();
      _amountController.clear();
      _startDateController.clear();
      _endDateController.clear();
      _statusController.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        content: Form(
          key: _formKey,
          child: BlocBuilder<TransactionBloc, TransactionState>(
            builder: (context, state) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: AppTextStyle.title),
                  SizedBox(height: 8),
                  TextFormField(
                    decoration: InputDecoration(
                      label: Text('Customer'),
                    ),
                    readOnly: true,
                    style: AppTextStyle.textField,
                    controller: _customerNameController,
                    onTap: () async {
                      final customer = await context.pushNamed<Customer>(
                        'select-customer',
                      );
                      if (customer != null) {
                        setState(
                          () {
                            _customerNameController.text = customer.id!;
                          },
                        );
                      }
                    },
                  ),
                  BlocConsumer<ServiceBloc, ServiceState>(
                    listener: (context, state) {
                      if (state is ServiceStateFailure) {
                        showSnackbar(context, state.message.toString());
                      }
                    },
                    builder: (context, state) {
                      if (state is ServiceStateLoading) {
                        return WidgetLoading();
                      } else if (state is ServiceStateSuccessGetServices) {
                        final List<Service> services = state.services;

                        return TypeAheadField<Service>(
                          suggestionsCallback: (pattern) {
                            return services.where(
                              (service) {
                                return service.name!.toLowerCase().contains(
                                      pattern.toLowerCase(),
                                    );
                              },
                            ).toList();
                          },
                          builder: (context, controller, focusNode) {
                            return TextField(
                              controller: _serviceController,
                              focusNode: focusNode,
                              autofocus: true,
                              decoration: InputDecoration(
                                labelText: 'Service',
                              ),
                            );
                          },
                          itemBuilder: (context, service) {
                            return ListTile(
                              title: Text(service.name ?? ''),
                            );
                          },
                          onSelected: (service) {
                            _serviceController.text = service.name!;
                          },
                        );
                      } else {
                        return const SizedBox();
                      }
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Weight',
                    ),
                    controller: _weightController,
                    style: AppTextStyle.textField,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Amount',
                    ),
                    controller: _amountController,
                    style: AppTextStyle.textField,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Start Date',
                    ),
                    controller: _startDateController,
                    style: AppTextStyle.textField,
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (pickedTime != null) {
                          final dateTime = DateTime(
                            pickedDate.year,
                            pickedDate.month,
                            pickedDate.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );
                          setState(() {
                            _startDateController.text =
                                dateTime.toIso8601String();
                          });
                        }
                      }
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'End Date',
                    ),
                    controller: _endDateController,
                    style: AppTextStyle.textField,
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(Duration(days: 3)),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (pickedTime != null) {
                          final dateTime = DateTime(
                            pickedDate.year,
                            pickedDate.month,
                            pickedDate.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );
                          setState(() {
                            _endDateController.text =
                                dateTime.toIso8601String();
                          });
                        }
                      }
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Status',
                    ),
                    controller: _statusController,
                    style: AppTextStyle.textField,
                  ),
                  const SizedBox(height: 16),
                  WidgetButton(
                    label: appText.button_submit,
                    isLoading: state is TransactionStateLoading,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final newTransaction = Transaction(
                          id: transaction?.id,
                          customerId: _customerNameController.text,
                          serviceName: _serviceController.text,
                          weight: 3.1,
                          amount: int.tryParse(_amountController.text),
                          startDate: DateTime.parse(_startDateController.text),
                          endDate: DateTime.parse(_endDateController.text),
                          status: TransactionStatusId.received,
                        );

                        print(newTransaction);

                        onSubmit(newTransaction);
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  if (showDeleteButton)
                    WidgetTextButton(
                      label: appText.button_delete,
                      isLoading: state is TransactionStateLoading,
                      onPressed: () {},
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
