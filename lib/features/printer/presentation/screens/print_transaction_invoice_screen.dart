import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../config/textstyle/app_colors.dart';
import '../../../../config/textstyle/app_sizes.dart';
import '../../../../config/textstyle/app_textstyle.dart';
import '../../../../core/utils/context_extensions.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/price_formatter.dart';
import '../../../../core/widgets/widget_app_bar.dart';
import '../../../../core/widgets/widget_button.dart';
import '../../../../core/widgets/widget_loading.dart';
import '../../../../core/widgets/widget_text_form_field.dart';
import '../../../../injection_container.dart';
import '../../../transaction/domain/entities/payment_status.dart';
import '../../../transaction/domain/entities/transaction.dart';
import '../../../transaction/domain/entities/transaction_status.dart';
import '../../../transaction/presentation/bloc/transaction_bloc.dart';
import '../../../transaction/presentation/widgets/widget_bottom_bar.dart';
import '../bloc/printer_bloc.dart';
import 'printer_settings_screen.dart';

void pushPrintTransactionInvoiceScreen({
  required BuildContext context,
  required String transactionId,
}) {
  context.pushNamed(
    RouteNames.printTransaction,
    pathParameters: {
      'id': transactionId.toString(),
    },
  );
}

class PrintTransactionInvoiceScreen extends StatefulWidget {
  final String transactionId;

  const PrintTransactionInvoiceScreen({
    super.key,
    required this.transactionId,
  });

  @override
  State<PrintTransactionInvoiceScreen> createState() => _PrintTransactionInvoiceScreenState();
}

class _PrintTransactionInvoiceScreenState extends State<PrintTransactionInvoiceScreen> {
  late final TransactionBloc _transactionBloc;
  late final PrinterBloc _printerBloc;

  final TextEditingController _businessNameController = TextEditingController(text: 'Laundry LB Fresh');
  final TextEditingController _businessAddressController = TextEditingController(text: 'Mantrijeron, Yogyakarta');
  final TextEditingController _businessPhoneController = TextEditingController(text: '0822-2367-6677');

