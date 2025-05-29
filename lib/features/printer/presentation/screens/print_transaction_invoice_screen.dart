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

  final TextEditingController _businessNameController = TextEditingController(text: 'Londri');
  final TextEditingController _businessAddressController = TextEditingController(text: 'Jl. Raya No. 123, Jakarta');
  final TextEditingController _businessPhoneController = TextEditingController(text: '0812-3456-7890');

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
          controller: _businessNameController,
        ),
        AppSizes.spaceHeight8,
        WidgetTextFormField(
          label: context.appText.printer_business_address,
          hint: context.appText.printer_business_address_hint,
          controller: _businessAddressController,
        ),
        AppSizes.spaceHeight8,
        WidgetTextFormField(
          label: context.appText.printer_business_phone,
          hint: context.appText.printer_business_phone_hint,
          controller: _businessPhoneController,
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

    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.size8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(AppSizes.size16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                _businessNameController.text,
                style: AppTextStyle.heading3.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              Text(
                _businessAddressController.text,
                style: AppTextStyle.body1,
                textAlign: TextAlign.center,
              ),
              Text(
                _businessPhoneController.text,
                style: AppTextStyle.body1,
                textAlign: TextAlign.center,
              ),

              AppSizes.spaceHeight16,

              Text(
                context.appText.invoice_print_title,
                style: AppTextStyle.heading3.copyWith(fontWeight: FontWeight.bold),
              ),

              Divider(thickness: 1),

              _buildInvoiceRow(
                label: context.appText.invoice_print_transaction_id,
                value: "#${_currentTransaction!.id!}",
              ),
              _buildInvoiceRow(
                label: context.appText.invoice_print_date,
                value: _currentTransaction!.createdAt?.formatDateOnly() ?? "-",
              ),
              _buildInvoiceRow(
                label: context.appText.invoice_print_customer_name,
                value: _currentTransaction!.customerName ?? "-",
              ),

              Divider(thickness: 1),

              _buildInvoiceRow(
                label: context.appText.invoice_print_service_name,
                value: _currentTransaction!.serviceName ?? "-",
              ),
              _buildInvoiceRow(
                label: context.appText.invoice_print_weight,
                value: "${_currentTransaction!.weight} kg",
              ),
              _buildInvoiceRow(
                label: context.appText.invoice_print_amount,
                value: "Rp ${_currentTransaction!.amount?.formatNumber() ?? '0'}",
              ),

              Divider(thickness: 1),

              // Status information
              _buildInvoiceRow(
                label: context.appText.invoice_print_transaction_status,
                value: getTransactionStatusValue(context, _currentTransaction!.transactionStatus ?? TransactionStatus.onProgress),
              ),
              _buildInvoiceRow(
                label: context.appText.invoice_print_payment_status,
                value: getPaymentStatusValue(context, _currentTransaction!.paymentStatus ?? PaymentStatus.notPaidYet),
              ),

              if (_currentTransaction!.startDate != null)
                _buildInvoiceRow(
                  label: context.appText.invoice_print_start_date,
                  value: _currentTransaction!.startDate?.formatDateOnly() ?? "-",
                ),

              if (_currentTransaction!.endDate != null)
                _buildInvoiceRow(
                  label: context.appText.invoice_print_end_date,
                  value: _currentTransaction!.endDate?.formatDateOnly() ?? "-",
                ),

              Divider(thickness: 1),

              if (_currentTransaction!.description != null && _currentTransaction!.description!.isNotEmpty) ...[
                AppSizes.spaceHeight8,
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    context.appText.invoice_print_invoices,
                    style: AppTextStyle.body1.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                AppSizes.spaceHeight4,
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _currentTransaction!.description!,
                    style: AppTextStyle.body1,
                  ),
                ),
                AppSizes.spaceHeight8,
              ],

              AppSizes.spaceHeight16,
              Text(
                context.appText.invoice_print_thank_you(_businessNameController.text),
                style: AppTextStyle.body1.copyWith(fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
              AppSizes.spaceHeight4,
              Text(
                '${context.appText.invoice_print_staff_name}: ${_currentTransaction!.userName ?? "-"}',
                style: AppTextStyle.caption.copyWith(fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceRow({
    required String label,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Text(
        '$label: $value',
        style: AppTextStyle.body1,
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