  Transaction? _currentTransaction;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _transactionBloc = serviceLocator<TransactionBloc>();
    _printerBloc = serviceLocator<PrinterBloc>();
    _loadData();
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _businessAddressController.dispose();
    _businessPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _transactionBloc),
        BlocProvider.value(value: _printerBloc),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<TransactionBloc, TransactionState>(
            listener: (context, state) {
              if (state is TransactionStateSuccessGetTransactionById) {
                setState(() {
                  _currentTransaction = state.transaction;
                  _isLoading = false;
                });
              } else if (state is TransactionStateFailure) {
                context.showSnackbar(state.message);
                setState(() {
                  _isLoading = false;
                });
              }
            },
          ),
          BlocListener<PrinterBloc, PrinterState>(
            listener: (context, state) {
              if (state is PrinterStateSuccess) {
                context.showSnackbar(state.message);
                if (state.message.contains('Invoice printed successfully')) {
                  context.pop();
                }
              } else if (state is PrinterStateFailure) {
                context.showSnackbar(state.message);
              }
            },
          ),
        ],
        child: Scaffold(
          appBar: WidgetAppBar(
            title: context.appText.print_transaction_screen_title,
            action: IconButton(
              onPressed: () async {
                final result = await pushPrinterSettings(context: context);
                if (result) {
                  _printerBloc.add(PrinterEventGetPairedDevices());
                }
              },
              icon: Icon(Icons.settings),
              tooltip: context.appText.printer_settings_screen_title,
            ),
          ),
          body: _isLoading
              ? const WidgetLoading(usingPadding: true)
              : SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(AppSizes.size16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPrinterStatus(),
                        AppSizes.spaceHeight16,
                        Text(
                          context.appText.printer_business_info,
                          style: AppTextStyle.heading3,
                        ),
                        AppSizes.spaceHeight8,
                        _buildBusinessForm(),
                        AppSizes.spaceHeight16,
                        Expanded(
                          child: _buildInvoicePreview(),
                        ),
                      ],
                    ),
                  ),
                ),
          bottomNavigationBar: BlocBuilder<PrinterBloc, PrinterState>(
            builder: (context, state) {
              final bool isPrinting = state is PrinterStatePrinting;

              return WidgetBottomBar(content: [
                WidgetButton(
                  label: context.appText.printer_print_invoice,
                  isLoading: isPrinting,
                  onPressed: _currentTransaction != null ? () => _printInvoice(context) : () {},
                ),
              ]);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPrinterStatus() {
    return BlocBuilder<PrinterBloc, PrinterState>(
      builder: (context, state) {
        bool isConnected = false;
        BluetoothInfo? selectedPrinter;

        if (state is PrinterStatePairedDevicesLoaded) {
          isConnected = state.isConnected;
          selectedPrinter = state.selectedDevice;
        } else if (state is PrinterStateConnected) {
          isConnected = true;
          selectedPrinter = state.device;
        }

        return Container(
          padding: EdgeInsets.all(AppSizes.size12),
          decoration: BoxDecoration(
            color: isConnected ? AppColors.success.withValues(alpha: 0.1) : AppColors.warning.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.size8),
            border: Border.all(
              color: isConnected ? AppColors.success : AppColors.warning,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                color: isConnected ? AppColors.success : AppColors.warning,
              ),
              AppSizes.spaceWidth8,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isConnected ? context.appText.printer_status_connected(selectedPrinter!.name) : context.appText.printer_status_not_connected,
                      style: AppTextStyle.body1.copyWith(fontWeight: FontWeight.bold),
                    ),
                    if (isConnected && selectedPrinter != null)
                      Text(
                        selectedPrinter.name,
                        style: AppTextStyle.body2,
                      ),
                  ],
                ),
              ),
              SizedBox(
                width: AppSizes.size132,
                height: AppSizes.size40,
                child: WidgetButton(
                  label: isConnected ? context.appText.button_change : context.appText.button_connect,
                  backgroundColor: isConnected ? AppColors.success : AppColors.primary,
                  onPressed: () async {
                    final result = await pushPrinterSettings(context: context);

                    if (result) {
                      _printerBloc.add(PrinterEventGetPairedDevices());
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBusinessForm() {
    return Column(
      children: [
        WidgetTextFormField(
          label: context.appText.printer_business_name,
          hint: context.appText.printer_business_name_hint,
          maxLength: 32,
          controller: _businessNameController,
          onChanged: (value) {
            setState(() {});
          },
        ),
        AppSizes.spaceHeight8,
        WidgetTextFormField(
          label: context.appText.printer_business_address,
          hint: context.appText.printer_business_address_hint,
          maxLength: 32,
          controller: _businessAddressController,
          onChanged: (value) {
            setState(() {});
          },
        ),
        AppSizes.spaceHeight8,
        WidgetTextFormField(
          label: context.appText.printer_business_phone,
          hint: context.appText.printer_business_phone_hint,
          maxLength: 18,
          controller: _businessPhoneController,
          keyboardType: TextInputType.phone,
          onChanged: (value) {
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget _buildInvoicePreview() {
    if (_currentTransaction == null) {
      return Center(
        child: Text(context.appText.printer_no_transaction_data),
      );
    }
    final transaction = _currentTransaction!;
    final dateToday = DateTime.now().formatDateOnly();
    final startDate = transaction.startDate?.formatDateOnly() ?? '-';
    final endDate = transaction.endDate?.formatDateOnly() ?? '-';
    final staffName = transaction.userName ?? '-';

    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.onPrimary,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.gray.withValues(alpha: 0.2), width: 1),
        ),
        child: DefaultTextStyle(
          style: const TextStyle(
            fontFamily: 'Courier New',
            fontSize: 11,
            color: AppColors.onSecondary,
            height: 1.2,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header with title
              const Divider(thickness: 2),
              Text(
                context.appText.invoice_print_title.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Divider(thickness: 2),
              const SizedBox(height: 8),

              // Business Info
              Text(_businessNameController.text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Text(_businessAddressController.text),
              Text(_businessPhoneController.text),
              const Divider(thickness: 1),
              const SizedBox(height: 8),

              // QR Code placeholder
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.gray),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Center(
                  child: Text(
                    'QR\nCODE',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Transaction ID and Date
              Text(transaction.id ?? '-', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(dateToday),
              const Divider(thickness: 1),
              const SizedBox(height: 8),

              // Transaction Details
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Customer
                    Text(
                        '${context.appText.invoice_print_customer_name.padRight(15)}: ${transaction.customerName ?? '-'}'),
                    const SizedBox(height: 4),

                    // Service
                    Text(
                        '${context.appText.invoice_print_service_name.padRight(15)}: ${transaction.serviceName ?? '-'}'),
                    const SizedBox(height: 4),

                    // Weight
                    Text('${context.appText.invoice_print_weight.padRight(15)}: ${transaction.weight ?? '-'} kg'),
                    const SizedBox(height: 4),

                    // Amount
                    Text(
                      '${context.appText.invoice_print_amount.padRight(15)}: ${transaction.amount?.formatNumber() ?? '-'}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),

                    // Staff
                    Text('${context.appText.invoice_print_staff_name.padRight(15)}: $staffName'),

                    // Notes (if available)
                    if (transaction.description != null && transaction.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text('${context.appText.invoice_print_notes.padRight(15)}: ${transaction.description!}'),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 8),
              const Divider(thickness: 1),

              // Dates Section
              Text(startDate, style: const TextStyle(fontWeight: FontWeight.bold)),
              const Text('---', style: TextStyle(fontSize: 8)),
              Text(endDate, style: const TextStyle(fontWeight: FontWeight.bold)),

              const Divider(thickness: 1),
              const SizedBox(height: 8),

              // Status
              Text(
                '${getTransactionStatusValue(context, transaction.transactionStatus ?? TransactionStatus.other)} | ${getPaymentStatusValue(context, transaction.paymentStatus ?? PaymentStatus.other)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),

              const Divider(thickness: 1),
              const SizedBox(height: 8),

              // Thank You
              Text(
                context.appText.invoice_print_thank_you,
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _printInvoice(BuildContext context) {
    if (_currentTransaction == null) {
      context.showSnackbar(context.appText.printer_no_transaction_data);
      return;
    }

    context.read<PrinterBloc>().add(
          PrinterEventPrintInvoice(
            context: context,
            transaction: _currentTransaction!,
            businessName: _businessNameController.text,
            businessAddress: _businessAddressController.text,
            businessPhone: _businessPhoneController.text,
          ),
        );

    return;
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    _printerBloc.add(PrinterEventInitialize());
    _transactionBloc.add(TransactionEventGetTransactionById(id: widget.transactionId));
  }
}
